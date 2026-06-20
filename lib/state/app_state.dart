import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:shared_preferences/shared_preferences.dart';

import '../api/tune_client.dart';
import '../api/models.dart';

class AppState extends ChangeNotifier {
  static const _kHostLegacy = 'host'; // pre host/port split
  static const _kHost = 'server_host';
  static const _kPort = 'server_port';
  static const _kZone = 'zone_id';
  static const _kLocale = 'locale';
  static const defaultPort = 8888;

  String _host = '';
  int _port = defaultPort;
  TuneClient? _client;
  bool _connected = false;
  bool _loading = false;
  String? _error;

  List<Zone> _zones = [];
  List<Device> _devices = [];
  Map<String, StreamingServiceInfo> _services = {};
  int? _currentZoneId;
  Timer? _poll;

  /// Favorite keys: `<source>|<type>|<id>` (type ∈ tracks/albums/artists/playlists).
  final Set<String> _favs = {};

  StreamConfig? _streamCfg;
  StreamConfig? get streamConfig => _streamCfg;

  /// UI language; null = follow the system locale.
  Locale? _locale;
  Locale? get locale => _locale;

  String get serverHost => _host;
  int get serverPort => _port;

  /// Combined "host:port" used by the REST client and the auth signatures.
  String get host => _host.isEmpty ? '' : '$_host:$_port';

  TuneClient? get client => _client;
  bool get connected => _connected;
  bool get loading => _loading;
  String? get error => _error;
  List<Zone> get zones => _zones;

  /// Server origin (host without the /api/v1 suffix), for resolving relative
  /// artwork URLs.
  String? get serverBase {
    final c = _client;
    if (c == null) return null;
    final b = c.baseUrl;
    if (b.isEmpty) return null;
    return b.endsWith('/api/v1') ? b.substring(0, b.length - 7) : b;
  }

  List<Device> get devices => _devices;
  Map<String, StreamingServiceInfo> get services => _services;
  int? get currentZoneId => _currentZoneId;

  Zone? get currentZone {
    for (final z in _zones) {
      if (z.id == _currentZoneId) return z;
    }
    return _zones.isNotEmpty ? _zones.first : null;
  }

  /// The renderers/outputs offered in Settings: discovered devices that can
  /// render audio (DLNA renderers + local outputs).
  List<Device> get outputs => _devices.where((d) => d.isRenderer).toList();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final lc = prefs.getString(_kLocale);
    _locale = (lc != null && lc.isNotEmpty) ? Locale(lc) : null;
    _host = prefs.getString(_kHost) ?? '';
    _port = prefs.getInt(_kPort) ?? defaultPort;
    // Migrate the old combined "host:port" pref if present.
    if (_host.isEmpty) {
      final legacy = prefs.getString(_kHostLegacy);
      if (legacy != null && legacy.isNotEmpty) {
        final p = _parse(legacy);
        _host = p.$1;
        _port = p.$2;
      }
    }
    _currentZoneId = prefs.getInt(_kZone);
    if (_host.isNotEmpty) {
      _client = TuneClient(host);
      await refresh();
    }
    notifyListeners();
  }

  /// Splits user input into (host, port). Strips any scheme; an embedded
  /// `:port` overrides; defaults to [defaultPort].
  (String, int) _parse(String input, [int? fallbackPort]) {
    var s = input.trim().replaceAll(RegExp(r'^https?://'), '');
    s = s.replaceAll(RegExp(r'/.*$'), ''); // drop any path
    var port = fallbackPort ?? defaultPort;
    final colon = s.lastIndexOf(':');
    if (colon >= 0) {
      final maybe = int.tryParse(s.substring(colon + 1));
      if (maybe != null) {
        port = maybe;
        s = s.substring(0, colon);
      }
    }
    return (s, port);
  }

  /// Set the UI language ([code] like 'fr'; null = system).
  Future<void> setLocale(String? code) async {
    _locale = (code != null && code.isNotEmpty) ? Locale(code) : null;
    final prefs = await SharedPreferences.getInstance();
    if (code == null || code.isEmpty) {
      await prefs.remove(_kLocale);
    } else {
      await prefs.setString(_kLocale, code);
    }
    notifyListeners();
  }

  Future<void> setServer(String host, String port) async {
    final parsed = _parse(host, int.tryParse(port.trim()));
    _host = parsed.$1;
    _port = parsed.$2;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kHost, _host);
    await prefs.setInt(_kPort, _port);
    _client?.close();
    _client = _host.isEmpty ? null : TuneClient(this.host);
    await refresh();
  }

  Future<void> refresh() async {
    final c = _client;
    if (c == null) {
      _connected = false;
      notifyListeners();
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _connected = await c.ping();
      if (_connected) {
        final results = await Future.wait([
          c.zones(),
          c.devices(),
          c.streamingServices(),
        ]);
        _zones = results[0] as List<Zone>;
        _devices = results[1] as List<Device>;
        _services = results[2] as Map<String, StreamingServiceInfo>;
        if (currentZone != null) _currentZoneId = currentZone!.id;
        _startPolling();
        unawaited(loadFavorites());
        unawaited(loadStreamConfig());
      } else {
        _poll?.cancel();
      }
    } catch (e) {
      _error = e.toString();
      _connected = false;
      _poll?.cancel();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Now-playing polling ────────────────────────────────────────────
  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 2), (_) => _pollZones());
  }

  Future<void> _pollZones() async {
    final c = _client;
    if (c == null || !_connected) return;
    try {
      _zones = await c.zones();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> togglePlay() async {
    final c = _client;
    final z = currentZone;
    if (c == null || z == null) return;
    if (z.isPlaying) {
      await c.pauseZone(z.id);
    } else {
      await c.resumeZone(z.id);
    }
    await _pollZones();
  }

  Future<void> next() async {
    final c = _client;
    final z = currentZone;
    if (c == null || z == null) return;
    await c.nextZone(z.id);
    await _pollZones();
  }

  Future<void> previous() async {
    final c = _client;
    final z = currentZone;
    if (c == null || z == null) return;
    await c.previousZone(z.id);
    await _pollZones();
  }

  Future<void> stopPlayback() async {
    final c = _client;
    final z = currentZone;
    if (c == null || z == null) return;
    await c.stopZone(z.id);
    await _pollZones();
  }

  Future<void> seek(int positionMs) async {
    final c = _client;
    final z = currentZone;
    if (c == null || z == null) return;
    await c.seekZone(z.id, positionMs);
    await _pollZones();
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> setCurrentZone(int id) async {
    _currentZoneId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kZone, id);
    notifyListeners();
    // Remember it server-side too, so reconnects default to this output.
    try {
      await _client?.setDefaultZone(id);
    } catch (_) {}
  }

  /// Choose the playback output: hot-swap the current zone to [device].
  Future<void> setOutput(Device device) async {
    final c = _client;
    final z = currentZone;
    if (c == null || z == null) return;
    await c.setZoneOutput(z.id, device.type, deviceId: device.id);
    await refresh();
  }

  // ── Favorites ──────────────────────────────────────────────────────
  String _favKey(String source, String type, String id) => '$source|$type|$id';

  bool isFavorite(String source, String type, String id) =>
      _favs.contains(_favKey(source, type, id));

  /// Load every authenticated service's favorite IDs into [_favs].
  Future<void> loadFavorites() async {
    final c = _client;
    if (c == null || !_connected) return;
    final keys = <String>{};
    for (final s in _services.values) {
      if (!(s.enabled && s.authenticated)) continue;
      final svc = s.name;
      for (final type in const ['tracks', 'albums', 'artists']) {
        try {
          final items = await c.favorites(svc, type);
          for (final m in items) {
            final id = (m['source_id'] ?? m['id'] ?? m['artist_id'])?.toString();
            if (id != null && id.isNotEmpty) keys.add(_favKey(svc, type, id));
          }
        } catch (_) {}
      }
    }
    _favs
      ..clear()
      ..addAll(keys);
    notifyListeners();
  }

  /// Add or remove a favorite (optimistic, reverts on error).
  Future<void> toggleFavorite(String source, String type, String id) async {
    final c = _client;
    if (c == null || source.isEmpty || source == 'local' || source == 'smart' || id.isEmpty) {
      return;
    }
    final key = _favKey(source, type, id);
    final was = _favs.contains(key);
    if (was) {
      _favs.remove(key);
    } else {
      _favs.add(key);
    }
    notifyListeners();
    try {
      if (was) {
        await c.removeFavorite(source, type, id);
      } else {
        await c.addFavorite(source, type, id);
      }
    } catch (e) {
      if (was) {
        _favs.add(key);
      } else {
        _favs.remove(key);
      }
      notifyListeners();
      rethrow;
    }
  }

  // ── Zone settings (current zone) ───────────────────────────────────
  Future<void> _patchCurrentZone(Map<String, dynamic> body) async {
    final c = _client;
    final z = currentZone;
    if (c == null || z == null) return;
    await c.patchZone(z.id, body);
    await _pollZones(); // reload zones to reflect the new value
  }

  Future<void> setGapless(bool enabled) =>
      _patchCurrentZone({'gapless_enabled': enabled});

  // ── Streaming quality cap ──────────────────────────────────────────
  Future<void> loadStreamConfig() async {
    final c = _client;
    if (c == null || !_connected) return;
    try {
      _streamCfg = await c.streamConfig();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setStreamQuality(int sampleRate, int bitDepth) async {
    final c = _client;
    if (c == null) return;
    await c.setStreamQuality(sampleRate, bitDepth);
    await loadStreamConfig();
  }

  // ── Playback helpers (target the current zone) ─────────────────────
  Future<void> playTrack(Track t) async {
    final c = _client;
    final z = currentZone;
    if (c == null || z == null) throw Exception('Aucune zone/sortie sélectionnée');
    await c.playStreamingTrack(z.id, t.source, t.sourceId);
    await _pollZones();
  }

  Future<void> playTracks(List<Track> tracks, {int startIndex = 0}) async {
    final c = _client;
    final z = currentZone;
    if (c == null || z == null) throw Exception('Aucune zone/sortie sélectionnée');
    await c.playTracks(z.id, tracks, startIndex: startIndex);
    await _pollZones();
  }

  Future<void> playAlbum(Album a) async {
    final c = _client;
    final z = currentZone;
    if (c == null || z == null) throw Exception('Aucune zone/sortie sélectionnée');
    final tracks = await c.streamingAlbumTracks(a.source, a.sourceId);
    await c.playTracks(z.id, tracks);
    await _pollZones();
  }
}
