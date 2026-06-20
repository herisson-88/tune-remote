import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/responsive.dart';

/// Toggle which metadata fields the server exposes for the local library.
/// GET /system/settings/metadata-fields, PUT {fields: [enabled keys]}.
class MetadataScreen extends StatefulWidget {
  const MetadataScreen({super.key});

  @override
  State<MetadataScreen> createState() => _MetadataScreenState();
}

class _MetadataScreenState extends State<MetadataScreen> {
  List<MetadataCategory>? _cats;
  final Set<String> _enabled = {};
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = context.read<AppState>().client;
    if (c == null) return;
    try {
      final cats = await c.metadataFields();
      if (!mounted) return;
      setState(() {
        _cats = cats;
        _enabled
          ..clear()
          ..addAll([
            for (final cat in cats)
              for (final f in cat.fields)
                if (f.enabled) f.key,
          ]);
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _save() async {
    final c = context.read<AppState>().client;
    if (c == null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    final t = AppL.of(context);
    try {
      await c.setMetadataFields(_enabled.toList());
      messenger.showSnackBar(SnackBar(content: Text(t.metadataSaved)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(t.errorWith('$e'))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cats = _cats;
    final t = AppL.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.metadataTitle),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
                onPressed: _save, icon: const Icon(Icons.save_outlined)),
        ],
      ),
      body: _error != null
          ? Center(child: Text(t.errorWith(_error!)))
          : cats == null
              ? const Center(child: CircularProgressIndicator())
              : MaxWidth(
                  maxWidth: 720,
                  child: ListView(
                    children: [
                      for (final cat in cats) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Text(cat.name,
                              style: Theme.of(context).textTheme.titleSmall),
                        ),
                        for (final f in cat.fields)
                          SwitchListTile(
                            dense: true,
                            title: Text(f.label),
                            value: _enabled.contains(f.key),
                            onChanged: (v) => setState(() =>
                                v ? _enabled.add(f.key) : _enabled.remove(f.key)),
                          ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}
