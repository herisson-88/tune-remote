import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/cover.dart';
import '../widgets/playlist_actions.dart';
import '../widgets/responsive.dart';
import '../widgets/track_tile.dart';
import 'playlist_detail.dart';

const _sourceLabels = {
  'qobuz': 'Qobuz',
  'youtube': 'YouTube',
  'tidal': 'Tidal',
  'deezer': 'Deezer',
  'spotify': 'Spotify',
  'amazon': 'Amazon Music',
  'amazon_music': 'Amazon Music',
};

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  List<Playlist>? _streaming; // streaming services + local
  List<Playlist> _smart = const []; // dynamic / smart playlists
  String? _error;
  bool _loading = false;
  String? _loadedSig;

  /// Reloads whenever the host or the set of authenticated services changes.
  String _authSig(AppState app) {
    final svcs = app.services.values
        .where((s) => s.enabled && s.authenticated)
        .map((s) => s.name)
        .toList()
      ..sort();
    return '${app.host}|${svcs.join(',')}';
  }

  Future<void> _load() async {
    final app = context.read<AppState>();
    final c = app.client;
    if (c == null) return;
    setState(() {
      _loading = true;
      _error = null;
      _loadedSig = _authSig(app); // claim the load now to avoid double-trigger
    });
    final streaming = <Playlist>[];
    String? firstError;

    // Streaming services — publish each as soon as it returns, so Qobuz shows
    // up immediately even if another service is slow.
    for (final s in app.services.values) {
      if (!(s.enabled && s.authenticated)) continue;
      try {
        streaming.addAll(await c.streamingPlaylists(s.name));
        if (mounted) setState(() => _streaming = List.of(streaming));
      } catch (e) {
        firstError ??= e.toString();
      }
    }
    try {
      streaming.addAll(await c.localPlaylists());
    } catch (_) {}
    try {
      final smart = await c.smartPlaylists();
      if (mounted) setState(() => _smart = smart);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _streaming = streaming;
        _loading = false;
        // Only surface an error if nothing at all could be loaded.
        if (streaming.isEmpty && _smart.isEmpty) _error = firstError;
      });
    }
  }

  Future<void> _open(Playlist p) async {
    final changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => PlaylistDetail(playlist: p)));
    if (changed == true && mounted) _load();
  }

  Future<void> _create() async {
    final id = await showCreatePlaylistDialog(context);
    if (id != null) _load();
  }

  List<Widget> _section(String title, List<Playlist> items, {bool smart = false}) {
    if (items.isEmpty) return const [];
    final t = AppL.of(context);
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Row(
          children: [
            if (smart) ...[
              Icon(Icons.auto_awesome,
                  size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
            ],
            Text(title, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
      for (final p in items)
        ListTile(
          leading: smart
              ? CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.auto_awesome,
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                )
              : Cover(
                  path: p.coverPath, size: 52, fallback: Icons.queue_music),
          title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text([
            if (!smart) p.source.toUpperCase(),
            if (smart) t.dynamicTag,
            if (p.trackCount != null)
              smart ? t.maxTracks(p.trackCount!) : t.tracksCount(p.trackCount!),
          ].join(' · ')),
          onTap: () => _open(p),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (app.connected && !_loading && _loadedSig != _authSig(app)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load();
      });
    }

    // Group streaming playlists by source, preserving service order.
    final bySource = <String, List<Playlist>>{};
    for (final p in _streaming ?? const <Playlist>[]) {
      bySource.putIfAbsent(p.source, () => []).add(p);
    }
    final sortedSources = bySource.keys.toList()
      ..sort((a, b) => a == 'local'
          ? 1
          : b == 'local'
              ? -1
              : a.compareTo(b));

    final hasAny = _smart.isNotEmpty || (_streaming?.isNotEmpty ?? false);
    final t = AppL.of(context);

    Widget body;
    if (!app.connected) {
      body = const NotConnected();
    } else if (_loading && _streaming == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(child: Text(t.errorWith(_error!)));
    } else if (!hasAny) {
      body = Center(child: Text(t.noPlaylists));
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            ..._section(t.dynamicPlaylists, _smart, smart: true),
            for (final src in sortedSources)
              ..._section(
                  src == 'local'
                      ? t.sourceLibrary
                      : (_sourceLabels[src] ?? src.toUpperCase()),
                  bySource[src]!),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.playlistsTitle),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: app.connected
          ? FloatingActionButton.extended(
              onPressed: _create,
              icon: const Icon(Icons.add),
              label: Text(t.createPlaylist),
            )
          : null,
      body: MaxWidth(maxWidth: 900, child: body),
    );
  }
}
