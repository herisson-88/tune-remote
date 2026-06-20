// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLEn extends AppL {
  AppLEn([String locale = 'en']) : super(locale);

  @override
  String get navSearch => 'Search';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navSettings => 'Settings';

  @override
  String get loading => 'Loading…';

  @override
  String errorWith(String msg) {
    return 'Error: $msg';
  }

  @override
  String get notConnected => 'Set up the server in Settings';

  @override
  String get playAll => 'Play all';

  @override
  String get noTracks => 'No tracks';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Title, album, artist…';

  @override
  String get filterAll => 'All';

  @override
  String get searchEmptyTitle => 'Search a title, an album or an artist';

  @override
  String get searchEmptySub => 'Qobuz · YouTube · your library';

  @override
  String get noResults => 'No results';

  @override
  String get sectionArtists => 'Artists';

  @override
  String get sectionAlbums => 'Albums';

  @override
  String get sectionPlaylists => 'Playlists';

  @override
  String get sectionTracks => 'Tracks';

  @override
  String get sourceLibrary => 'Library';

  @override
  String get playlistsTitle => 'Playlists';

  @override
  String get dynamicPlaylists => 'Dynamic playlists';

  @override
  String get dynamicTag => 'Dynamic';

  @override
  String tracksCount(int n) {
    return '$n tracks';
  }

  @override
  String maxTracks(int n) {
    return 'max $n';
  }

  @override
  String get noPlaylists => 'No playlist';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get tabArtists => 'Artists';

  @override
  String get tabAlbums => 'Albums';

  @override
  String get tabTracks => 'Tracks';

  @override
  String get noFavArtists => 'No favorite artist';

  @override
  String get noFavAlbums => 'No favorite album';

  @override
  String get noFavTracks => 'No favorite track';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get server => 'Server';

  @override
  String get host => 'Host';

  @override
  String get port => 'Port';

  @override
  String get connect => 'Connect';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get audioOutput => 'Audio output';

  @override
  String get audioOutputDesc =>
      'Each server zone is one output (local ALSA, Diretta renderer…). Pick the zone to play on.';

  @override
  String get noZones => 'No zone available';

  @override
  String get gapless => 'Gapless playback';

  @override
  String get gaplessDesc =>
      'Disable if you hear white noise / glitches between tracks on this renderer.';

  @override
  String get metadataFields => 'Metadata fields';

  @override
  String get metadataFieldsDesc => 'Info shown for the local library';

  @override
  String get streamingQuality => 'Streaming quality';

  @override
  String get streamingQualityDesc =>
      'Caps the frequency / resolution requested from services (Qobuz, Tidal…).';

  @override
  String get freqLimit => 'Frequency limit';

  @override
  String get qualityMax => 'Maximum';

  @override
  String get qualityHires => 'Hi-Res (up to 192 kHz)';

  @override
  String get qualityCd => 'CD (44.1 kHz / 16 bit)';

  @override
  String get maxFrequency => 'Max frequency';

  @override
  String get maxBitDepth => 'Max bit depth';

  @override
  String get noLimit => 'No limit';

  @override
  String get streamingServices => 'Streaming services';

  @override
  String get language => 'Language';

  @override
  String get systemLanguage => 'System';

  @override
  String get nothingPlaying => 'Nothing playing';

  @override
  String get visualizer => 'Visualizer';

  @override
  String get cover => 'Cover';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String favError(String msg) {
    return 'Favorite failed: $msg';
  }

  @override
  String get metadataTitle => 'Metadata fields';

  @override
  String get metadataSaved => 'Metadata saved';

  @override
  String get logIn => 'Log in';

  @override
  String get logOut => 'Log out';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get cancel => 'Cancel';

  @override
  String get noService => 'No service';

  @override
  String loginTo(String service) {
    return 'Sign in to $service';
  }

  @override
  String get authorizeInBrowser => 'Authorize access in your browser:';

  @override
  String get openAuthPage => 'Open the authorization page';

  @override
  String get done => 'I\'m done';

  @override
  String get disabled => 'Disabled';
}
