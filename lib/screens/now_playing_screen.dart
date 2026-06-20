import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/cover.dart';
import '../widgets/favorite_button.dart';
import '../widgets/responsive.dart';
import '../widgets/spectrum_visualizer.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  bool _viz = false;
  double? _drag;

  String _fmt(int ms) {
    final s = ms ~/ 1000;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l = AppL.of(context);
    final z = app.currentZone;
    final t = z?.currentTrack;
    final cs = Theme.of(context).colorScheme;

    if (z == null || t == null || z.state == 'stopped') {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              onPressed: () => Navigator.maybePop(context)),
        ),
        body: Center(child: Text(l.nothingPlaying)),
      );
    }

    final dur = t.durationMs ?? 0;
    final pos = _drag ?? z.positionMs.toDouble();
    final size = MediaQuery.of(context).size;
    final wide = size.width >= Breakpoints.rail;
    final artSide = wide
        ? (size.height - 140).clamp(220.0, 460.0)
        : size.width - 56;

    // Cover ⇄ visualizer
    final art = SizedBox(
      width: artSide,
      height: artSide,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _viz
            ? Container(
                key: const ValueKey('viz'),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child:
                    SpectrumVisualizer(active: z.isPlaying, color: cs.primary),
              )
            : Cover(
                key: const ValueKey('cover'),
                path: t.coverPath,
                size: artSide,
                radius: 16),
      ),
    );

    // Title / artist / album / quality
    final info = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(t.title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text(
              [t.artistName, t.albumTitle]
                  .where((e) => e != null && e.isNotEmpty)
                  .join(' · '),
              style: TextStyle(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          if (t.quality != null && !t.quality!.isEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(t.quality!.label,
                  style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );

    final seekBar = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: dur > 0 ? pos.clamp(0, dur.toDouble()) : 0,
              max: dur > 0 ? dur.toDouble() : 1,
              onChanged: dur > 0 ? (v) => setState(() => _drag = v) : null,
              onChangeEnd: (v) {
                setState(() => _drag = null);
                app.seek(v.toInt());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(pos.toInt()),
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                Text(_fmt(dur),
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );

    final controls = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            iconSize: 40,
            icon: const Icon(Icons.skip_previous),
            onPressed: app.previous),
        const SizedBox(width: 16),
        IconButton.filled(
          iconSize: 44,
          icon: Icon(z.isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: app.togglePlay,
        ),
        const SizedBox(width: 16),
        IconButton(
            iconSize: 40,
            icon: const Icon(Icons.skip_next),
            onPressed: app.next),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(z.name, style: const TextStyle(fontSize: 14)),
        actions: [
          FavoriteButton(source: t.source, type: 'tracks', id: t.sourceId),
          IconButton(
            tooltip: _viz ? l.cover : l.visualizer,
            icon: Icon(_viz ? Icons.album : Icons.graphic_eq),
            onPressed: () => setState(() => _viz = !_viz),
          ),
        ],
      ),
      body: SafeArea(
        child: wide
            // Two-pane: artwork left, info + controls right.
            ? Row(
                children: [
                  Expanded(child: Center(child: art)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          info,
                          const SizedBox(height: 32),
                          seekBar,
                          const SizedBox(height: 12),
                          controls,
                        ],
                      ),
                    ),
                  ),
                ],
              )
            // Single column (phones).
            : Column(
                children: [
                  const Spacer(),
                  art,
                  const SizedBox(height: 28),
                  info,
                  const Spacer(),
                  seekBar,
                  const SizedBox(height: 8),
                  controls,
                  const SizedBox(height: 28),
                ],
              ),
      ),
    );
  }
}
