/// Data models mapped 1:1 on the tune-server REST API (the same API the
/// working web app uses). Field names follow the backend's snake_case JSON.

String _s(dynamic v) => v == null ? '' : v.toString();

class Quality {
  final int? sampleRate; // Hz
  final int? bitDepth;
  final String? codec;
  Quality({this.sampleRate, this.bitDepth, this.codec});

  factory Quality.fromJson(Map<String, dynamic> j) => Quality(
        sampleRate: (j['sample_rate'] as num?)?.toInt(),
        bitDepth: (j['bit_depth'] as num?)?.toInt(),
        codec: j['codec'] as String?,
      );

  bool get isEmpty => sampleRate == null && bitDepth == null && codec == null;

  String _khz() {
    final khz = sampleRate! / 1000;
    return khz % 1 == 0 ? khz.toStringAsFixed(0) : khz.toStringAsFixed(1);
  }

  String get label {
    final parts = <String>[];
    if (codec != null && codec!.isNotEmpty) parts.add(codec!.toUpperCase());
    if (bitDepth != null) parts.add('$bitDepth bit');
    if (sampleRate != null) parts.add('${_khz()} kHz');
    return parts.join(' · ');
  }

  /// Compact form for list rows, e.g. "24/192".
  String get short {
    final parts = <String>[];
    if (bitDepth != null) parts.add('$bitDepth');
    if (sampleRate != null) parts.add(_khz());
    return parts.join('/');
  }

  /// True for anything above CD quality (16-bit / 44.1 kHz).
  bool get isHiRes =>
      (bitDepth != null && bitDepth! > 16) ||
      (sampleRate != null && sampleRate! > 48000);
}

class Track {
  final String sourceId;
  final String title;
  final String? artistName;
  final String? artistId;
  final String? albumId;
  final String? albumTitle;
  final String? coverPath;
  final int? durationMs;
  final int? trackNumber;
  final Quality? quality;

  /// Streaming service / origin: 'qobuz' | 'youtube' | 'local'.
  final String source;

  Track({
    required this.sourceId,
    required this.title,
    required this.source,
    this.artistName,
    this.artistId,
    this.albumId,
    this.albumTitle,
    this.coverPath,
    this.durationMs,
    this.trackNumber,
    this.quality,
  });

  factory Track.fromJson(Map<String, dynamic> j, {required String source}) =>
      Track(
        // Local "now playing" reports `track_id` (no `id`/`source_id`); local
        // list rows report `id`; streaming rows report `source_id`.
        sourceId: _s(j['source_id'] ?? j['id'] ?? j['track_id']),
        title: _s(j['title'] ?? j['name']),
        source: source,
        artistName: j['artist_name'] as String? ?? j['artist'] as String?,
        artistId: (j['artist_id'] ?? j['artist']?['id'])?.toString(),
        albumId: (j['album_id'] ?? j['album']?['id'])?.toString(),
        albumTitle: j['album_title'] as String? ?? j['album'] as String?,
        coverPath: j['cover_path'] as String? ?? j['cover_url'] as String?,
        durationMs: (j['duration_ms'] as num?)?.toInt(),
        trackNumber: (j['track_number'] as num?)?.toInt(),
        quality: j['quality'] is Map<String, dynamic>
            ? Quality.fromJson(j['quality'] as Map<String, dynamic>)
            : null,
      );

  String get durationLabel {
    final ms = durationMs ?? 0;
    final s = ms ~/ 1000;
    final m = s ~/ 60;
    final r = s % 60;
    return '$m:${r.toString().padLeft(2, '0')}';
  }
}

class Album {
  final String sourceId;
  final String title;
  final String? artistName;
  final String? artistId;
  final String? coverPath;
  final int? trackCount;
  final int? year;
  final String source;

  Album({
    required this.sourceId,
    required this.title,
    required this.source,
    this.artistName,
    this.artistId,
    this.coverPath,
    this.trackCount,
    this.year,
  });

  factory Album.fromJson(Map<String, dynamic> j, {required String source}) =>
      Album(
        sourceId: _s(j['source_id'] ?? j['id']),
        title: _s(j['title'] ?? j['name']),
        source: source,
        artistName: j['artist_name'] as String? ?? j['artist'] as String?,
        artistId: (j['artist_id'] ?? j['artist']?['id'])?.toString(),
        coverPath: j['cover_path'] as String? ?? j['cover_url'] as String?,
        trackCount: (j['track_count'] as num?)?.toInt(),
        year: (j['year'] as num?)?.toInt(),
      );
}

class Artist {
  final String id;
  final String name;
  final String? picture;
  final String source;

  Artist({required this.id, required this.name, required this.source, this.picture});

  factory Artist.fromJson(Map<String, dynamic> j, {required String source}) =>
      Artist(
        id: _s(j['source_id'] ?? j['id'] ?? j['artist_id']),
        name: _s(j['name'] ?? j['artist_name']),
        source: source,
        picture: j['picture'] as String? ??
            j['image_path'] as String? ??
            j['image'] as String? ??
            j['cover_path'] as String?,
      );
}

class Playlist {
  final String id;
  final String name;
  final int? trackCount;
  final String? coverPath;
  final String? description;
  final String? owner;

  /// 'qobuz' | 'youtube' | 'local'
  final String source;

  Playlist({
    required this.id,
    required this.name,
    required this.source,
    this.trackCount,
    this.coverPath,
    this.description,
    this.owner,
  });

  factory Playlist.fromJson(Map<String, dynamic> j, {required String source}) =>
      Playlist(
        id: _s(j['source_id'] ?? j['id']),
        name: _s(j['name'] ?? j['title']),
        source: source,
        trackCount: (j['track_count'] as num?)?.toInt(),
        coverPath: j['cover_path'] as String? ?? j['cover_url'] as String?,
        description: j['description'] as String?,
        owner: j['owner'] as String?,
      );
}

/// Discovery context of the now-playing track: its genre and record label
/// (Qobuz). Lets the full player jump to the genre's expert playlists or the
/// label's album catalogue.
class AlbumContext {
  final String? genreId;
  final String? genreName;
  final String? labelId;
  final String? labelName;

  AlbumContext({this.genreId, this.genreName, this.labelId, this.labelName});

  factory AlbumContext.fromJson(Map<String, dynamic> j) => AlbumContext(
        genreId: j['genre_id']?.toString(),
        genreName: j['genre_name'] as String?,
        labelId: j['label_id']?.toString(),
        labelName: j['label_name'] as String?,
      );

  bool get hasGenre =>
      (genreId ?? '').isNotEmpty && (genreName ?? '').isNotEmpty;
  bool get hasLabel => (labelName ?? '').isNotEmpty;
}

/// One service's slice of search results (or a library section).
class SearchSection {
  final List<Album> albums;
  final List<Artist> artists;
  final List<Track> tracks;
  final List<Playlist> playlists;

  SearchSection({
    this.albums = const [],
    this.artists = const [],
    this.tracks = const [],
    this.playlists = const [],
  });

  bool get isEmpty =>
      albums.isEmpty && artists.isEmpty && tracks.isEmpty && playlists.isEmpty;

  factory SearchSection.fromJson(Map<String, dynamic> j, {required String source}) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) f) =>
        (j[key] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(f)
            .toList();
    return SearchSection(
      albums: list('albums', (m) => Album.fromJson(m, source: source)),
      artists: list('artists', (m) => Artist.fromJson(m, source: source)),
      tracks: list('tracks', (m) => Track.fromJson(m, source: source)),
      playlists: list('playlists', (m) => Playlist.fromJson(m, source: source)),
    );
  }
}

/// GET /search?q= → { local, radios, services: { qobuz, youtube } }
class FederatedResults {
  final SearchSection local;
  final Map<String, SearchSection> services; // 'qobuz', 'youtube', ...

  FederatedResults({required this.local, required this.services});

  factory FederatedResults.fromJson(Map<String, dynamic> j) {
    final svcJson = j['services'] as Map<String, dynamic>? ?? const {};
    return FederatedResults(
      local: SearchSection.fromJson(
          j['local'] as Map<String, dynamic>? ?? const {}, source: 'local'),
      services: svcJson.map((k, v) => MapEntry(
          k, SearchSection.fromJson(v as Map<String, dynamic>, source: k))),
    );
  }
}

class StreamingServiceInfo {
  final String name;
  final bool authenticated;
  final bool enabled;
  final String? username;
  final String? subscription;

  StreamingServiceInfo({
    required this.name,
    required this.authenticated,
    required this.enabled,
    this.username,
    this.subscription,
  });

  factory StreamingServiceInfo.fromJson(String key, Map<String, dynamic> j) =>
      StreamingServiceInfo(
        name: j['name'] as String? ?? key,
        authenticated: j['authenticated'] as bool? ?? false,
        enabled: j['enabled'] as bool? ?? false,
        username: j['username'] as String?,
        subscription: j['subscription'] as String?,
      );
}

/// A discoverable output / renderer (GET /devices).
class Device {
  final String id;
  final String name;
  final String type; // 'dlna' | 'local' | 'openhome' | ...
  final bool available;

  Device({required this.id, required this.name, required this.type, this.available = true});

  factory Device.fromJson(Map<String, dynamic> j) => Device(
        id: _s(j['id']),
        name: _s(j['name']),
        type: _s(j['type']),
        available: j['available'] as bool? ?? true,
      );

  bool get isRenderer => type != 'server' && type != 'media_server';
}

/// A playback zone (GET /zones).
class Zone {
  final int id;
  final String name;
  final String? outputType;
  final String? outputDeviceId;
  final String state; // 'playing' | 'paused' | 'stopped'
  final int positionMs;
  final Track? currentTrack;
  final bool gaplessEnabled;
  final bool autoplayEnabled;
  final double volume; // 0.0 – 1.0
  final bool fixedVolume;
  final int? maxSampleRate; // Hz; null = no limit

  Zone({
    required this.id,
    required this.name,
    this.outputType,
    this.outputDeviceId,
    this.state = 'stopped',
    this.positionMs = 0,
    this.currentTrack,
    this.gaplessEnabled = true,
    this.autoplayEnabled = true,
    this.volume = 1.0,
    this.fixedVolume = false,
    this.maxSampleRate,
  });

  bool get isPlaying => state == 'playing';
  bool get isPaused => state == 'paused';

  factory Zone.fromJson(Map<String, dynamic> j) {
    final ct = j['current_track'];
    return Zone(
      id: (j['id'] as num).toInt(),
      name: _s(j['name']),
      outputType: j['output_type'] as String?,
      outputDeviceId: j['output_device_id'] as String?,
      state: _s(j['state']).isEmpty ? 'stopped' : _s(j['state']),
      positionMs: (j['position_ms'] as num?)?.toInt() ?? 0,
      currentTrack: ct is Map<String, dynamic>
          ? Track.fromJson(ct, source: _s(ct['source']))
          : null,
      gaplessEnabled: j['gapless_enabled'] as bool? ?? true,
      autoplayEnabled: j['autoplay_enabled'] as bool? ?? true,
      volume: (j['volume'] as num?)?.toDouble() ?? 1.0,
      fixedVolume: j['fixed_volume'] as bool? ?? false,
      maxSampleRate: (j['max_sample_rate'] as num?)?.toInt(),
    );
  }
}

/// Streaming quality cap from GET /system/config. Only these two fields are
/// read (the endpoint also returns credentials, which we deliberately ignore).
class StreamConfig {
  final int maxSampleRate; // Hz
  final int maxBitDepth;
  StreamConfig({required this.maxSampleRate, required this.maxBitDepth});

  factory StreamConfig.fromJson(Map<String, dynamic> j) => StreamConfig(
        maxSampleRate: (j['max_sample_rate'] as num?)?.toInt() ?? 192000,
        maxBitDepth: (j['max_bit_depth'] as num?)?.toInt() ?? 24,
      );
}

/// One field within a metadata-fields category (GET /system/settings/metadata-fields).
class MetadataField {
  final String key;
  final String label;
  final bool enabled;
  MetadataField({required this.key, required this.label, required this.enabled});

  factory MetadataField.fromJson(Map<String, dynamic> j) => MetadataField(
        key: _s(j['key']),
        label: _s(j['label']),
        enabled: j['enabled'] as bool? ?? false,
      );
}

class MetadataCategory {
  final String name;
  final List<MetadataField> fields;
  MetadataCategory({required this.name, required this.fields});

  factory MetadataCategory.fromJson(Map<String, dynamic> j) => MetadataCategory(
        name: _s(j['name']),
        fields: (j['fields'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(MetadataField.fromJson)
            .toList(),
      );
}
