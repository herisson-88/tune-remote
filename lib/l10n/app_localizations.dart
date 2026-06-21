import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL
/// returned by `AppL.of(context)`.
///
/// Applications need to include `AppL.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL.localizationsDelegates,
///   supportedLocales: AppL.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL.supportedLocales
/// property.
abstract class AppL {
  AppL(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL of(BuildContext context) {
    return Localizations.of<AppL>(context, AppL)!;
  }

  static const LocalizationsDelegate<AppL> delegate = _AppLDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @genre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get genre;

  /// No description provided for @label.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get label;

  /// No description provided for @expertPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Expert playlists'**
  String get expertPlaylists;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get navPlaylists;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @errorWith.
  ///
  /// In en, this message translates to:
  /// **'Error: {msg}'**
  String errorWith(String msg);

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Set up the server in Settings'**
  String get notConnected;

  /// No description provided for @playAll.
  ///
  /// In en, this message translates to:
  /// **'Play all'**
  String get playAll;

  /// No description provided for @noTracks.
  ///
  /// In en, this message translates to:
  /// **'No tracks'**
  String get noTracks;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Title, album, artist…'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Search a title, an album or an artist'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptySub.
  ///
  /// In en, this message translates to:
  /// **'Qobuz · YouTube · your library'**
  String get searchEmptySub;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @sectionArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get sectionArtists;

  /// No description provided for @sectionAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get sectionAlbums;

  /// No description provided for @sectionPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get sectionPlaylists;

  /// No description provided for @sectionTracks.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get sectionTracks;

  /// No description provided for @sourceLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get sourceLibrary;

  /// No description provided for @playlistsTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlistsTitle;

  /// No description provided for @dynamicPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Dynamic playlists'**
  String get dynamicPlaylists;

  /// No description provided for @dynamicTag.
  ///
  /// In en, this message translates to:
  /// **'Dynamic'**
  String get dynamicTag;

  /// No description provided for @tracksCount.
  ///
  /// In en, this message translates to:
  /// **'{n} tracks'**
  String tracksCount(int n);

  /// No description provided for @maxTracks.
  ///
  /// In en, this message translates to:
  /// **'max {n}'**
  String maxTracks(int n);

  /// No description provided for @noPlaylists.
  ///
  /// In en, this message translates to:
  /// **'No playlist'**
  String get noPlaylists;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @tabArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get tabArtists;

  /// No description provided for @tabAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get tabAlbums;

  /// No description provided for @tabTracks.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get tabTracks;

  /// No description provided for @noFavArtists.
  ///
  /// In en, this message translates to:
  /// **'No favorite artist'**
  String get noFavArtists;

  /// No description provided for @noFavAlbums.
  ///
  /// In en, this message translates to:
  /// **'No favorite album'**
  String get noFavAlbums;

  /// No description provided for @noFavTracks.
  ///
  /// In en, this message translates to:
  /// **'No favorite track'**
  String get noFavTracks;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @host.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @audioOutput.
  ///
  /// In en, this message translates to:
  /// **'Audio output'**
  String get audioOutput;

  /// No description provided for @audioOutputDesc.
  ///
  /// In en, this message translates to:
  /// **'Each server zone is one output (local ALSA, Diretta renderer…). Pick the zone to play on.'**
  String get audioOutputDesc;

  /// No description provided for @noZones.
  ///
  /// In en, this message translates to:
  /// **'No zone available'**
  String get noZones;

  /// No description provided for @gapless.
  ///
  /// In en, this message translates to:
  /// **'Gapless playback'**
  String get gapless;

  /// No description provided for @gaplessDesc.
  ///
  /// In en, this message translates to:
  /// **'Disable if you hear white noise / glitches between tracks on this renderer.'**
  String get gaplessDesc;

  /// No description provided for @metadataFields.
  ///
  /// In en, this message translates to:
  /// **'Metadata fields'**
  String get metadataFields;

  /// No description provided for @metadataFieldsDesc.
  ///
  /// In en, this message translates to:
  /// **'Info shown for the local library'**
  String get metadataFieldsDesc;

  /// No description provided for @streamingQuality.
  ///
  /// In en, this message translates to:
  /// **'Streaming quality'**
  String get streamingQuality;

  /// No description provided for @streamingQualityDesc.
  ///
  /// In en, this message translates to:
  /// **'Caps the frequency / resolution requested from services (Qobuz, Tidal…).'**
  String get streamingQualityDesc;

  /// No description provided for @freqLimit.
  ///
  /// In en, this message translates to:
  /// **'Frequency limit'**
  String get freqLimit;

  /// No description provided for @qualityMax.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get qualityMax;

  /// No description provided for @qualityHires.
  ///
  /// In en, this message translates to:
  /// **'Hi-Res (up to 192 kHz)'**
  String get qualityHires;

  /// No description provided for @qualityCd.
  ///
  /// In en, this message translates to:
  /// **'CD (44.1 kHz / 16 bit)'**
  String get qualityCd;

  /// No description provided for @maxFrequency.
  ///
  /// In en, this message translates to:
  /// **'Max frequency'**
  String get maxFrequency;

  /// No description provided for @maxBitDepth.
  ///
  /// In en, this message translates to:
  /// **'Max bit depth'**
  String get maxBitDepth;

  /// No description provided for @noLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  /// No description provided for @streamingServices.
  ///
  /// In en, this message translates to:
  /// **'Streaming services'**
  String get streamingServices;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemLanguage;

  /// No description provided for @nothingPlaying.
  ///
  /// In en, this message translates to:
  /// **'Nothing playing'**
  String get nothingPlaying;

  /// No description provided for @visualizer.
  ///
  /// In en, this message translates to:
  /// **'Visualizer'**
  String get visualizer;

  /// No description provided for @cover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get cover;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFavorite;

  /// No description provided for @favError.
  ///
  /// In en, this message translates to:
  /// **'Favorite failed: {msg}'**
  String favError(String msg);

  /// No description provided for @metadataTitle.
  ///
  /// In en, this message translates to:
  /// **'Metadata fields'**
  String get metadataTitle;

  /// No description provided for @metadataSaved.
  ///
  /// In en, this message translates to:
  /// **'Metadata saved'**
  String get metadataSaved;

  /// No description provided for @localLibrary.
  ///
  /// In en, this message translates to:
  /// **'Local library'**
  String get localLibrary;

  /// No description provided for @localLibraryDesc.
  ///
  /// In en, this message translates to:
  /// **'Folders the server scans for music'**
  String get localLibraryDesc;

  /// No description provided for @musicFolders.
  ///
  /// In en, this message translates to:
  /// **'Scanned folders'**
  String get musicFolders;

  /// No description provided for @addFolder.
  ///
  /// In en, this message translates to:
  /// **'Add a folder'**
  String get addFolder;

  /// No description provided for @noFolders.
  ///
  /// In en, this message translates to:
  /// **'No folder configured'**
  String get noFolders;

  /// No description provided for @runScan.
  ///
  /// In en, this message translates to:
  /// **'Scan library'**
  String get runScan;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning…'**
  String get scanning;

  /// No description provided for @pickFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose a folder'**
  String get pickFolder;

  /// No description provided for @addThisFolder.
  ///
  /// In en, this message translates to:
  /// **'Add this folder'**
  String get addThisFolder;

  /// No description provided for @createPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create a playlist'**
  String get createPlaylist;

  /// No description provided for @playlistName.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistName;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to a playlist'**
  String get addToPlaylist;

  /// No description provided for @newPlaylist.
  ///
  /// In en, this message translates to:
  /// **'New playlist'**
  String get newPlaylist;

  /// No description provided for @playlistCreated.
  ///
  /// In en, this message translates to:
  /// **'Playlist created'**
  String get playlistCreated;

  /// No description provided for @addedToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Added to playlist'**
  String get addedToPlaylist;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deletePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist'**
  String get deletePlaylist;

  /// No description provided for @deletePlaylistConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this playlist?'**
  String get deletePlaylistConfirm;

  /// No description provided for @playlistDeleted.
  ///
  /// In en, this message translates to:
  /// **'Playlist deleted'**
  String get playlistDeleted;

  /// No description provided for @trackRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from playlist'**
  String get trackRemoved;

  /// No description provided for @removeFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Remove from playlist'**
  String get removeFromPlaylist;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @noService.
  ///
  /// In en, this message translates to:
  /// **'No service'**
  String get noService;

  /// No description provided for @loginTo.
  ///
  /// In en, this message translates to:
  /// **'Sign in to {service}'**
  String loginTo(String service);

  /// No description provided for @authorizeInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Authorize access in your browser:'**
  String get authorizeInBrowser;

  /// No description provided for @openAuthPage.
  ///
  /// In en, this message translates to:
  /// **'Open the authorization page'**
  String get openAuthPage;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'I\'m done'**
  String get done;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;
}

class _AppLDelegate extends LocalizationsDelegate<AppL> {
  const _AppLDelegate();

  @override
  Future<AppL> load(Locale locale) {
    return SynchronousFuture<AppL>(lookupAppL(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLDelegate old) => false;
}

AppL lookupAppL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLDe();
    case 'en':
      return AppLEn();
    case 'es':
      return AppLEs();
    case 'fr':
      return AppLFr();
    case 'it':
      return AppLIt();
    case 'ja':
      return AppLJa();
    case 'ko':
      return AppLKo();
    case 'zh':
      return AppLZh();
  }

  throw FlutterError(
    'AppL.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
