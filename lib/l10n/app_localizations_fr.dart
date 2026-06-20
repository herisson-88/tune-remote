// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLFr extends AppL {
  AppLFr([String locale = 'fr']) : super(locale);

  @override
  String get navSearch => 'Recherche';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get loading => 'Chargement…';

  @override
  String errorWith(String msg) {
    return 'Erreur : $msg';
  }

  @override
  String get notConnected => 'Configure le serveur dans Paramètres';

  @override
  String get playAll => 'Tout lire';

  @override
  String get noTracks => 'Aucune piste';

  @override
  String get searchTitle => 'Recherche';

  @override
  String get searchHint => 'Titre, album, artiste…';

  @override
  String get filterAll => 'Tout';

  @override
  String get searchEmptyTitle => 'Recherche un titre, un album ou un artiste';

  @override
  String get searchEmptySub => 'Qobuz · YouTube · ta bibliothèque';

  @override
  String get noResults => 'Aucun résultat';

  @override
  String get sectionArtists => 'Artistes';

  @override
  String get sectionAlbums => 'Albums';

  @override
  String get sectionPlaylists => 'Playlists';

  @override
  String get sectionTracks => 'Titres';

  @override
  String get sourceLibrary => 'Bibliothèque';

  @override
  String get playlistsTitle => 'Playlists';

  @override
  String get dynamicPlaylists => 'Playlists dynamiques';

  @override
  String get dynamicTag => 'Dynamique';

  @override
  String tracksCount(int n) {
    return '$n pistes';
  }

  @override
  String maxTracks(int n) {
    return 'max $n';
  }

  @override
  String get noPlaylists => 'Aucune playlist';

  @override
  String get favoritesTitle => 'Favoris';

  @override
  String get tabArtists => 'Artistes';

  @override
  String get tabAlbums => 'Albums';

  @override
  String get tabTracks => 'Titres';

  @override
  String get noFavArtists => 'Aucun artiste favori';

  @override
  String get noFavAlbums => 'Aucun album favori';

  @override
  String get noFavTracks => 'Aucun titre favori';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get server => 'Serveur';

  @override
  String get host => 'Hôte';

  @override
  String get port => 'Port';

  @override
  String get connect => 'Connecter';

  @override
  String get connected => 'Connecté';

  @override
  String get disconnected => 'Non connecté';

  @override
  String get audioOutput => 'Sortie audio';

  @override
  String get audioOutputDesc =>
      'Chaque zone du serveur correspond à une sortie (ALSA local, renderer Diretta…). Choisis la zone sur laquelle jouer.';

  @override
  String get noZones => 'Aucune zone disponible';

  @override
  String get gapless => 'Lecture enchaînée (gapless)';

  @override
  String get gaplessDesc =>
      'À désactiver si bruit blanc / glitch entre les pistes sur ce renderer.';

  @override
  String get metadataFields => 'Champs de métadonnées';

  @override
  String get metadataFieldsDesc =>
      'Infos affichées pour la bibliothèque locale';

  @override
  String get streamingQuality => 'Qualité streaming';

  @override
  String get streamingQualityDesc =>
      'Plafonne la fréquence / résolution demandée aux services (Qobuz, Tidal…).';

  @override
  String get freqLimit => 'Limite de fréquence';

  @override
  String get qualityMax => 'Maximum';

  @override
  String get qualityHires => 'Hi-Res (jusqu\'à 192 kHz)';

  @override
  String get qualityCd => 'CD (44.1 kHz / 16 bit)';

  @override
  String get streamingServices => 'Services de streaming';

  @override
  String get language => 'Langue';

  @override
  String get systemLanguage => 'Système';

  @override
  String get nothingPlaying => 'Rien en lecture';

  @override
  String get visualizer => 'Visualiseur';

  @override
  String get cover => 'Pochette';

  @override
  String get addFavorite => 'Ajouter aux favoris';

  @override
  String get removeFavorite => 'Retirer des favoris';

  @override
  String favError(String msg) {
    return 'Échec favori : $msg';
  }

  @override
  String get metadataTitle => 'Champs de métadonnées';

  @override
  String get metadataSaved => 'Métadonnées enregistrées';

  @override
  String get logIn => 'Se connecter';

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get username => 'Identifiant / email';

  @override
  String get password => 'Mot de passe';

  @override
  String get cancel => 'Annuler';

  @override
  String get noService => 'Aucun service';

  @override
  String loginTo(String service) {
    return 'Connexion $service';
  }

  @override
  String get authorizeInBrowser => 'Autorise l\'accès dans ton navigateur :';

  @override
  String get openAuthPage => 'Ouvrir la page d\'autorisation';

  @override
  String get done => 'J\'ai terminé';

  @override
  String get disabled => 'Désactivé';
}
