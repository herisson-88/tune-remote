import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/media_card.dart';
import '../widgets/responsive.dart';
import '../widgets/track_tile.dart';
import 'album_detail.dart';
import 'artist_detail.dart';
import 'playlist_detail.dart';

const _sourceLabels = {
  'qobuz': 'Qobuz',
  'youtube': 'YouTube',
  'tidal': 'Tidal',
  'deezer': 'Deezer',
  'local': 'Bibliothèque',
};

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  FederatedResults? _results;
  bool _loading = false;
  String? _error;
  String? _target; // null = all sources; else the source to search

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    final client = context.read<AppState>().client;
    if (client == null) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await client.search(q,
          sources: _target == null ? null : [_target!]);
      if (mounted) setState(() => _results = r);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Available search targets: authenticated services + local library.
  List<String> _targets(AppState app) => [
        for (final s in app.services.values)
          if (s.enabled && s.authenticated) s.name,
        'local',
      ];

  void _open(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  List<Widget> _sectionFor(String source, SearchSection s) {
    if (s.isEmpty) return const [];
    final t = AppL.of(context);
    final label =
        source == 'local' ? t.sourceLibrary : (_sourceLabels[source] ?? source);
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
        child: Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
      CardRow(
        title: t.sectionArtists,
        cards: [
          for (final a in s.artists)
            MediaCard(
              coverPath: a.picture,
              title: a.name,
              round: true,
              fallback: Icons.person,
              onTap: () => _open(ArtistDetail(artist: a)),
            ),
        ],
      ),
      CardRow(
        title: t.sectionAlbums,
        cards: [
          for (final al in s.albums)
            MediaCard(
              coverPath: al.coverPath,
              title: al.title,
              subtitle: al.artistName,
              onTap: () => _open(AlbumDetail(album: al)),
            ),
        ],
      ),
      CardRow(
        title: t.sectionPlaylists,
        cards: [
          for (final p in s.playlists)
            MediaCard(
              coverPath: p.coverPath,
              title: p.name,
              subtitle: p.owner,
              fallback: Icons.queue_music,
              onTap: () => _open(PlaylistDetail(playlist: p)),
            ),
        ],
      ),
      if (s.tracks.isNotEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(t.sectionTracks,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      for (final tr in s.tracks.take(12)) TrackTile(track: tr),
    ];
  }

  /// Target selector: choose what to search (all sources, or a single one).
  /// Changing it re-runs the current query, like the web app.
  Widget _targetChips(AppState app) {
    final targets = _targets(app);
    if (targets.length < 2) return const SizedBox.shrink();
    void pick(String? src) {
      if (_target == src) return;
      setState(() => _target = src);
      if (_ctrl.text.trim().isNotEmpty) _search();
    }

    final t = AppL.of(context);
    Widget chip(String? src, String label) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(label),
            selected: _target == src,
            onSelected: (_) => pick(src),
          ),
        );
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          chip(null, t.filterAll),
          for (final s in targets)
            chip(s, s == 'local' ? t.sourceLibrary : (_sourceLabels[s] ?? s)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = AppL.of(context);
    final r = _results;

    final List<Widget> body = [];
    if (r != null) {
      // Streaming services first (qobuz, youtube…), then local library.
      for (final entry in r.services.entries) {
        body.addAll(_sectionFor(entry.key, entry.value));
      }
      body.addAll(_sectionFor('local', r.local));
      if (body.isEmpty) {
        body.add(Padding(
          padding: const EdgeInsets.all(32),
          child: Center(child: Text(t.noResults)),
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.searchTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: SearchBar(
              controller: _ctrl,
              hintText: t.searchHint,
              leading: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.search),
              ),
              trailing: [
                if (_ctrl.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() {
                      _ctrl.clear();
                      _results = null;
                    }),
                  ),
              ],
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _search(),
            ),
          ),
          if (app.connected) _targetChips(app),
          Expanded(
            child: !app.connected
                ? const NotConnected()
                : _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(t.errorWith(_error!)))
                        : r == null
                            ? const _SearchHint()
                            : MaxWidth(
                                maxWidth: 1000,
                                child: ListView(children: [
                                  ...body,
                                  const SizedBox(height: 24),
                                ]),
                              ),
          ),
        ],
      ),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint();
  @override
  Widget build(BuildContext context) {
    final t = AppL.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.travel_explore, size: 56, color: Colors.white24),
            const SizedBox(height: 14),
            Text(
              t.searchEmptyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              t.searchEmptySub,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}
