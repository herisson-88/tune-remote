import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/responsive.dart';
import '../widgets/services_section.dart';
import 'metadata_screen.dart';

/// Languages offered in Settings (matches the web app's locales).
const kLanguages = <String, String>{
  '': 'Système',
  'en': 'English',
  'fr': 'Français',
  'de': 'Deutsch',
  'es': 'Español',
  'it': 'Italiano',
  'zh': '中文',
  'ja': '日本語',
  'ko': '한국어',
};

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _hostCtrl;
  late final TextEditingController _portCtrl;
  bool _synced = false;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _hostCtrl = TextEditingController(text: app.serverHost);
    _portCtrl = TextEditingController(text: app.serverPort.toString());
    // If the host was already loaded from prefs, we're in sync; otherwise
    // build() will populate the fields once init() finishes (see below).
    _synced = app.serverHost.isNotEmpty;
  }

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_portCtrl.text.trim().isEmpty) {
      _portCtrl.text = AppState.defaultPort.toString();
    }
    await context.read<AppState>().setServer(_hostCtrl.text, _portCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = AppL.of(context);
    // Once init() has loaded the saved host from prefs, fill the fields
    // (initState ran before that async load completed).
    if (!_synced && app.serverHost.isNotEmpty) {
      _hostCtrl.text = app.serverHost;
      _portCtrl.text = app.serverPort.toString();
      _synced = true;
    }
    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: MaxWidth(
        maxWidth: 720,
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Server ──────────────────────────────────────────────
          Text(t.server, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _hostCtrl,
                  decoration: InputDecoration(
                    labelText: t.host,
                    hintText: '192.168.1.18',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.dns),
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  onSubmitted: (_) => _save(),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 96,
                child: TextField(
                  controller: _portCtrl,
                  decoration: InputDecoration(
                    labelText: t.port,
                    hintText: '8888',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _save(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              FilledButton.icon(
                onPressed: app.loading ? null : _save,
                icon: const Icon(Icons.link),
                label: Text(t.connect),
              ),
              const SizedBox(width: 12),
              if (app.loading)
                const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              else
                _StatusChip(
                    connected: app.connected,
                    label: app.connected ? t.connected : t.disconnected),
            ],
          ),
          if (app.error != null) ...[
            const SizedBox(height: 8),
            Text(app.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],

          if (app.connected) ...[
            const Divider(height: 32),
            // ── Output = zone ─────────────────────────────────────
            Text(t.audioOutput,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              t.audioOutputDesc,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 10),
            if (app.zones.isEmpty)
              Text(t.noZones)
            else
              ...app.zones.map((z) {
                final selected = z.id == app.currentZone?.id;
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    leading: Icon(z.outputType == 'dlna' ||
                            z.outputType == 'openhome'
                        ? Icons.speaker
                        : Icons.volume_up),
                    title: Text(z.name),
                    subtitle: z.outputType != null ? Text(z.outputType!) : null,
                    trailing: selected
                        ? Icon(Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () => app.setCurrentZone(z.id),
                  ),
                );
              }),

            if (app.currentZone != null) ...[
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.gapless),
                subtitle: Text(t.gaplessDesc),
                value: app.currentZone!.gaplessEnabled,
                onChanged: (v) => app.setGapless(v),
              ),
            ],

            const Divider(height: 32),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.label_outline),
              title: Text(t.metadataFields),
              subtitle: Text(t.metadataFieldsDesc),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const MetadataScreen())),
            ),

            const Divider(height: 32),
            // ── Streaming quality ─────────────────────────────────
            Text(t.streamingQuality,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              t.streamingQualityDesc,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white54),
            ),
            const _StreamQuality(),

            const Divider(height: 32),
            // ── Services ──────────────────────────────────────────
            Text(t.streamingServices,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const ServicesSection(),
          ],

          const Divider(height: 32),
          // ── Language ────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(t.language,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              DropdownButton<String>(
                value: app.locale?.languageCode ?? '',
                onChanged: (v) => app.setLocale(v),
                items: [
                  for (final e in kLanguages.entries)
                    DropdownMenuItem(
                      value: e.key,
                      child: Text(e.key.isEmpty ? t.systemLanguage : e.value),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
      ),
    );
  }
}

/// Caps the streaming sample rate and bit depth INDEPENDENTLY (DACs vary a lot),
/// written to the server's max_sample_rate / max_bit_depth config.
class _StreamQuality extends StatelessWidget {
  const _StreamQuality();

  static const _rates = [44100, 48000, 88200, 96000, 176400, 192000, 352800, 384000];
  static const _depths = [16, 24, 32];

  String _rateLabel(int hz) {
    final khz = hz / 1000;
    final s = khz % 1 == 0 ? khz.toStringAsFixed(0) : khz.toStringAsFixed(1);
    return '$s kHz';
  }

  /// Snap an arbitrary server value to the closest offered option.
  int _closest(List<int> options, int value) => options.reduce(
      (a, b) => (a - value).abs() <= (b - value).abs() ? a : b);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = AppL.of(context);
    final cfg = app.streamConfig;
    if (cfg == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(t.loading, style: const TextStyle(color: Colors.white54)),
      );
    }
    final rate = _closest(_rates, cfg.maxSampleRate);
    final depth = _closest(_depths, cfg.maxBitDepth);

    Widget row(String label, Widget dropdown) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [Expanded(child: Text(label)), dropdown],
          ),
        );

    return Column(
      children: [
        row(
          t.maxFrequency,
          DropdownButton<int>(
            value: rate,
            onChanged: (v) {
              if (v != null) app.setStreamQuality(v, cfg.maxBitDepth);
            },
            items: [
              for (final r in _rates)
                DropdownMenuItem(value: r, child: Text(_rateLabel(r))),
            ],
          ),
        ),
        row(
          t.maxBitDepth,
          DropdownButton<int>(
            value: depth,
            onChanged: (v) {
              if (v != null) app.setStreamQuality(cfg.maxSampleRate, v);
            },
            items: [
              for (final d in _depths)
                DropdownMenuItem(value: d, child: Text('$d-bit')),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool connected;
  final String label;
  const _StatusChip({required this.connected, required this.label});
  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(connected ? Icons.cloud_done : Icons.cloud_off,
          size: 18, color: connected ? Colors.green : Colors.white38),
      label: Text(label),
    );
  }
}

