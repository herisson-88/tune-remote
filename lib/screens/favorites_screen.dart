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

class _Favorites {
  final String service;
  final List<Album> albums;
  final List<Artist> artists;
  final List<Track> tracks;
  _Favorites(this.service, this.albums, this.artists, this.tracks);
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<_Favorites>? _data;
  String? _error;
  bool _loading = false;
  String? _loadedSig; // signature of authenticated services last loaded
  String? _sourceFilter; // null = all services

  /// Identifies the current set of usable services (host + authenticated names).
  /// Changes whenever a service logs in/out, so favorites reload on auth.
  String _authSig(AppState app) {
    final svcs = app.services.values
        .where((s) => s.enabled && s.authenticated)
        .map((s) => s.name)
        .toList()
      ..sort();
    return '${app.host}|${svcs.join(',')}';
  }

  Future<List<Map<String, dynamic>>> _safe(
      Future<List<Map<String, dynamic>>> Function() f) async {
    try {
      return await f();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _load() async {
    final app = context.read<AppState>();
    final c = app.client;
    if (c == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final out = <_Favorites>[];
      for (final s in app.services.values) {
        if (!(s.enabled && s.authenticated)) continue;
        final svc = s.name;
        final albums = await _safe(() => c.favorites(svc, 'albums'));
        final artists = await _safe(() => c.favorites(svc, 'artists'));
        final tracks = await _safe(() => c.favorites(svc, 'tracks'));
        out.add(_Favorites(
          svc,
          albums.map((m) => Album.fromJson(m, source: svc)).toList(),
          artists.map((m) => Artist.fromJson(m, source: svc)).toList(),
          tracks.map((m) => Track.fromJson(m, source: svc)).toList(),
        ));
      }
      if (mounted) {
        setState(() {
          _data = out;
          _loadedSig = _authSig(app);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _open(Widget s) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => s));

  Widget _sourceChips() {
    final data = _data!;
    final sources = data
        .where((f) =>
            f.albums.isNotEmpty || f.artists.isNotEmpty || f.tracks.isNotEmpty)
        .map((f) => f.service)
        .toList();
    if (sources.length < 2) return const SizedBox.shrink();
    Widget chip(String? src, String label) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(label),
            selected: _sourceFilter == src,
            onSelected: (_) => setState(() => _sourceFilter = src),
          ),
        );
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          chip(null, AppL.of(context).filterAll),
          for (final s in sources) chip(s, s.toUpperCase()),
        ],
      ),
    );
  }

  // Build a tab body that groups [items per service] under service headers.
  Widget _grouped(
    bool Function(_Favorites) hasAny,
    List<Widget> Function(_Favorites) cardsFor,
    String emptyLabel,
  ) {
    final data = _data!;
    final services = data
        .where((f) =>
            (_sourceFilter == null || f.service == _sourceFilter) && hasAny(f))
        .toList();
    if (services.isEmpty) return Center(child: Text(emptyLabel));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          for (final f in services) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(f.service.toUpperCase(),
                  style: Theme.of(context).textTheme.titleSmall),
            ),
            ...cardsFor(f),
          ],
        ],
      ),
    );
  }

  /// Responsive card grid: columns and card width adapt to the screen width.
  Widget _responsiveCards(List<Widget Function(double width)> builders) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: LayoutBuilder(builder: (ctx, c) {
          const gap = 12.0;
          const minW = 110.0;
          final cols = ((c.maxWidth + gap) / (minW + gap)).floor().clamp(2, 6);
          final w = (c.maxWidth - gap * (cols - 1)) / cols;
          return Wrap(
            spacing: gap,
            runSpacing: 14,
            children: [for (final b in builders) b(w)],
          );
        }),
      );

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = AppL.of(context);
    if (app.connected && !_loading && _loadedSig != _authSig(app)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load();
      });
    }

    Widget body;
    if (!app.connected) {
      body = const NotConnected();
    } else if (_loading && _data == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(child: Text(t.errorWith(_error!)));
    } else if (_data == null) {
      body = const SizedBox.shrink();
    } else {
      body = Column(
        children: [
          _sourceChips(),
          Expanded(
            child: TabBarView(
        children: [
          // Artistes
          _grouped(
            (f) => f.artists.isNotEmpty,
            (f) => [
              _responsiveCards([
                for (final a in f.artists)
                  (w) => MediaCard(
                        coverPath: a.picture,
                        title: a.name,
                        round: true,
                        fallback: Icons.person,
                        width: w,
                        onTap: () => _open(ArtistDetail(artist: a)),
                      ),
              ]),
            ],
            t.noFavArtists,
          ),
          // Albums
          _grouped(
            (f) => f.albums.isNotEmpty,
            (f) => [
              _responsiveCards([
                for (final al in f.albums)
                  (w) => MediaCard(
                        coverPath: al.coverPath,
                        title: al.title,
                        subtitle: al.artistName,
                        width: w,
                        onTap: () => _open(AlbumDetail(album: al)),
                      ),
              ]),
            ],
            t.noFavAlbums,
          ),
          // Titres
          _grouped(
            (f) => f.tracks.isNotEmpty,
            (f) => [for (final tr in f.tracks) TrackTile(track: tr)],
            t.noFavTracks,
          ),
        ],
            ),
          ),
        ],
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.favoritesTitle),
          actions: [
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: t.tabArtists),
              Tab(text: t.tabAlbums),
              Tab(text: t.tabTracks),
            ],
          ),
        ),
        body: MaxWidth(maxWidth: 1100, child: body),
      ),
    );
  }
}
