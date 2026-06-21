import 'dart:convert';
import 'package:http/http.dart' as http;

import 'models.dart';

/// Thin REST client for the tune-server backend. Pure remote: every call
/// targets `http://<host>/api/v1/...` exactly like the working web app.
class TuneClient {
  /// e.g. "192.168.1.18:8888" or "http://192.168.1.18:8888".
  final String host;
  final http.Client _http;

  TuneClient(this.host, {http.Client? client}) : _http = client ?? http.Client();

  String get baseUrl {
    var h = host.trim();
    if (h.isEmpty) return '';
    if (!h.startsWith('http://') && !h.startsWith('https://')) {
      h = 'http://$h';
    }
    h = h.replaceAll(RegExp(r'/+$'), '');
    return '$h/api/v1';
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<dynamic> _get(String path) async {
    final r = await _http
        .get(_uri(path), headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));
    if (r.statusCode != 200) {
      throw TuneException('GET $path → ${r.statusCode}', r.statusCode);
    }
    final body = r.body.trimLeft();
    if (body.startsWith('<')) {
      throw TuneException('GET $path returned HTML, not JSON', 200);
    }
    return body.isEmpty ? null : jsonDecode(body);
  }

  Future<dynamic> _post(String path, [Map<String, dynamic>? body]) async {
    final r = await _http
        .post(_uri(path),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: jsonEncode(body ?? const {}))
        .timeout(const Duration(seconds: 20));
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw TuneException('POST $path → ${r.statusCode}: ${r.body}', r.statusCode);
    }
    return r.body.isEmpty ? null : jsonDecode(r.body);
  }

  Future<void> _delete(String path) async {
    final r = await _http.delete(_uri(path)).timeout(const Duration(seconds: 20));
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw TuneException('DELETE $path → ${r.statusCode}', r.statusCode);
    }
  }

  Future<void> _patch(String path, Map<String, dynamic> body) async {
    final r = await _http
        .patch(_uri(path),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw TuneException('PATCH $path → ${r.statusCode}: ${r.body}', r.statusCode);
    }
  }

  Future<void> _put(String path, Map<String, dynamic> body) async {
    final r = await _http
        .put(_uri(path),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw TuneException('PUT $path → ${r.statusCode}: ${r.body}', r.statusCode);
    }
  }

  // ── Health / services ──────────────────────────────────────────────
  Future<bool> ping() async {
    try {
      await _get('/system/health');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Log in to a credential-based service (e.g. Qobuz): POST /streaming/{s}/auth
  /// with {username, password}. Returns the auth response.
  Future<Map<String, dynamic>> authCredentials(
      String service, String username, String password) async {
    final d = await _post('/streaming/$service/auth',
        {'username': username, 'password': password});
    return (d as Map<String, dynamic>?) ?? const {};
  }

  /// Start an OAuth / device-code flow (e.g. Tidal, Spotify): POST with no body.
  /// Returns {verification_url, user_code, authenticated, ...}.
  Future<Map<String, dynamic>> authOAuth(String service) async {
    final d = await _post('/streaming/$service/auth');
    return (d as Map<String, dynamic>?) ?? const {};
  }

  Future<void> disconnectService(String service) =>
      _post('/streaming/$service/disconnect');

  Future<void> enableService(String service) =>
      _post('/streaming/$service/enable');

  Future<void> disableService(String service) =>
      _post('/streaming/$service/disable');

  Future<Map<String, StreamingServiceInfo>> streamingServices() async {
    final d = await _get('/streaming/services') as Map<String, dynamic>;
    return d.map((k, v) =>
        MapEntry(k, StreamingServiceInfo.fromJson(k, v as Map<String, dynamic>)));
  }

  // ── Search (federated) ─────────────────────────────────────────────
  /// [sources] restricts the search to specific services (e.g. ['qobuz']).
  /// null/empty = federated across every enabled source.
  Future<FederatedResults> search(String query,
      {int limit = 25, List<String>? sources}) async {
    var path = '/search?q=${Uri.encodeQueryComponent(query)}&limit=$limit';
    if (sources != null && sources.isNotEmpty) {
      path += '&sources=${sources.join(',')}';
    }
    final d = await _get(path) as Map<String, dynamic>;
    return FederatedResults.fromJson(d);
  }

  // ── Playlists ──────────────────────────────────────────────────────
  Future<List<Playlist>> streamingPlaylists(String service) async {
    final d = await _get('/streaming/$service/playlists') as List;
    return d
        .whereType<Map<String, dynamic>>()
        .map((m) => Playlist.fromJson(m, source: service))
        .toList();
  }

  Future<List<Track>> streamingPlaylistTracks(
      String service, String playlistId) async {
    final d = await _get('/streaming/$service/playlists/$playlistId/tracks')
        as List;
    return d
        .whereType<Map<String, dynamic>>()
        .map((m) => Track.fromJson(m, source: service))
        .toList();
  }

  Future<List<Album>> streamingArtistAlbums(String service, String artistId) async {
    final d = await _get('/streaming/$service/artists/$artistId/albums') as List;
    return d
        .whereType<Map<String, dynamic>>()
        .map((m) => Album.fromJson(m, source: service))
        .toList();
  }

  Future<List<Track>> streamingAlbumTracks(String service, String albumId) async {
    final d = await _get('/streaming/$service/albums/$albumId/tracks') as List;
    return d
        .whereType<Map<String, dynamic>>()
        .map((m) => Track.fromJson(m, source: service))
        .toList();
  }

  /// Single track detail (used to resolve album/artist IDs from now-playing).
  Future<Track> streamingTrack(String service, String trackId) async {
    final d = await _get('/streaming/$service/tracks/$trackId')
        as Map<String, dynamic>;
    return Track.fromJson(d, source: service);
  }

  /// Single album detail — carries artist_id (Qobuz tracks don't).
  Future<Album> streamingAlbum(String service, String albumId) async {
    final d = await _get('/streaming/$service/albums/$albumId')
        as Map<String, dynamic>;
    return Album.fromJson(d, source: service);
  }

  /// Discovery context (genre + label) resolved from an album (Qobuz).
  Future<AlbumContext> albumContext(String service, String albumId) async {
    final d = await _get('/streaming/$service/albums/$albumId/context')
        as Map<String, dynamic>;
    return AlbumContext.fromJson(d);
  }

  /// A record label's full album catalogue, resolved from one of its albums.
  Future<({String name, List<Album> albums})> albumLabel(
      String service, String albumId) async {
    final d = await _get('/streaming/$service/albums/$albumId/label')
        as Map<String, dynamic>;
    final albums = (d['albums'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((m) => Album.fromJson(m, source: service))
        .toList();
    return (name: (d['name'] as String?) ?? '', albums: albums);
  }

  /// Curated/editorial ("expert") playlists, optionally filtered by genre/tag.
  Future<List<Playlist>> featuredPlaylists(String service,
      {String? genre, String? tag}) async {
    final q = <String>[
      if (genre != null && genre.isNotEmpty)
        'genre=${Uri.encodeQueryComponent(genre)}',
      if (tag != null && tag.isNotEmpty) 'tag=${Uri.encodeQueryComponent(tag)}',
    ];
    final path = '/streaming/$service/featured-playlists'
        '${q.isEmpty ? '' : '?${q.join('&')}'}';
    final d = await _get(path) as List;
    return d
        .whereType<Map<String, dynamic>>()
        .map((m) => Playlist.fromJson(m, source: service))
        .toList();
  }

  // ── Local library (source == 'local') ──────────────────────────────
  // Local content lives under /library and is referenced by integer IDs,
  // NOT by a streaming service (there is no "local" service in the registry).
  Future<List<Track>> localAlbumTracks(String albumId) async {
    final d = await _get('/library/albums/$albumId/tracks') as List;
    return d
        .whereType<Map<String, dynamic>>()
        .map((m) => Track.fromJson(m, source: 'local'))
        .toList();
  }

  Future<List<Album>> localArtistAlbums(String artistId) async {
    final d = await _get('/library/artists/$artistId/albums') as List;
    return d
        .whereType<Map<String, dynamic>>()
        .map((m) => Album.fromJson(m, source: 'local'))
        .toList();
  }

  /// Play local tracks by integer ID. A single /play call with the full list
  /// queues them all and starts the first (local uses track_ids).
  Future<void> playLocalTracks(int zoneId, List<int> trackIds) =>
      _post('/zones/$zoneId/play', {'track_ids': trackIds});

  Future<List<Playlist>> localPlaylists() async {
    final d = await _get('/playlists') as List;
    return d
        .whereType<Map<String, dynamic>>()
        .map((m) => Playlist.fromJson(m, source: 'local'))
        .toList();
  }

  Future<List<Track>> localPlaylistTracks(String id) async {
    final d = await _get('/playlists/$id/tracks') as List;
    return d
        .whereType<Map<String, dynamic>>()
        .map((m) => Track.fromJson(m, source: 'local'))
        .toList();
  }

  // ── Playlist creation / editing ────────────────────────────────────
  /// Create a local playlist → returns its id.
  Future<String> createLocalPlaylist(String name, {String? description}) async {
    final d = await _post('/playlists', {
      'name': name,
      if (description != null && description.isNotEmpty) 'description': description,
    }) as Map<String, dynamic>;
    return d['id'].toString();
  }

  /// Add local tracks (integer IDs) to a local playlist.
  Future<void> addLocalPlaylistTracks(String playlistId, List<int> trackIds) =>
      _post('/playlists/$playlistId/tracks', {'track_ids': trackIds})
          .then((_) {});

  /// Create a streaming-service playlist (e.g. Qobuz) → returns its id.
  Future<String> createStreamingPlaylist(String service, String name,
      {String? description}) async {
    final d = await _post('/streaming/$service/playlists', {
      'name': name,
      if (description != null && description.isNotEmpty) 'description': description,
    }) as Map<String, dynamic>;
    return d['id'].toString();
  }

  /// Add streaming tracks (string IDs) to a streaming playlist.
  Future<void> addStreamingPlaylistTracks(
          String service, String playlistId, List<String> trackIds) =>
      _post('/streaming/$service/playlists/$playlistId/tracks',
          {'track_ids': trackIds}).then((_) {});

  Future<void> deleteLocalPlaylist(String id) => _delete('/playlists/$id');

  Future<void> deleteStreamingPlaylist(String service, String id) =>
      _delete('/streaming/$service/playlists/$id');

  /// Remove a local playlist track by its position (0-based index).
  Future<void> removeLocalPlaylistTrack(String playlistId, int position) =>
      _post('/playlists/$playlistId/tracks/remove', {'position': position})
          .then((_) {});

  /// Remove streaming tracks by their source IDs (backend resolves them).
  Future<void> removeStreamingPlaylistTracks(
          String service, String playlistId, List<String> trackIds) =>
      _post('/streaming/$service/playlists/$playlistId/tracks/remove',
          {'track_ids': trackIds}).then((_) {});

  /// Dynamic ("smart") playlists — rule-based local library lists.
  Future<List<Playlist>> smartPlaylists() async {
    final d = await _get('/library/smart-playlists') as List;
    return d.whereType<Map<String, dynamic>>().map((m) => Playlist(
          id: m['id'].toString(),
          name: (m['name'] ?? '').toString(),
          source: 'smart',
          trackCount: (m['max_tracks'] as num?)?.toInt(),
        )).toList();
  }

  Future<List<Track>> smartPlaylistTracks(String id) async {
    final d = await _get('/library/smart-playlists/$id/tracks') as List;
    return d
        .whereType<Map<String, dynamic>>()
        .map((m) => Track.fromJson(m, source: 'local'))
        .toList();
  }

  // ── Favorites ──────────────────────────────────────────────────────
  /// type: 'tracks' | 'albums' | 'artists' | 'playlists'
  Future<List<Map<String, dynamic>>> favorites(String service, String type) async {
    final d = await _get('/streaming/$service/favorites/$type');
    if (d is List) return d.whereType<Map<String, dynamic>>().toList();
    if (d is Map<String, dynamic>) {
      final items = d['items'] ?? d[type];
      if (items is List) return items.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  // Add/remove put item_id in the PATH (POST/DELETE), per the backend routes.
  // fav_type ∈ tracks | albums | artists.
  Future<void> addFavorite(String service, String type, String itemId) => _post(
      '/streaming/$service/favorites/$type/${Uri.encodeComponent(itemId)}');

  Future<void> removeFavorite(String service, String type, String itemId) =>
      _delete(
          '/streaming/$service/favorites/$type/${Uri.encodeComponent(itemId)}');

  // ── Local library favorites (profile-scoped) ───────────────────────
  // Local favorites live in the `favorites` table keyed by the active profile,
  // with SINGULAR item types ('track'|'album'|'artist'). They are separate
  // from the per-streaming-service favorites above.
  Future<int> activeProfileId() async {
    try {
      final d = await _get('/profiles/active') as Map<String, dynamic>;
      return (d['active_profile_id'] as num?)?.toInt() ?? 1;
    } catch (_) {
      return 1;
    }
  }

  /// [type] is singular: 'track' | 'album' | 'artist'.
  Future<List<int>> localFavoriteIds(int profileId, String type) async {
    final d = await _get('/profiles/$profileId/favorites?item_type=$type') as List;
    return d
        .whereType<Map<String, dynamic>>()
        .map((m) => (m['item_id'] as num?)?.toInt())
        .whereType<int>()
        .toList();
  }

  Future<void> addLocalFavorite(int profileId, String type, int itemId) =>
      _post('/profiles/$profileId/favorites/add',
          {'item_type': type, 'item_id': itemId});

  Future<void> removeLocalFavorite(int profileId, String type, int itemId) =>
      _post('/profiles/$profileId/favorites/remove',
          {'item_type': type, 'item_id': itemId});

  Future<Track> localTrackById(int id) async {
    final d = await _get('/library/tracks/$id') as Map<String, dynamic>;
    return Track.fromJson(d, source: 'local');
  }

  Future<Album> localAlbumById(int id) async {
    final d = await _get('/library/albums/$id') as Map<String, dynamic>;
    return Album.fromJson(d, source: 'local');
  }

  Future<Artist> localArtistById(int id) async {
    final d = await _get('/library/artists/$id') as Map<String, dynamic>;
    return Artist.fromJson(d, source: 'local');
  }

  // ── Zones / outputs ────────────────────────────────────────────────
  Future<List<Zone>> zones() async {
    final d = await _get('/zones') as List;
    return d.whereType<Map<String, dynamic>>().map(Zone.fromJson).toList();
  }

  Future<List<Device>> devices() async {
    final d = await _get('/devices') as List;
    return d.whereType<Map<String, dynamic>>().map(Device.fromJson).toList();
  }

  /// Toggle gapless playback for a zone — PATCH /zones/{id}.
  Future<void> setZoneGapless(int zoneId, bool enabled) =>
      _patch('/zones/$zoneId', {'gapless_enabled': enabled});

  /// Patch arbitrary zone fields (autoplay_enabled, volume, max_sample_rate…).
  Future<void> patchZone(int zoneId, Map<String, dynamic> body) =>
      _patch('/zones/$zoneId', body);

  /// Remember a zone as the server's default output.
  Future<void> setDefaultZone(int zoneId) =>
      _put('/system/settings/default-zone', {'zone_id': zoneId});

  // ── Streaming quality cap (global, /system/config) ─────────────────
  Future<StreamConfig> streamConfig() async {
    final d = await _get('/system/config') as Map<String, dynamic>;
    return StreamConfig.fromJson(d);
  }

  Future<void> setStreamQuality(int sampleRate, int bitDepth) => _patch(
      '/system/config',
      {'max_sample_rate': sampleRate, 'max_bit_depth': bitDepth});

  // ── Local library: music folders + scan ────────────────────────────
  Future<List<String>> musicDirs() async {
    final d = await _get('/system/music-dirs') as Map<String, dynamic>;
    return (d['dirs'] as List? ?? const []).map((e) => e.toString()).toList();
  }

  Future<List<String>> addMusicDir(String path) async {
    final d = await _post('/system/music-dirs/add', {'path': path})
        as Map<String, dynamic>;
    return (d['dirs'] as List? ?? const []).map((e) => e.toString()).toList();
  }

  Future<List<String>> removeMusicDir(String path) async {
    final d = await _post('/system/music-dirs/remove', {'path': path})
        as Map<String, dynamic>;
    return (d['dirs'] as List? ?? const []).map((e) => e.toString()).toList();
  }

  Future<void> startScan() => _post('/system/scan').then((_) {});

  Future<Map<String, dynamic>> scanStatus() async {
    final d = await _get('/system/scan/status');
    return (d as Map<String, dynamic>?) ?? const {};
  }

  /// Browse the server's filesystem. Returns {dirs:[{name,path,has_children}],
  /// parent, current}. [path] null starts from the server's default base.
  Future<Map<String, dynamic>> browseDirs(String? path) async {
    final q = (path == null || path.isEmpty)
        ? ''
        : '?path=${Uri.encodeQueryComponent(path)}';
    final d = await _get('/system/browse-dirs$q');
    return (d as Map<String, dynamic>?) ?? const {};
  }

  // ── Metadata fields ────────────────────────────────────────────────
  Future<List<MetadataCategory>> metadataFields() async {
    final d = await _get('/system/settings/metadata-fields')
        as Map<String, dynamic>;
    return (d['categories'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(MetadataCategory.fromJson)
        .toList();
  }

  /// PUT body shape is `{fields: [<enabled key strings>]}`.
  Future<void> setMetadataFields(List<String> enabledKeys) =>
      _put('/system/settings/metadata-fields', {'fields': enabledKeys});

  /// Change a zone's output (renderer) — POST /zone-manager/zones/{id}/hot-swap.
  Future<void> setZoneOutput(int zoneId, String outputType, {String? deviceId}) =>
      _post('/zone-manager/zones/$zoneId/hot-swap', {
        'output_type': outputType,
        if (deviceId != null) 'output_device_id': deviceId,
      });

  // ── Playback ───────────────────────────────────────────────────────
  Future<void> playStreamingTrack(int zoneId, String source, String sourceId) =>
      _post('/zones/$zoneId/play', {'source': source, 'source_id': sourceId});

  Future<void> pauseZone(int zoneId) => _post('/zones/$zoneId/pause').then((_) {});
  Future<void> resumeZone(int zoneId) => _post('/zones/$zoneId/resume').then((_) {});
  Future<void> nextZone(int zoneId) => _post('/zones/$zoneId/next').then((_) {});
  Future<void> previousZone(int zoneId) =>
      _post('/zones/$zoneId/previous').then((_) {});
  Future<void> stopZone(int zoneId) => _post('/zones/$zoneId/stop').then((_) {});
  Future<void> seekZone(int zoneId, int positionMs) =>
      _post('/zones/$zoneId/seek', {'position_ms': positionMs}).then((_) {});

  Future<void> clearQueue(int zoneId) => _delete('/zones/$zoneId/queue/clear');

  Future<void> addToQueue(int zoneId, String source, String sourceId) =>
      _post('/zones/$zoneId/queue/add', {'source': source, 'source_id': sourceId});

  /// Play a list of streaming tracks starting at [startIndex], preserving order.
  Future<void> playTracks(int zoneId, List<Track> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;
    final start = startIndex.clamp(0, tracks.length - 1);
    final first = tracks[start];
    await playStreamingTrack(zoneId, first.source, first.sourceId);
    // Append the rest in playback order from the start track.
    final order = <int>[
      for (var i = start + 1; i < tracks.length; i++) i,
      for (var i = 0; i < start; i++) i,
    ];
    for (final i in order) {
      try {
        await addToQueue(zoneId, tracks[i].source, tracks[i].sourceId);
      } catch (_) {}
    }
  }

  void close() => _http.close();
}

class TuneException implements Exception {
  final String message;
  final int statusCode;
  TuneException(this.message, this.statusCode);
  @override
  String toString() => message;
}
