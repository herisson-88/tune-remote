import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/cover.dart';
import '../widgets/favorite_button.dart';
import '../widgets/mini_player.dart';
import 'album_detail.dart';

class ArtistDetail extends StatefulWidget {
  final Artist artist;
  const ArtistDetail({super.key, required this.artist});

  @override
  State<ArtistDetail> createState() => _ArtistDetailState();
}

class _ArtistDetailState extends State<ArtistDetail> {
  List<Album>? _albums;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final c = context.read<AppState>().client!;
      final a = widget.artist.source == 'local'
          ? await c.localArtistAlbums(widget.artist.id)
          : await c.streamingArtistAlbums(widget.artist.source, widget.artist.id);
      if (mounted) setState(() => _albums = a);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final albums = _albums;
    final t = AppL.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.artist.name),
        actions: [
          FavoriteButton(
            source: widget.artist.source,
            type: 'artists',
            id: widget.artist.id,
          ),
        ],
      ),
      body: _error != null
          ? Center(child: Text(t.errorWith(_error!)))
          : albums == null
              ? const Center(child: CircularProgressIndicator())
              : albums.isEmpty
                  ? Center(child: Text(t.noResults))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 180,
                        childAspectRatio: 0.74,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: albums.length,
                      itemBuilder: (_, i) {
                        final al = albums[i];
                        return InkWell(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => AlbumDetail(album: al))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Cover(path: al.coverPath, size: 156, radius: 10),
                              const SizedBox(height: 6),
                              Text(al.title,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              if (al.year != null)
                                Text('${al.year}',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
