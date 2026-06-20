# CLAUDE.md — Tune Remote

Guidance for AI assistants working in this repository. Keep it tidy, keep it
honest, and **never commit credentials**.

## What this is

A **pure remote** Flutter client for the
[Tune Server](https://github.com/renesenses/tune-server-rust) backend.
Targets **Android** (developed & tested) and **iOS** (compiles from the same
codebase but **not tested on device** yet — say so in user-facing copy). The app
plays nothing itself — it drives the server and its renderers over the Tune REST
API (`http://<host>:<port>/api/v1/...`), the same contract the official web app
and [tune-server-flutter](https://github.com/renesenses/tune-server-flutter)
use.

This is a community companion project developed in coordination with the server
author ([@renesenses](https://github.com/renesenses)). When in doubt about an
endpoint, the source of truth is the **server**, not guesswork.

## Golden rules

1. **No credentials in the repo, ever.** Streaming logins (Qobuz, Tidal…) live
   server-side. The app only sends a username/password to the server's auth
   endpoint at the user's request and stores nothing. The server's
   `GET /system/config` returns secrets in clear — the app must read only the
   non-sensitive fields it needs and never display or persist the rest.
2. **Only expose a setting the web app itself modifies.** Before adding a server
   control, confirm the official client writes it. Mirroring the web keeps us
   from breaking carefully-tuned audio setups. (The one deliberate exception is
   the per-zone *gapless* toggle, added on explicit request.)
3. **Implicit feedback over toasts.** Starting playback shows the mini player —
   no "now playing" snackbar. Keep error snackbars only.
4. **Localize new strings.** Every user-facing string goes through the ARB
   files (see i18n) in all supported languages.

## Architecture

```
lib/
├── api/
│   ├── models.dart        # Data models (snake_case JSON ↔ Dart)
│   └── tune_client.dart    # REST client: GET/POST/PATCH/PUT helpers + endpoints
├── state/
│   └── app_state.dart      # ChangeNotifier: connection, zones, favorites,
│                           #   stream config, locale, playback helpers
├── l10n/                   # ARB translation files (app_<lang>.arb) + generated
├── screens/                # search, playlists, favorites, settings, details,
│                           #   now_playing, metadata
├── widgets/                # mini_player, track_tile, media_card, cover,
│                           #   favorite_button, services_section, spectrum
│                           #   visualizer, responsive helpers
└── main.dart               # MaterialApp, theme, localization, adaptive nav
                            #   (bottom bar on phones, NavigationRail on tablets)
```

- **State**: `provider` / `ChangeNotifier`. `AppState` is the single source of
  truth; screens `context.watch` it. Use `context.select` for narrow rebuilds
  (e.g. the "is this the playing track" highlight).
- **Output = zone**: each server zone is one output. Selecting a zone also sets
  it as the server default. There is no device hot-swap UI (the server enforces
  one device per zone).
- **No local playback / no music DB**: everything is fetched live from the
  server. Lists auto-load on connect and whenever the set of authenticated
  services changes (a signature, not just the host).

## Conventions

- French is the working language for in-app copy authoring, but **all strings
  must be translated** — never hardcode a literal in a widget.
- Favorites hearts appear in track lists, the player, and as AppBar actions on
  album/artist/playlist detail screens — **not** as overlays on artist/album
  thumbnails (kept clean on purpose). Favoritable types: `tracks`, `albums`,
  `artists` (not playlists, per the server).
- Keep widgets small and composable; match the surrounding style.

## i18n

- Tooling: `flutter_localizations` + `intl`, configured in `l10n.yaml`
  (generated class `AppL`, output `lib/l10n/app_localizations.dart`).
- Languages: `en` (template), `fr`, `de`, `es`, `it`, `zh`, `ja`, `ko`.
- To add a string: add the key to **every** `lib/l10n/app_*.arb`, run
  `flutter gen-l10n`, then use `AppL.of(context).<key>`.
- Capture `AppL.of(context)` before any `await` to avoid `use_build_context_
  synchronously` lints.

## Build & run

```bash
flutter pub get
flutter gen-l10n          # if ARB files changed
flutter analyze           # keep it at 0 errors / 0 warnings
flutter run               # Android device/emulator or iOS simulator
```

Keep `flutter analyze` clean; the few remaining infos are pre-existing style
nits.

## Related projects

- Backend — [renesenses/tune-server-rust](https://github.com/renesenses/tune-server-rust)
- Official Flutter client — [renesenses/tune-server-flutter](https://github.com/renesenses/tune-server-flutter)
