import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/now_playing_screen.dart';
import '../state/app_state.dart';
import 'cover.dart';

/// Compact now-playing bar shown above the bottom navigation.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final z = app.currentZone;
    final t = z?.currentTrack;
    if (z == null || t == null || z.state == 'stopped') {
      return const SizedBox.shrink();
    }

    final dur = t.durationMs ?? 0;
    final progress = dur > 0 ? (z.positionMs / dur).clamp(0.0, 1.0) : 0.0;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerHigh,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 2,
            backgroundColor: cs.surfaceContainerHighest,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const NowPlayingScreen())),
                    child: Row(
                      children: [
                        Cover(path: t.coverPath, size: 44, radius: 6),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(t.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              if (t.artistName != null)
                                Text(t.artistName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: cs.onSurfaceVariant, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: app.previous,
                ),
                IconButton.filled(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(z.isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: app.togglePlay,
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.skip_next),
                  onPressed: app.next,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
