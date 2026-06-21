// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLIt extends AppL {
  AppLIt([String locale = 'it']) : super(locale);

  @override
  String get genre => 'Genere';

  @override
  String get label => 'Etichetta';

  @override
  String get expertPlaylists => 'Playlist degli esperti';

  @override
  String get navSearch => 'Cerca';

  @override
  String get navPlaylists => 'Playlist';

  @override
  String get navFavorites => 'Preferiti';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get loading => 'Caricamento…';

  @override
  String errorWith(String msg) {
    return 'Errore: $msg';
  }

  @override
  String get notConnected => 'Configura il server nelle Impostazioni';

  @override
  String get playAll => 'Riproduci tutto';

  @override
  String get noTracks => 'Nessun brano';

  @override
  String get searchTitle => 'Cerca';

  @override
  String get searchHint => 'Titolo, album, artista…';

  @override
  String get filterAll => 'Tutto';

  @override
  String get searchEmptyTitle => 'Cerca un titolo, un album o un artista';

  @override
  String get searchEmptySub => 'Qobuz · YouTube · la tua libreria';

  @override
  String get noResults => 'Nessun risultato';

  @override
  String get sectionArtists => 'Artisti';

  @override
  String get sectionAlbums => 'Album';

  @override
  String get sectionPlaylists => 'Playlist';

  @override
  String get sectionTracks => 'Brani';

  @override
  String get sourceLibrary => 'Libreria';

  @override
  String get playlistsTitle => 'Playlist';

  @override
  String get dynamicPlaylists => 'Playlist dinamiche';

  @override
  String get dynamicTag => 'Dinamica';

  @override
  String tracksCount(int n) {
    return '$n brani';
  }

  @override
  String maxTracks(int n) {
    return 'max $n';
  }

  @override
  String get noPlaylists => 'Nessuna playlist';

  @override
  String get favoritesTitle => 'Preferiti';

  @override
  String get tabArtists => 'Artisti';

  @override
  String get tabAlbums => 'Album';

  @override
  String get tabTracks => 'Brani';

  @override
  String get noFavArtists => 'Nessun artista preferito';

  @override
  String get noFavAlbums => 'Nessun album preferito';

  @override
  String get noFavTracks => 'Nessun brano preferito';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get server => 'Server';

  @override
  String get host => 'Host';

  @override
  String get port => 'Porta';

  @override
  String get connect => 'Connetti';

  @override
  String get connected => 'Connesso';

  @override
  String get disconnected => 'Non connesso';

  @override
  String get audioOutput => 'Uscita audio';

  @override
  String get audioOutputDesc =>
      'Ogni zona del server è un\'uscita (ALSA locale, renderer Diretta…). Scegli la zona su cui riprodurre.';

  @override
  String get noZones => 'Nessuna zona disponibile';

  @override
  String get gapless => 'Riproduzione senza pause';

  @override
  String get gaplessDesc =>
      'Disattiva se senti rumore bianco / interruzioni tra i brani su questo renderer.';

  @override
  String get metadataFields => 'Campi metadati';

  @override
  String get metadataFieldsDesc => 'Info mostrate per la libreria locale';

  @override
  String get streamingQuality => 'Qualità streaming';

  @override
  String get streamingQualityDesc =>
      'Limita la frequenza / risoluzione richiesta ai servizi (Qobuz, Tidal…).';

  @override
  String get freqLimit => 'Limite di frequenza';

  @override
  String get qualityMax => 'Massima';

  @override
  String get qualityHires => 'Hi-Res (fino a 192 kHz)';

  @override
  String get qualityCd => 'CD (44.1 kHz / 16 bit)';

  @override
  String get maxFrequency => 'Frequenza max';

  @override
  String get maxBitDepth => 'Profondità max';

  @override
  String get noLimit => 'Nessun limite';

  @override
  String get streamingServices => 'Servizi di streaming';

  @override
  String get language => 'Lingua';

  @override
  String get systemLanguage => 'Sistema';

  @override
  String get nothingPlaying => 'Niente in riproduzione';

  @override
  String get visualizer => 'Visualizzatore';

  @override
  String get cover => 'Copertina';

  @override
  String get addFavorite => 'Aggiungi ai preferiti';

  @override
  String get removeFavorite => 'Rimuovi dai preferiti';

  @override
  String favError(String msg) {
    return 'Preferito non riuscito: $msg';
  }

  @override
  String get metadataTitle => 'Campi metadati';

  @override
  String get metadataSaved => 'Metadati salvati';

  @override
  String get localLibrary => 'Libreria locale';

  @override
  String get localLibraryDesc => 'Cartelle in cui il server cerca la musica';

  @override
  String get musicFolders => 'Cartelle scansionate';

  @override
  String get addFolder => 'Aggiungi una cartella';

  @override
  String get noFolders => 'Nessuna cartella configurata';

  @override
  String get runScan => 'Scansiona libreria';

  @override
  String get scanning => 'Scansione…';

  @override
  String get pickFolder => 'Scegli una cartella';

  @override
  String get addThisFolder => 'Aggiungi questa cartella';

  @override
  String get createPlaylist => 'Crea una playlist';

  @override
  String get playlistName => 'Nome della playlist';

  @override
  String get create => 'Crea';

  @override
  String get addToPlaylist => 'Aggiungi a una playlist';

  @override
  String get newPlaylist => 'Nuova playlist';

  @override
  String get playlistCreated => 'Playlist creata';

  @override
  String get addedToPlaylist => 'Aggiunto alla playlist';

  @override
  String get delete => 'Elimina';

  @override
  String get deletePlaylist => 'Elimina playlist';

  @override
  String get deletePlaylistConfirm => 'Eliminare questa playlist?';

  @override
  String get playlistDeleted => 'Playlist eliminata';

  @override
  String get trackRemoved => 'Rimosso dalla playlist';

  @override
  String get removeFromPlaylist => 'Rimuovi dalla playlist';

  @override
  String get logIn => 'Accedi';

  @override
  String get logOut => 'Disconnetti';

  @override
  String get username => 'Nome utente';

  @override
  String get password => 'Password';

  @override
  String get cancel => 'Annulla';

  @override
  String get noService => 'Nessun servizio';

  @override
  String loginTo(String service) {
    return 'Accedi a $service';
  }

  @override
  String get authorizeInBrowser => 'Autorizza l\'accesso nel browser:';

  @override
  String get openAuthPage => 'Apri la pagina di autorizzazione';

  @override
  String get done => 'Ho finito';

  @override
  String get disabled => 'Disattivato';
}
