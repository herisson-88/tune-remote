import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';

const _oauthServices = {'tidal', 'spotify'};
const _noLoginServices = {'youtube'};

String _label(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final services = app.services.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    if (services.isEmpty) return Text(AppL.of(context).noService);
    return Column(
      children: [for (final s in services) _ServiceTile(info: s)],
    );
  }
}

class _ServiceTile extends StatefulWidget {
  final StreamingServiceInfo info;
  const _ServiceTile({required this.info});

  @override
  State<_ServiceTile> createState() => _ServiceTileState();
}

class _ServiceTileState extends State<_ServiceTile> {
  bool _busy = false;

  StreamingServiceInfo get s => widget.info;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      await context.read<AppState>().refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppL.of(context).errorWith('$e'))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _connect() async {
    final app = context.read<AppState>();
    final c = app.client;
    if (c == null) return;

    if (_oauthServices.contains(s.name)) {
      // OAuth: get a verification URL and let the user authorize in a browser.
      setState(() => _busy = true);
      try {
        final r = await c.authOAuth(s.name);
        final url = r['verification_url'] as String?;
        final code = r['user_code'] as String?;
        if (mounted && url != null) {
          await _showOAuthDialog(url, code);
        }
        await app.refresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Erreur: $e')));
        }
      } finally {
        if (mounted) setState(() => _busy = false);
      }
      return;
    }

    // Credentials (Qobuz, Deezer…)
    final creds = await _showCredentialsDialog();
    if (creds == null) return;
    await _run(() => c.authCredentials(s.name, creds.$1, creds.$2));
  }

  Future<(String, String)?> _showCredentialsDialog() {
    final user = TextEditingController();
    final pass = TextEditingController();
    final t = AppL.of(context);
    return showDialog<(String, String)>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.loginTo(_label(s.name))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: user,
              autocorrect: false,
              decoration: InputDecoration(
                  labelText: t.username,
                  prefixIcon: const Icon(Icons.person)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pass,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: t.password, prefixIcon: const Icon(Icons.lock)),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, (user.text.trim(), pass.text)),
            child: Text(t.logIn),
          ),
        ],
      ),
    );
  }

  Future<void> _showOAuthDialog(String url, String? code) {
    final t = AppL.of(context);
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.loginTo(_label(s.name))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.authorizeInBrowser),
            if (code != null) ...[
              const SizedBox(height: 12),
              Center(
                child: SelectableText(code,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () =>
                  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.open_in_new),
              label: Text(t.openAuthPage),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(t.done)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL.of(context);
    final authed = s.authenticated;
    final canLogin = !_noLoginServices.contains(s.name);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
        child: Row(
          children: [
            Icon(
              authed ? Icons.check_circle : Icons.cloud_off,
              color: authed ? Colors.green : Colors.white24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_label(s.name),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    authed
                        ? (s.username ?? t.connected)
                        : (s.enabled ? t.disconnected : t.disabled),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (authed)
              TextButton(
                onPressed: () => _run(() =>
                    context.read<AppState>().client!.disconnectService(s.name)),
                child: Text(t.logOut),
              )
            else if (canLogin)
              FilledButton(
                onPressed: _connect,
                child: Text(t.connect),
              ),
          ],
        ),
      ),
    );
  }
}
