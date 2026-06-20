// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLZh extends AppL {
  AppLZh([String locale = 'zh']) : super(locale);

  @override
  String get navSearch => '搜索';

  @override
  String get navPlaylists => '播放列表';

  @override
  String get navFavorites => '收藏';

  @override
  String get navSettings => '设置';

  @override
  String get loading => '加载中…';

  @override
  String errorWith(String msg) {
    return '错误：$msg';
  }

  @override
  String get notConnected => '请在设置中配置服务器';

  @override
  String get playAll => '全部播放';

  @override
  String get noTracks => '没有曲目';

  @override
  String get searchTitle => '搜索';

  @override
  String get searchHint => '标题、专辑、艺人…';

  @override
  String get filterAll => '全部';

  @override
  String get searchEmptyTitle => '搜索标题、专辑或艺人';

  @override
  String get searchEmptySub => 'Qobuz · YouTube · 你的音乐库';

  @override
  String get noResults => '无结果';

  @override
  String get sectionArtists => '艺人';

  @override
  String get sectionAlbums => '专辑';

  @override
  String get sectionPlaylists => '播放列表';

  @override
  String get sectionTracks => '曲目';

  @override
  String get sourceLibrary => '音乐库';

  @override
  String get playlistsTitle => '播放列表';

  @override
  String get dynamicPlaylists => '动态播放列表';

  @override
  String get dynamicTag => '动态';

  @override
  String tracksCount(int n) {
    return '$n 首';
  }

  @override
  String maxTracks(int n) {
    return '最多 $n';
  }

  @override
  String get noPlaylists => '没有播放列表';

  @override
  String get favoritesTitle => '收藏';

  @override
  String get tabArtists => '艺人';

  @override
  String get tabAlbums => '专辑';

  @override
  String get tabTracks => '曲目';

  @override
  String get noFavArtists => '没有收藏的艺人';

  @override
  String get noFavAlbums => '没有收藏的专辑';

  @override
  String get noFavTracks => '没有收藏的曲目';

  @override
  String get settingsTitle => '设置';

  @override
  String get server => '服务器';

  @override
  String get host => '主机';

  @override
  String get port => '端口';

  @override
  String get connect => '连接';

  @override
  String get connected => '已连接';

  @override
  String get disconnected => '未连接';

  @override
  String get audioOutput => '音频输出';

  @override
  String get audioOutputDesc => '每个服务器区域对应一个输出（本地 ALSA、Diretta 渲染器…）。选择要播放的区域。';

  @override
  String get noZones => '没有可用区域';

  @override
  String get gapless => '无缝播放';

  @override
  String get gaplessDesc => '如果在此渲染器上曲目之间出现白噪声/卡顿，请关闭。';

  @override
  String get metadataFields => '元数据字段';

  @override
  String get metadataFieldsDesc => '为本地音乐库显示的信息';

  @override
  String get streamingQuality => '流媒体质量';

  @override
  String get streamingQualityDesc => '限制向服务（Qobuz、Tidal…）请求的频率/分辨率。';

  @override
  String get freqLimit => '频率上限';

  @override
  String get qualityMax => '最高';

  @override
  String get qualityHires => 'Hi-Res（最高 192 kHz）';

  @override
  String get qualityCd => 'CD（44.1 kHz / 16 位）';

  @override
  String get maxFrequency => '最高频率';

  @override
  String get maxBitDepth => '最高位深';

  @override
  String get noLimit => '无限制';

  @override
  String get streamingServices => '流媒体服务';

  @override
  String get language => '语言';

  @override
  String get systemLanguage => '系统';

  @override
  String get nothingPlaying => '没有在播放';

  @override
  String get visualizer => '可视化';

  @override
  String get cover => '封面';

  @override
  String get addFavorite => '加入收藏';

  @override
  String get removeFavorite => '取消收藏';

  @override
  String favError(String msg) {
    return '收藏失败：$msg';
  }

  @override
  String get metadataTitle => '元数据字段';

  @override
  String get metadataSaved => '元数据已保存';

  @override
  String get localLibrary => '本地音乐库';

  @override
  String get localLibraryDesc => '服务器扫描音乐的文件夹';

  @override
  String get musicFolders => '已扫描的文件夹';

  @override
  String get addFolder => '添加文件夹';

  @override
  String get noFolders => '未配置文件夹';

  @override
  String get runScan => '扫描音乐库';

  @override
  String get scanning => '扫描中…';

  @override
  String get pickFolder => '选择文件夹';

  @override
  String get addThisFolder => '添加此文件夹';

  @override
  String get createPlaylist => '创建播放列表';

  @override
  String get playlistName => '播放列表名称';

  @override
  String get create => '创建';

  @override
  String get addToPlaylist => '添加到播放列表';

  @override
  String get newPlaylist => '新建播放列表';

  @override
  String get playlistCreated => '播放列表已创建';

  @override
  String get addedToPlaylist => '已添加到播放列表';

  @override
  String get delete => '删除';

  @override
  String get deletePlaylist => '删除播放列表';

  @override
  String get deletePlaylistConfirm => '删除此播放列表？';

  @override
  String get playlistDeleted => '播放列表已删除';

  @override
  String get trackRemoved => '已从播放列表移除';

  @override
  String get removeFromPlaylist => '从播放列表移除';

  @override
  String get logIn => '登录';

  @override
  String get logOut => '登出';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get cancel => '取消';

  @override
  String get noService => '无服务';

  @override
  String loginTo(String service) {
    return '登录 $service';
  }

  @override
  String get authorizeInBrowser => '在浏览器中授权访问：';

  @override
  String get openAuthPage => '打开授权页面';

  @override
  String get done => '我已完成';

  @override
  String get disabled => '已禁用';
}
