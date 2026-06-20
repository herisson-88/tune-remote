<div align="center">

# 🎵 Tune Remote

**A clean, native remote control for your [Tune Server](https://github.com/renesenses/tune-server-rust) music system.**

Search · Stream · Curate — from your phone, in your language.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Android-tested-3DDC84?logo=android&logoColor=white)](#)
[![iOS](https://img.shields.io/badge/iOS-builds%2C%20untested-lightgrey?logo=apple&logoColor=white)](#-platforms)
[![Languages](https://img.shields.io/badge/i18n-8%20languages-6C5CE7)](#-languages)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

</div>

---

## ✨ What is this?

**Tune Android Remote** is a lightweight, *remote-only* client for the
[Tune Server](https://github.com/renesenses/tune-server-rust) audio streaming
backend. It does **no playback of its own** — it drives your server and your
renderers (DLNA / Diretta / local outputs) over the Tune REST API, exactly like
the official web UI does, but as a polished native mobile app.

> 🤝 **Companion project.** This app is an independent, community remote built
> **in coordination with the Tune Server author** ([@renesenses](https://github.com/renesenses)).
> It targets the same public API as the official
> [web app](https://github.com/renesenses/tune-server-rust) and
> [Flutter client](https://github.com/renesenses/tune-server-flutter). All the
> heavy lifting (cataloguing, streaming, audio) lives in the server — full
> credit and thanks to its author. ❤️

No accounts, tokens or passwords are ever stored in this app: streaming
credentials live **server-side only**.

---

## 📱 Platforms

Built with Flutter, so it targets **Android and iOS** from a single codebase.

- ✅ **Android** — developed and tested on device.
- 🧪 **iOS** — compiles from the same code but is **not tested yet**. It should
  work, and iOS users are very welcome to try it and report back — just know it
  hasn't been validated on real hardware. Feedback and PRs appreciated!

---

## 🎯 Features

- 🔎 **Federated search** across Qobuz, YouTube, Tidal… and your local library,
  with a **per-source target selector** (search everything, or just one service).
- 💜 **Favorites** — add / remove tracks, albums and artists; browse them grouped
  by service with Artists / Albums / Tracks tabs.
- 🎶 **Playlists** — streaming, local **and dynamic (smart) playlists**, loaded
  automatically.
- ▶️ **Now playing** — a mini player plus a full-screen view with a live
  **frequency visualizer**, seek bar and hi-res quality badge.
- 🔊 **Output = zone** — pick the server zone (local ALSA, Diretta renderer…) to
  play on; remembered as the server default.
- 🎚️ **Server settings from your pocket** — gapless toggle, streaming quality cap
  (Maximum / Hi-Res / CD), metadata fields.
- 🌍 **8 languages**, switchable live (see below).
- 📐 **Responsive** — phone layout *and* a tablet layout with a side navigation
  rail and width-capped content.
- 🟢 **Now-playing everywhere** — the currently playing track is highlighted in
  every list (search, albums, playlists, favorites).

---

## 📱 Screenshots

> _Coming soon — drop your captures in `docs/screenshots/`._

| Search | Now Playing | Favorites | Settings |
| :---: | :---: | :---: | :---: |
| 🔎 | 🎶 | 💜 | ⚙️ |

---

## 🏗️ Architecture

```
┌──────────────────────────┐        REST / JSON         ┌───────────────────────────┐
│   Tune Android Remote     │ ─────────────────────────▶ │   Tune Server (Rust)       │
│   (this app — Flutter)    │   GET /search, /zones,     │   catalogue · streaming ·  │
│   pure remote control     │   POST /zones/{id}/play …  │   favorites · audio        │
└──────────────────────────┘ ◀───────────────────────── └───────────────────────────┘
                                  zones / now-playing                 │
                                                                      ▼
                                                          DLNA / Diretta / local output
```

The app talks to `http://<host>:<port>/api/v1/...`. Everything it shows comes
from the server; it keeps no music database of its own.

---

## 🚀 Getting started

### Prerequisites
- A running [Tune Server](https://github.com/renesenses/tune-server-rust) on your network.
- [Flutter](https://docs.flutter.dev/get-started/install) 3.x.

### Run
```bash
git clone https://github.com/herisson-88/tune-remote.git
cd tune-remote
flutter pub get
flutter run            # Android device/emulator (or iOS — untested)
```

### Configure
On first launch, open **Settings** and enter your server **Host** (e.g.
`192.168.1.18`) and **Port** (default `8888`), then tap **Connect**. Pick an
output zone and you're ready to play.

---

## 🌍 Languages

The UI is fully localized and follows the system locale by default, with a
manual picker in Settings:

🇬🇧 English · 🇫🇷 Français · 🇩🇪 Deutsch · 🇪🇸 Español · 🇮🇹 Italiano · 🇨🇳 中文 · 🇯🇵 日本語 · 🇰🇷 한국어

Translations live in [`lib/l10n/`](lib/l10n) as ARB files (Flutter `gen-l10n`).
PRs adding or improving a language are very welcome!

---

## 🧩 Tech stack

| | |
| --- | --- |
| Framework | Flutter / Dart |
| State | `provider` (ChangeNotifier) |
| Networking | `http` |
| Images | `cached_network_image` |
| Storage | `shared_preferences` |
| i18n | `flutter_localizations` + `intl` (ARB) |

---

## 🙏 Acknowledgements

- **[Tune Server](https://github.com/renesenses/tune-server-rust)** and its
  author **[@renesenses](https://github.com/renesenses)** — the backend that
  makes all of this possible.
- The official **[tune-server-flutter](https://github.com/renesenses/tune-server-flutter)**
  client, a reference for the API contract.

---

## 📄 License

Released under the [MIT License](LICENSE) — same spirit as the upstream Tune
Server project.
