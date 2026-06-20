// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLEs extends AppL {
  AppLEs([String locale = 'es']) : super(locale);

  @override
  String get navSearch => 'Buscar';

  @override
  String get navPlaylists => 'Listas';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get loading => 'Cargando…';

  @override
  String errorWith(String msg) {
    return 'Error: $msg';
  }

  @override
  String get notConnected => 'Configura el servidor en Ajustes';

  @override
  String get playAll => 'Reproducir todo';

  @override
  String get noTracks => 'Sin pistas';

  @override
  String get searchTitle => 'Buscar';

  @override
  String get searchHint => 'Título, álbum, artista…';

  @override
  String get filterAll => 'Todo';

  @override
  String get searchEmptyTitle => 'Busca un título, un álbum o un artista';

  @override
  String get searchEmptySub => 'Qobuz · YouTube · tu biblioteca';

  @override
  String get noResults => 'Sin resultados';

  @override
  String get sectionArtists => 'Artistas';

  @override
  String get sectionAlbums => 'Álbumes';

  @override
  String get sectionPlaylists => 'Listas';

  @override
  String get sectionTracks => 'Pistas';

  @override
  String get sourceLibrary => 'Biblioteca';

  @override
  String get playlistsTitle => 'Listas';

  @override
  String get dynamicPlaylists => 'Listas dinámicas';

  @override
  String get dynamicTag => 'Dinámica';

  @override
  String tracksCount(int n) {
    return '$n pistas';
  }

  @override
  String maxTracks(int n) {
    return 'máx. $n';
  }

  @override
  String get noPlaylists => 'Ninguna lista';

  @override
  String get favoritesTitle => 'Favoritos';

  @override
  String get tabArtists => 'Artistas';

  @override
  String get tabAlbums => 'Álbumes';

  @override
  String get tabTracks => 'Pistas';

  @override
  String get noFavArtists => 'Sin artistas favoritos';

  @override
  String get noFavAlbums => 'Sin álbumes favoritos';

  @override
  String get noFavTracks => 'Sin pistas favoritas';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get server => 'Servidor';

  @override
  String get host => 'Host';

  @override
  String get port => 'Puerto';

  @override
  String get connect => 'Conectar';

  @override
  String get connected => 'Conectado';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get audioOutput => 'Salida de audio';

  @override
  String get audioOutputDesc =>
      'Cada zona del servidor es una salida (ALSA local, renderer Diretta…). Elige la zona donde reproducir.';

  @override
  String get noZones => 'Ninguna zona disponible';

  @override
  String get gapless => 'Reproducción sin pausas';

  @override
  String get gaplessDesc =>
      'Desactiva si oyes ruido blanco / cortes entre pistas en este renderer.';

  @override
  String get metadataFields => 'Campos de metadatos';

  @override
  String get metadataFieldsDesc =>
      'Información mostrada para la biblioteca local';

  @override
  String get streamingQuality => 'Calidad de streaming';

  @override
  String get streamingQualityDesc =>
      'Limita la frecuencia / resolución solicitada a los servicios (Qobuz, Tidal…).';

  @override
  String get freqLimit => 'Límite de frecuencia';

  @override
  String get qualityMax => 'Máxima';

  @override
  String get qualityHires => 'Hi-Res (hasta 192 kHz)';

  @override
  String get qualityCd => 'CD (44.1 kHz / 16 bits)';

  @override
  String get maxFrequency => 'Frecuencia máx.';

  @override
  String get maxBitDepth => 'Profundidad máx.';

  @override
  String get noLimit => 'Sin límite';

  @override
  String get streamingServices => 'Servicios de streaming';

  @override
  String get language => 'Idioma';

  @override
  String get systemLanguage => 'Sistema';

  @override
  String get nothingPlaying => 'Nada en reproducción';

  @override
  String get visualizer => 'Visualizador';

  @override
  String get cover => 'Carátula';

  @override
  String get addFavorite => 'Añadir a favoritos';

  @override
  String get removeFavorite => 'Quitar de favoritos';

  @override
  String favError(String msg) {
    return 'Error de favorito: $msg';
  }

  @override
  String get metadataTitle => 'Campos de metadatos';

  @override
  String get metadataSaved => 'Metadatos guardados';

  @override
  String get localLibrary => 'Biblioteca local';

  @override
  String get localLibraryDesc => 'Carpetas donde el servidor busca música';

  @override
  String get musicFolders => 'Carpetas escaneadas';

  @override
  String get addFolder => 'Añadir una carpeta';

  @override
  String get noFolders => 'Ninguna carpeta configurada';

  @override
  String get runScan => 'Escanear biblioteca';

  @override
  String get scanning => 'Escaneando…';

  @override
  String get pickFolder => 'Elegir una carpeta';

  @override
  String get addThisFolder => 'Añadir esta carpeta';

  @override
  String get createPlaylist => 'Crear una lista';

  @override
  String get playlistName => 'Nombre de la lista';

  @override
  String get create => 'Crear';

  @override
  String get addToPlaylist => 'Añadir a una lista';

  @override
  String get newPlaylist => 'Nueva lista';

  @override
  String get playlistCreated => 'Lista creada';

  @override
  String get addedToPlaylist => 'Añadido a la lista';

  @override
  String get delete => 'Eliminar';

  @override
  String get deletePlaylist => 'Eliminar lista';

  @override
  String get deletePlaylistConfirm => '¿Eliminar esta lista?';

  @override
  String get playlistDeleted => 'Lista eliminada';

  @override
  String get trackRemoved => 'Quitado de la lista';

  @override
  String get removeFromPlaylist => 'Quitar de la lista';

  @override
  String get logIn => 'Iniciar sesión';

  @override
  String get logOut => 'Cerrar sesión';

  @override
  String get username => 'Usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get cancel => 'Cancelar';

  @override
  String get noService => 'Ningún servicio';

  @override
  String loginTo(String service) {
    return 'Iniciar sesión en $service';
  }

  @override
  String get authorizeInBrowser => 'Autoriza el acceso en tu navegador:';

  @override
  String get openAuthPage => 'Abrir la página de autorización';

  @override
  String get done => 'He terminado';

  @override
  String get disabled => 'Desactivado';
}
