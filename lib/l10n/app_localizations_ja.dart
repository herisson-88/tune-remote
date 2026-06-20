// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLJa extends AppL {
  AppLJa([String locale = 'ja']) : super(locale);

  @override
  String get navSearch => '検索';

  @override
  String get navPlaylists => 'プレイリスト';

  @override
  String get navFavorites => 'お気に入り';

  @override
  String get navSettings => '設定';

  @override
  String get loading => '読み込み中…';

  @override
  String errorWith(String msg) {
    return 'エラー: $msg';
  }

  @override
  String get notConnected => '設定でサーバーを構成してください';

  @override
  String get playAll => 'すべて再生';

  @override
  String get noTracks => 'トラックなし';

  @override
  String get searchTitle => '検索';

  @override
  String get searchHint => 'タイトル、アルバム、アーティスト…';

  @override
  String get filterAll => 'すべて';

  @override
  String get searchEmptyTitle => 'タイトル・アルバム・アーティストを検索';

  @override
  String get searchEmptySub => 'Qobuz · YouTube · ライブラリ';

  @override
  String get noResults => '結果なし';

  @override
  String get sectionArtists => 'アーティスト';

  @override
  String get sectionAlbums => 'アルバム';

  @override
  String get sectionPlaylists => 'プレイリスト';

  @override
  String get sectionTracks => 'トラック';

  @override
  String get sourceLibrary => 'ライブラリ';

  @override
  String get playlistsTitle => 'プレイリスト';

  @override
  String get dynamicPlaylists => 'ダイナミックプレイリスト';

  @override
  String get dynamicTag => 'ダイナミック';

  @override
  String tracksCount(int n) {
    return '$n 曲';
  }

  @override
  String maxTracks(int n) {
    return '最大 $n';
  }

  @override
  String get noPlaylists => 'プレイリストなし';

  @override
  String get favoritesTitle => 'お気に入り';

  @override
  String get tabArtists => 'アーティスト';

  @override
  String get tabAlbums => 'アルバム';

  @override
  String get tabTracks => 'トラック';

  @override
  String get noFavArtists => 'お気に入りのアーティストなし';

  @override
  String get noFavAlbums => 'お気に入りのアルバムなし';

  @override
  String get noFavTracks => 'お気に入りのトラックなし';

  @override
  String get settingsTitle => '設定';

  @override
  String get server => 'サーバー';

  @override
  String get host => 'ホスト';

  @override
  String get port => 'ポート';

  @override
  String get connect => '接続';

  @override
  String get connected => '接続済み';

  @override
  String get disconnected => '未接続';

  @override
  String get audioOutput => 'オーディオ出力';

  @override
  String get audioOutputDesc =>
      '各サーバーゾーンが1つの出力です（ローカルALSA、Direttaレンダラー…）。再生するゾーンを選択してください。';

  @override
  String get noZones => '利用可能なゾーンがありません';

  @override
  String get gapless => 'ギャップレス再生';

  @override
  String get gaplessDesc => 'このレンダラーでトラック間にホワイトノイズ/途切れがある場合は無効にしてください。';

  @override
  String get metadataFields => 'メタデータ項目';

  @override
  String get metadataFieldsDesc => 'ローカルライブラリに表示される情報';

  @override
  String get streamingQuality => 'ストリーミング品質';

  @override
  String get streamingQualityDesc => 'サービス（Qobuz、Tidal…）に要求する周波数/解像度の上限を設定します。';

  @override
  String get freqLimit => '周波数の上限';

  @override
  String get qualityMax => '最高';

  @override
  String get qualityHires => 'ハイレゾ（最大192 kHz）';

  @override
  String get qualityCd => 'CD（44.1 kHz / 16ビット）';

  @override
  String get streamingServices => 'ストリーミングサービス';

  @override
  String get language => '言語';

  @override
  String get systemLanguage => 'システム';

  @override
  String get nothingPlaying => '再生していません';

  @override
  String get visualizer => 'ビジュアライザー';

  @override
  String get cover => 'ジャケット';

  @override
  String get addFavorite => 'お気に入りに追加';

  @override
  String get removeFavorite => 'お気に入りから削除';

  @override
  String favError(String msg) {
    return 'お気に入りに失敗: $msg';
  }

  @override
  String get metadataTitle => 'メタデータ項目';

  @override
  String get metadataSaved => 'メタデータを保存しました';

  @override
  String get logIn => 'ログイン';

  @override
  String get logOut => 'ログアウト';

  @override
  String get username => 'ユーザー名';

  @override
  String get password => 'パスワード';

  @override
  String get cancel => 'キャンセル';

  @override
  String get noService => 'サービスなし';

  @override
  String loginTo(String service) {
    return '$service にログイン';
  }

  @override
  String get authorizeInBrowser => 'ブラウザでアクセスを許可してください：';

  @override
  String get openAuthPage => '認証ページを開く';

  @override
  String get done => '完了しました';

  @override
  String get disabled => '無効';
}
