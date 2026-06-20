import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/models.dart';
import '../state/app_state.dart';
import 'tracks_detail_screen.dart';

class PlaylistDetail extends StatelessWidget {
  final Playlist playlist;
  const PlaylistDetail({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final c = context.read<AppState>().client!;
    final isLocal = playlist.source == 'local';
    // Smart (dynamic) playlists are read-only; everything else is editable.
    final editable = playlist.source != 'smart';
    return TracksDetailScreen(
      title: playlist.name,
      subtitle: [
        playlist.owner,
        if (playlist.trackCount != null) '${playlist.trackCount} pistes',
      ].where((e) => e != null && e.isNotEmpty).join(' · '),
      coverPath: playlist.coverPath,
      loadTracks: () {
        switch (playlist.source) {
          case 'smart':
            return c.smartPlaylistTracks(playlist.id);
          case 'local':
            return c.localPlaylistTracks(playlist.id);
          default:
            return c.streamingPlaylistTracks(playlist.source, playlist.id);
        }
      },
      onDelete: !editable
          ? null
          : () => isLocal
              ? c.deleteLocalPlaylist(playlist.id)
              : c.deleteStreamingPlaylist(playlist.source, playlist.id),
      onRemoveTrack: !editable
          ? null
          : (index, track) => isLocal
              ? c.removeLocalPlaylistTrack(playlist.id, index)
              : c.removeStreamingPlaylistTracks(
                  playlist.source, playlist.id, [track.sourceId]),
    );
  }
}
