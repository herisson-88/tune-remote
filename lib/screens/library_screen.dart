import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/tune_client.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/responsive.dart';

/// Manage the server's local music folders and trigger a library scan.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<String>? _dirs;
  bool _busy = false;
  bool _scanning = false;
  int? _lastTracks;

  TuneClient? get _c => context.read<AppState>().client;

  @override
  void initState() {
    super.initState();
    _load();
    _refreshScan();
  }

  Future<void> _load() async {
    final c = _c;
    if (c == null) return;
    try {
      final d = await c.musicDirs();
      if (mounted) setState(() => _dirs = d);
    } catch (e) {
      _snack('$e');
      if (mounted) setState(() => _dirs = const []);
    }
  }

  Future<void> _refreshScan() async {
    final c = _c;
    if (c == null) return;
    try {
      final s = await c.scanStatus();
      if (!mounted) return;
      setState(() {
        _scanning = s['status'] == 'scanning' || s['scanning'] == true;
        final res = s['result'];
        if (res is Map && res['inserted'] != null) {
          _lastTracks = (res['inserted'] as num?)?.toInt();
        }
      });
    } catch (_) {}
  }

  Future<void> _add() async {
    final c = _c;
    if (c == null) return;
    final path = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (_) => const _DirBrowser()));
    if (path == null) return;
    setState(() => _busy = true);
    try {
      final d = await c.addMusicDir(path);
      if (mounted) setState(() => _dirs = d);
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(String path) async {
    final c = _c;
    if (c == null) return;
    setState(() => _busy = true);
    try {
      final d = await c.removeMusicDir(path);
      if (mounted) setState(() => _dirs = d);
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _scan() async {
    final c = _c;
    if (c == null) return;
    setState(() => _scanning = true);
    try {
      await c.startScan();
      for (var i = 0; i < 60 && mounted; i++) {
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        final s = await c.scanStatus();
        final scanning = s['status'] == 'scanning' || s['scanning'] == true;
        final res = s['result'];
        setState(() {
          _scanning = scanning;
          if (res is Map && res['inserted'] != null) {
            _lastTracks = (res['inserted'] as num?)?.toInt();
          }
        });
        if (!scanning) break;
      }
    } catch (e) {
      _snack('$e');
      if (mounted) setState(() => _scanning = false);
    }
  }

  void _snack(String m) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL.of(context);
    final dirs = _dirs;
    return Scaffold(
      appBar: AppBar(title: Text(t.localLibrary)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _add,
        icon: const Icon(Icons.create_new_folder_outlined),
        label: Text(t.addFolder),
      ),
      body: MaxWidth(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Text(t.localLibraryDesc,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white54)),
            const SizedBox(height: 16),
            Text(t.musicFolders,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (dirs == null)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (dirs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(t.noFolders,
                    style: const TextStyle(color: Colors.white54)),
              )
            else
              ...dirs.map((d) => Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      leading: const Icon(Icons.folder),
                      title: Text(d,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: _busy ? null : () => _remove(d),
                      ),
                    ),
                  )),
            const Divider(height: 32),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _scanning ? null : _scan,
                  icon: _scanning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh),
                  label: Text(_scanning ? t.scanning : t.runScan),
                ),
                const SizedBox(width: 12),
                if (_lastTracks != null)
                  Text(t.tracksCount(_lastTracks!),
                      style: const TextStyle(color: Colors.white54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A simple server-side directory browser. Pops the chosen absolute path.
class _DirBrowser extends StatefulWidget {
  const _DirBrowser();
  @override
  State<_DirBrowser> createState() => _DirBrowserState();
}

class _DirBrowserState extends State<_DirBrowser> {
  String? _current;
  String? _parent;
  List<Map<String, dynamic>> _dirs = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _browse(null);
  }

  Future<void> _browse(String? path) async {
    final c = context.read<AppState>().client;
    if (c == null) return;
    setState(() => _loading = true);
    try {
      final r = await c.browseDirs(path);
      if (!mounted) return;
      setState(() {
        _current = r['current'] as String?;
        _parent = r['parent'] as String?;
        _dirs = (r['dirs'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.pickFolder)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(_current ?? '…',
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      if (_parent != null)
                        ListTile(
                          leading: const Icon(Icons.arrow_upward),
                          title: const Text('..'),
                          onTap: () => _browse(_parent),
                        ),
                      for (final d in _dirs)
                        ListTile(
                          leading: const Icon(Icons.folder_outlined),
                          title: Text(d['name']?.toString() ?? ''),
                          trailing: d['has_children'] == true
                              ? const Icon(Icons.chevron_right)
                              : null,
                          onTap: () => _browse(d['path']?.toString()),
                        ),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: _current == null
                ? null
                : () => Navigator.of(context).pop(_current),
            icon: const Icon(Icons.check),
            label: Text(t.addThisFolder),
          ),
        ),
      ),
    );
  }
}
