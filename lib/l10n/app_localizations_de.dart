// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLDe extends AppL {
  AppLDe([String locale = 'de']) : super(locale);

  @override
  String get navSearch => 'Suche';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navFavorites => 'Favoriten';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get loading => 'Lädt…';

  @override
  String errorWith(String msg) {
    return 'Fehler: $msg';
  }

  @override
  String get notConnected => 'Server in den Einstellungen einrichten';

  @override
  String get playAll => 'Alle abspielen';

  @override
  String get noTracks => 'Keine Titel';

  @override
  String get searchTitle => 'Suche';

  @override
  String get searchHint => 'Titel, Album, Künstler…';

  @override
  String get filterAll => 'Alle';

  @override
  String get searchEmptyTitle =>
      'Suche einen Titel, ein Album oder einen Künstler';

  @override
  String get searchEmptySub => 'Qobuz · YouTube · deine Bibliothek';

  @override
  String get noResults => 'Keine Ergebnisse';

  @override
  String get sectionArtists => 'Künstler';

  @override
  String get sectionAlbums => 'Alben';

  @override
  String get sectionPlaylists => 'Playlists';

  @override
  String get sectionTracks => 'Titel';

  @override
  String get sourceLibrary => 'Bibliothek';

  @override
  String get playlistsTitle => 'Playlists';

  @override
  String get dynamicPlaylists => 'Dynamische Playlists';

  @override
  String get dynamicTag => 'Dynamisch';

  @override
  String tracksCount(int n) {
    return '$n Titel';
  }

  @override
  String maxTracks(int n) {
    return 'max. $n';
  }

  @override
  String get noPlaylists => 'Keine Playlist';

  @override
  String get favoritesTitle => 'Favoriten';

  @override
  String get tabArtists => 'Künstler';

  @override
  String get tabAlbums => 'Alben';

  @override
  String get tabTracks => 'Titel';

  @override
  String get noFavArtists => 'Keine Lieblingskünstler';

  @override
  String get noFavAlbums => 'Keine Lieblingsalben';

  @override
  String get noFavTracks => 'Keine Lieblingstitel';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get server => 'Server';

  @override
  String get host => 'Host';

  @override
  String get port => 'Port';

  @override
  String get connect => 'Verbinden';

  @override
  String get connected => 'Verbunden';

  @override
  String get disconnected => 'Nicht verbunden';

  @override
  String get audioOutput => 'Audioausgang';

  @override
  String get audioOutputDesc =>
      'Jede Serverzone ist ein Ausgang (lokales ALSA, Diretta-Renderer…). Wähle die Zone zum Abspielen.';

  @override
  String get noZones => 'Keine Zone verfügbar';

  @override
  String get gapless => 'Lückenlose Wiedergabe';

  @override
  String get gaplessDesc =>
      'Deaktivieren bei Rauschen / Aussetzern zwischen Titeln auf diesem Renderer.';

  @override
  String get metadataFields => 'Metadatenfelder';

  @override
  String get metadataFieldsDesc => 'Für die lokale Bibliothek angezeigte Infos';

  @override
  String get streamingQuality => 'Streaming-Qualität';

  @override
  String get streamingQualityDesc =>
      'Begrenzt die von den Diensten angeforderte Frequenz / Auflösung (Qobuz, Tidal…).';

  @override
  String get freqLimit => 'Frequenzgrenze';

  @override
  String get qualityMax => 'Maximum';

  @override
  String get qualityHires => 'Hi-Res (bis 192 kHz)';

  @override
  String get qualityCd => 'CD (44.1 kHz / 16 Bit)';

  @override
  String get maxFrequency => 'Max. Frequenz';

  @override
  String get maxBitDepth => 'Max. Bit-Tiefe';

  @override
  String get noLimit => 'Ohne Limit';

  @override
  String get streamingServices => 'Streaming-Dienste';

  @override
  String get language => 'Sprache';

  @override
  String get systemLanguage => 'System';

  @override
  String get nothingPlaying => 'Nichts wird abgespielt';

  @override
  String get visualizer => 'Visualisierung';

  @override
  String get cover => 'Cover';

  @override
  String get addFavorite => 'Zu Favoriten hinzufügen';

  @override
  String get removeFavorite => 'Aus Favoriten entfernen';

  @override
  String favError(String msg) {
    return 'Favorit fehlgeschlagen: $msg';
  }

  @override
  String get metadataTitle => 'Metadatenfelder';

  @override
  String get metadataSaved => 'Metadaten gespeichert';

  @override
  String get localLibrary => 'Lokale Bibliothek';

  @override
  String get localLibraryDesc => 'Ordner, die der Server nach Musik durchsucht';

  @override
  String get musicFolders => 'Gescannte Ordner';

  @override
  String get addFolder => 'Ordner hinzufügen';

  @override
  String get noFolders => 'Kein Ordner konfiguriert';

  @override
  String get runScan => 'Bibliothek scannen';

  @override
  String get scanning => 'Scannt…';

  @override
  String get pickFolder => 'Ordner auswählen';

  @override
  String get addThisFolder => 'Diesen Ordner hinzufügen';

  @override
  String get createPlaylist => 'Playlist erstellen';

  @override
  String get playlistName => 'Playlist-Name';

  @override
  String get create => 'Erstellen';

  @override
  String get addToPlaylist => 'Zu einer Playlist hinzufügen';

  @override
  String get newPlaylist => 'Neue Playlist';

  @override
  String get playlistCreated => 'Playlist erstellt';

  @override
  String get addedToPlaylist => 'Zur Playlist hinzugefügt';

  @override
  String get delete => 'Löschen';

  @override
  String get deletePlaylist => 'Playlist löschen';

  @override
  String get deletePlaylistConfirm => 'Diese Playlist löschen?';

  @override
  String get playlistDeleted => 'Playlist gelöscht';

  @override
  String get trackRemoved => 'Aus Playlist entfernt';

  @override
  String get removeFromPlaylist => 'Aus Playlist entfernen';

  @override
  String get logIn => 'Anmelden';

  @override
  String get logOut => 'Abmelden';

  @override
  String get username => 'Benutzername';

  @override
  String get password => 'Passwort';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get noService => 'Kein Dienst';

  @override
  String loginTo(String service) {
    return 'Bei $service anmelden';
  }

  @override
  String get authorizeInBrowser => 'Autorisiere den Zugriff im Browser:';

  @override
  String get openAuthPage => 'Autorisierungsseite öffnen';

  @override
  String get done => 'Fertig';

  @override
  String get disabled => 'Deaktiviert';
}
