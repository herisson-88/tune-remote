import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/cover.dart';
import '../widgets/mini_player.dart';
import 'album_detail.dart';
import 'playlist_detail.dart';

/// Qobuz "expert" (editorial) playlists for a genre — reached from the genre
/// chip in the full player.
class GenrePlaylistsScreen extends StatefulWidget {
  final String source;
  final String genreId;
  final String genreName;
  const GenrePlaylistsScreen({
    super.key,
    required this.source,
    required this.genreId,
    required this.genreName,
  });

  @override
  State<GenrePlaylistsScreen> createState() => _GenrePlaylistsScreenState();
}

class _GenrePlaylistsScreenState extends State<GenrePlaylistsScreen> {
  List<Playlist>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final c = context.read<AppState>().client!;
      final p = await c.featuredPlaylists(widget.source, genre: widget.genreId);
      if (mounted) setState(() => _items = p);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL.of(context);
    final items = _items;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.genreName),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(t.expertPlaylists,
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
        ),
      ),
      body: _error != null
          ? Center(child: Text(t.errorWith(_error!)))
          : items == null
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? Center(child: Text(t.noResults))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, indent: 76),
                      itemBuilder: (_, i) {
                        final p = items[i];
                        return ListTile(
                          leading: Cover(
                              path: p.coverPath,
                              size: 52,
                              radius: 6,
                              fallback: Icons.queue_music),
                          title: Text(p.name,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: p.trackCount != null
                              ? Text(t.tracksCount(p.trackCount!))
                              : (p.owner != null ? Text(p.owner!) : null),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      PlaylistDetail(playlist: p))),
                        );
                      },
                    ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}

/// A record label's full album catalogue — reached from the label chip in the
/// full player. The album id of the now-playing track resolves the label.
class LabelAlbumsScreen extends StatefulWidget {
  final String source;
  final String albumId;
  final String labelName;
  const LabelAlbumsScreen({
    super.key,
    required this.source,
    required this.albumId,
    required this.labelName,
  });

  @override
  State<LabelAlbumsScreen> createState() => _LabelAlbumsScreenState();
}

class _LabelAlbumsScreenState extends State<LabelAlbumsScreen> {
  List<Album>? _albums;
  String _title = '';
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _title = widget.labelName;
    _load();
  }

  Future<void> _load() async {
    try {
      final c = context.read<AppState>().client!;
      final r = await c.albumLabel(widget.source, widget.albumId);
      if (mounted) {
        setState(() {
          if (r.name.isNotEmpty) _title = r.name;
          _albums = r.albums;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL.of(context);
    final albums = _albums;
    final q = _query.trim().toLowerCase();
    final filtered = albums == null
        ? const <Album>[]
        : (q.isEmpty
            ? albums
            : albums
                .where((a) =>
                    a.title.toLowerCase().contains(q) ||
                    (a.artistName ?? '').toLowerCase().contains(q))
                .toList());

    return Scaffold(
      appBar: AppBar(title: Text(_title.isEmpty ? t.label : _title)),
      body: _error != null
          ? Center(child: Text(t.errorWith(_error!)))
          : albums == null
              ? const Center(child: CircularProgressIndicator())
              : albums.isEmpty
                  ? Center(child: Text(t.noResults))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: TextField(
                            decoration: InputDecoration(
                              isDense: true,
                              prefixIcon: const Icon(Icons.search),
                              hintText: t.navSearch,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (v) => setState(() => _query = v),
                          ),
                        ),
                        Expanded(
                          child: filtered.isEmpty
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
                                  itemCount: filtered.length,
                                  itemBuilder: (_, i) {
                                    final al = filtered[i];
                                    return InkWell(
                                      onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  AlbumDetail(album: al))),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Cover(
                                              path: al.coverPath,
                                              size: 156,
                                              radius: 10),
                                          const SizedBox(height: 6),
                                          Text(al.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                          if (al.artistName != null &&
                                              al.artistName!.isNotEmpty)
                                            Text(al.artistName!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}
