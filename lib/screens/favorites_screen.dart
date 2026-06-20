import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/models.dart';
import '../api/tune_client.dart';
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
  int _favSeen = -1; // last seen AppState.favVersion

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

  /// Local favorites are stored as bare (type, id) refs per profile, so each
  /// has to be hydrated via /library/{type}/{id}. Returns null if none.
  Future<_Favorites?> _loadLocal(TuneClient c, int profileId) async {
    final albums = <Album>[];
    final artists = <Artist>[];
    final tracks = <Track>[];
    try {
      for (final id in await c.localFavoriteIds(profileId, 'track')) {
        try {
          tracks.add(await c.localTrackById(id));
        } catch (_) {}
      }
      for (final id in await c.localFavoriteIds(profileId, 'album')) {
        try {
          albums.add(await c.localAlbumById(id));
        } catch (_) {}
      }
      for (final id in await c.localFavoriteIds(profileId, 'artist')) {
        try {
          artists.add(await c.localArtistById(id));
        } catch (_) {}
      }
    } catch (_) {}
    if (albums.isEmpty && artists.isEmpty && tracks.isEmpty) return null;
    return _Favorites('local', albums, artists, tracks);
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
      // Local library favorites: refs are bare IDs, hydrated one by one.
      final local = await _loadLocal(c, app.profileId);
      if (local != null) out.add(local);
      if (mounted) {
        setState(() {
          _data = out;
          _loadedSig = _authSig(app);
          _favSeen = app.favVersion;
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

  String _srcLabel(String s) =>
      s == 'local' ? AppL.of(context).sourceLibrary : s.toUpperCase();

  /// One source's favorites, split into Artists / Albums / Tracks tabs.
  Widget _sourceFavorites(_Favorites f) {
    final t = AppL.of(context);
    Widget tab(bool empty, String emptyLabel, Widget child) => empty
        ? Center(child: Text(emptyLabel))
        : RefreshIndicator(onRefresh: _load, child: child);

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: t.tabArtists),
              Tab(text: t.tabAlbums),
              Tab(text: t.tabTracks),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                tab(
                  f.artists.isEmpty,
                  t.noFavArtists,
                  ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: [
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
                  ),
                ),
                tab(
                  f.albums.isEmpty,
                  t.noFavAlbums,
                  ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    children: [
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
                  ),
                ),
                tab(
                  f.tracks.isEmpty,
                  t.noFavTracks,
                  ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [for (final tr in f.tracks) TrackTile(track: tr)],
                  ),
                ),
              ],
            ),
          ),
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
    // Reload when the authenticated services change OR any favorite is toggled.
    if (app.connected &&
        !_loading &&
        (_loadedSig != _authSig(app) || _favSeen != app.favVersion)) {
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
      // One group per source that actually has favorites.
      final groups = _data!
          .where((f) =>
              f.albums.isNotEmpty || f.artists.isNotEmpty || f.tracks.isNotEmpty)
          .toList();
      if (groups.isEmpty) {
        // Empty placeholder so the type tabs still render their empty states.
        body = _sourceFavorites(_Favorites('', const [], const [], const []));
      } else if (groups.length == 1) {
        body = _sourceFavorites(groups.first);
      } else {
        // Outer tabs = sources (Bibliothèque, Qobuz, Tidal…).
        body = DefaultTabController(
          length: groups.length,
          child: Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.surface,
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [for (final g in groups) Tab(text: _srcLabel(g.service))],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [for (final g in groups) _sourceFavorites(g)],
                ),
              ),
            ],
          ),
        );
      }
    }

    return Scaffold(
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
      ),
      body: MaxWidth(maxWidth: 1100, child: body),
    );
  }
}
