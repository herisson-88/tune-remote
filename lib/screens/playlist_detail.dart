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
    );
  }
}
