import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Decorative animated spectrum (the phone has no audio stream — playback is
/// on the renderer — so this is an ambient visualizer, not a real FFT).
/// It animates while [active] and settles to a low idle state when paused.
class SpectrumVisualizer extends StatefulWidget {
  final bool active;
  final Color color;
  final int bars;
  const SpectrumVisualizer({
    super.key,
    required this.active,
    required this.color,
    this.bars = 40,
  });

  @override
  State<SpectrumVisualizer> createState() => _SpectrumVisualizerState();
}

class _SpectrumVisualizerState extends State<SpectrumVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<double> _phase;
  late final List<double> _speed;
  late final List<double> _env; // frequency envelope (bass louder)

  @override
  void initState() {
    super.initState();
    final rnd = math.Random(7);
    _phase = List.generate(widget.bars, (_) => rnd.nextDouble() * math.pi * 2);
    _speed = List.generate(widget.bars, (_) => 0.6 + rnd.nextDouble() * 1.8);
    _env = List.generate(widget.bars, (i) {
      final x = i / widget.bars;
      // gentle hump: a bit louder in the low-mids, tapering to the highs
      return 0.55 + 0.45 * math.exp(-math.pow((x - 0.25) * 2.4, 2).toDouble());
    });
    _c = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value * math.pi * 2;
        final amp = widget.active ? 1.0 : 0.12;
        final heights = List<double>.generate(widget.bars, (i) {
          final base = (math.sin(t * _speed[i] + _phase[i]) +
                  0.5 * math.sin(t * _speed[i] * 0.5 + _phase[i] * 1.7)) /
              1.5;
          final h = 0.08 + (0.5 + 0.5 * base) * _env[i] * amp;
          return h.clamp(0.04, 1.0);
        });
        return CustomPaint(
          painter: _BarsPainter(heights, widget.color),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BarsPainter extends CustomPainter {
  final List<double> heights;
  final Color color;
  _BarsPainter(this.heights, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final n = heights.length;
    final gap = size.width / n * 0.35;
    final bw = size.width / n - gap;
    final mid = size.height / 2;
    for (var i = 0; i < n; i++) {
      final h = heights[i] * size.height * 0.5;
      final x = i * (bw + gap) + gap / 2;
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [color.withValues(alpha: 0.35), color],
        ).createShader(Rect.fromLTWH(x, mid - h, bw, h * 2));
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, mid - h, bw, h * 2),
        Radius.circular(bw / 2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) => true;
}
