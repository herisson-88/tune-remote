import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import 'cover.dart';
import 'favorite_button.dart';

/// A track row. Tapping plays it (single) by default, or runs [onTap] if given.
class TrackTile extends StatelessWidget {
  final Track track;
  final VoidCallback? onTap;
  final Widget? trailing;

  const TrackTile({super.key, required this.track, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final q = track.quality;

    // Is THIS track the one currently playing on the active zone?
    // Using select() so tiles only rebuild when the playing track changes,
    // not on every position poll.
    final playingId = context.select<AppState, String?>((s) {
      final z = s.currentZone;
      if (z == null || z.currentTrack == null || z.state == 'stopped') {
        return null;
      }
      return '${z.currentTrack!.source}:${z.currentTrack!.sourceId}';
    });
    final isCurrent = playingId == '${track.source}:${track.sourceId}';

    return ListTile(
      selected: isCurrent,
      selectedTileColor: cs.primary.withValues(alpha: 0.08),
      leading: Stack(
        alignment: Alignment.center,
        children: [
          Cover(path: track.coverPath, size: 48),
          if (isCurrent)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.graphic_eq, color: cs.primary, size: 22),
            ),
        ],
      ),
      title: Text(track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: isCurrent
              ? TextStyle(color: cs.primary, fontWeight: FontWeight.w600)
              : null),
      subtitle: Text(
        [track.artistName, track.albumTitle]
            .where((e) => e != null && e.isNotEmpty)
            .join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (q != null && !q.isEmpty)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: q.isHiRes
                            ? cs.primaryContainer
                            : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        q.short,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: q.isHiRes
                              ? cs.onPrimaryContainer
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (track.durationMs != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(track.durationLabel,
                          style:
                              TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
                    ),
                ],
              ),
              FavoriteButton(
                source: track.source,
                type: 'tracks',
                id: track.sourceId,
                size: 20,
              ),
            ],
          ),
      onTap: onTap ?? () => playAndToast(context, track),
    );
  }
}

Future<void> playAndToast(BuildContext context, Track t) async {
  final app = context.read<AppState>();
  final messenger = ScaffoldMessenger.of(context);
  final loc = AppL.of(context);
  try {
    // No success toast — the mini player appearing is the confirmation.
    await app.playTrack(t);
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(loc.errorWith('$e'))));
  }
}

/// Shown when the app isn't connected to a backend yet.
class NotConnected extends StatelessWidget {
  final String? label;
  const NotConnected({super.key, this.label});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.white24),
            const SizedBox(height: 12),
            Text(label ?? AppL.of(context).notConnected,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
