import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/cover.dart';
import '../widgets/favorite_button.dart';
import '../widgets/responsive.dart';
import '../widgets/track_tile.dart';

/// Generic "list of tracks" screen used for albums and playlists.
class TracksDetailScreen extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? coverPath;
  final Future<List<Track>> Function() loadTracks;

  /// Optional favorite target for the whole collection (album / playlist).
  final String? favoriteSource;
  final String? favoriteType; // 'albums' | 'playlists'
  final String? favoriteId;

  const TracksDetailScreen({
    super.key,
    required this.title,
    required this.loadTracks,
    this.subtitle,
    this.coverPath,
    this.favoriteSource,
    this.favoriteType,
    this.favoriteId,
  });

  @override
  State<TracksDetailScreen> createState() => _TracksDetailScreenState();
}

class _TracksDetailScreenState extends State<TracksDetailScreen> {
  List<Track>? _tracks;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final t = await widget.loadTracks();
      if (mounted) setState(() => _tracks = t);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _playAll(int startIndex) async {
    final app = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final t = AppL.of(context);
    try {
      // No success toast — the mini player is the confirmation.
      await app.playTracks(_tracks!, startIndex: startIndex);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(t.errorWith('$e'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracks = _tracks;
    final t = AppL.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
        actions: [
          if (widget.favoriteId != null && widget.favoriteType != null)
            FavoriteButton(
              source: widget.favoriteSource ?? '',
              type: widget.favoriteType!,
              id: widget.favoriteId!,
            ),
        ],
      ),
      body: _error != null
          ? Center(child: Text(t.errorWith(_error!)))
          : tracks == null
              ? const Center(child: CircularProgressIndicator())
              : MaxWidth(
                  maxWidth: 860,
                  child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Cover(path: widget.coverPath, size: 96, radius: 10),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.title,
                                    style: Theme.of(context).textTheme.titleLarge,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                if (widget.subtitle != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(widget.subtitle!,
                                        style: const TextStyle(color: Colors.white54)),
                                  ),
                                const SizedBox(height: 10),
                                FilledButton.icon(
                                  onPressed: tracks.isEmpty ? null : () => _playAll(0),
                                  icon: const Icon(Icons.play_arrow),
                                  label: Text(t.playAll),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    if (tracks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(child: Text(t.noTracks)),
                      )
                    else
                      for (var i = 0; i < tracks.length; i++)
                        TrackTile(
                          track: tracks[i],
                          onTap: () => _playAll(i),
                        ),
                    const SizedBox(height: 24),
                  ],
                  ),
                ),
    );
  }
}
