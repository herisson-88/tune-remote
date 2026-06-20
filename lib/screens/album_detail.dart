import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/models.dart';
import '../state/app_state.dart';
import 'tracks_detail_screen.dart';

class AlbumDetail extends StatelessWidget {
  final Album album;
  const AlbumDetail({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final c = context.read<AppState>().client!;
    return TracksDetailScreen(
      title: album.title,
      subtitle: [album.artistName, album.year?.toString()]
          .where((e) => e != null && e.isNotEmpty)
          .join(' · '),
      coverPath: album.coverPath,
      loadTracks: () => album.source == 'local'
          ? c.localAlbumTracks(album.sourceId)
          : c.streamingAlbumTracks(album.source, album.sourceId),
      favoriteSource: album.source,
      favoriteType: 'albums',
      favoriteId: album.sourceId,
    );
  }
}
