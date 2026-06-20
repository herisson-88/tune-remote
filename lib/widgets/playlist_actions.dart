import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/models.dart';
import '../api/tune_client.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import 'cover.dart';

/// Sources that can own user playlists: the local library + every authenticated
/// streaming service.
List<String> writablePlaylistSources(AppState app) => [
      'local',
      for (final s in app.services.values)
        if (s.enabled && s.authenticated) s.name,
    ];

String _sourceLabel(BuildContext c, String s) =>
    s == 'local' ? AppL.of(c).sourceLibrary : (s[0].toUpperCase() + s.substring(1));

/// Create-playlist dialog. When [source] is given the picker is hidden.
/// Returns the new playlist id (or null if cancelled).
Future<String?> showCreatePlaylistDialog(BuildContext context,
    {String? source}) async {
  final app = context.read<AppState>();
  final c = app.client;
  if (c == null) return null;
  final t = AppL.of(context);
  final nameCtrl = TextEditingController();
  final sources = source != null ? [source] : writablePlaylistSources(app);
  String picked = sources.first;
  final messenger = ScaffoldMessenger.of(context);

  final created = await showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setLocal) {
      return AlertDialog(
        title: Text(t.createPlaylist),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: InputDecoration(labelText: t.playlistName),
            ),
            if (source == null && sources.length > 1) ...[
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: picked,
                isExpanded: true,
                items: [
                  for (final s in sources)
                    DropdownMenuItem(value: s, child: Text(_sourceLabel(ctx, s))),
                ],
                onChanged: (v) {
                  if (v != null) setLocal(() => picked = v);
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
          FilledButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              try {
                final id = picked == 'local'
                    ? await c.createLocalPlaylist(name)
                    : await c.createStreamingPlaylist(picked, name);
                if (ctx.mounted) Navigator.pop(ctx, id);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx)
                      .showSnackBar(SnackBar(content: Text(t.errorWith('$e'))));
                }
              }
            },
            child: Text(t.create),
          ),
        ],
      );
    }),
  );
  if (created != null) {
    messenger.showSnackBar(SnackBar(content: Text(t.playlistCreated)));
  }
  return created;
}

/// Add [track] to one of the user's playlists (matching the track's source),
/// or create a new one. Smart/dynamic playlists aren't editable.
Future<void> showAddToPlaylistSheet(BuildContext context, Track track) async {
  if (track.source == 'smart') return;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _AddToPlaylistSheet(track: track),
  );
}

Future<void> _addTrack(TuneClient c, Playlist p, Track track) async {
  if (track.source == 'local') {
    final id = int.tryParse(track.sourceId);
    if (id != null) await c.addLocalPlaylistTracks(p.id, [id]);
  } else {
    await c.addStreamingPlaylistTracks(track.source, p.id, [track.sourceId]);
  }
}

class _AddToPlaylistSheet extends StatefulWidget {
  final Track track;
  const _AddToPlaylistSheet({required this.track});

  @override
  State<_AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends State<_AddToPlaylistSheet> {
  List<Playlist>? _playlists;
  bool _busy = false;

  TuneClient? get _c => context.read<AppState>().client;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = _c;
    if (c == null) return;
    try {
      final src = widget.track.source;
      final pls = src == 'local'
          ? await c.localPlaylists()
          : await c.streamingPlaylists(src);
      if (mounted) setState(() => _playlists = pls);
    } catch (_) {
      if (mounted) setState(() => _playlists = const []);
    }
  }

  Future<void> _addTo(Playlist p) async {
    final c = _c;
    if (c == null) return;
    final t = AppL.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await _addTrack(c, p, widget.track);
      if (mounted) Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text(t.addedToPlaylist)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(t.errorWith('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createAndAdd() async {
    final id = await showCreatePlaylistDialog(context, source: widget.track.source);
    if (id == null) return;
    await _addTo(Playlist(id: id, name: '', source: widget.track.source));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL.of(context);
    final pls = _playlists;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Text(t.addToPlaylist,
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (_busy)
                  const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
          ),
          Flexible(
            child: pls == null
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : ListView(
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.add),
                        title: Text(t.newPlaylist),
                        onTap: _busy ? null : _createAndAdd,
                      ),
                      const Divider(height: 1),
                      for (final p in pls)
                        ListTile(
                          leading: Cover(
                              path: p.coverPath,
                              size: 44,
                              fallback: Icons.queue_music),
                          title: Text(p.name,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: p.trackCount != null
                              ? Text(t.tracksCount(p.trackCount!))
                              : null,
                          onTap: _busy ? null : () => _addTo(p),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
