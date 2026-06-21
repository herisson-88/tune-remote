import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/cover.dart';
import '../widgets/favorite_button.dart';
import '../widgets/responsive.dart';
import '../widgets/spectrum_visualizer.dart';
import 'album_detail.dart';
import 'artist_detail.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  bool _viz = false;
  double? _drag;

  String _fmt(int ms) {
    final s = ms ~/ 1000;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  /// The zone's now-playing track carries no album/artist IDs, so resolve them
  /// from the full track detail (local or streaming) before navigating.
  Future<Track?> _full(Track t) async {
    final c = context.read<AppState>().client;
    if (c == null) return null;
    try {
      if (t.source == 'local') {
        final id = int.tryParse(t.sourceId);
        return id == null ? null : await c.localTrackById(id);
      }
      return await c.streamingTrack(t.source, t.sourceId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _openAlbum(Track t) async {
    final full = await _full(t);
    final albumId = full?.albumId ?? t.albumId;
    if (!mounted || albumId == null || albumId.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AlbumDetail(
        album: Album(
          sourceId: albumId,
          title: t.albumTitle ?? '',
          source: t.source,
          artistName: t.artistName,
          coverPath: t.coverPath,
        ),
      ),
    ));
  }

  Future<void> _openArtist(Track t) async {
    final c = context.read<AppState>().client;
    final full = await _full(t);
    var artistId = full?.artistId ?? t.artistId;
    // Streaming tracks (Qobuz) often lack artist_id — resolve it via the album.
    if ((artistId == null || artistId.isEmpty) && t.source != 'local' && c != null) {
      final albumId = full?.albumId ?? t.albumId;
      if (albumId != null && albumId.isNotEmpty) {
        try {
          artistId = (await c.streamingAlbum(t.source, albumId)).artistId;
        } catch (_) {}
      }
    }
    if (!mounted) return;
    if (artistId == null || artistId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL.of(context).noResults)));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ArtistDetail(
        artist: Artist(
            id: artistId!, name: t.artistName ?? '', source: t.source),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l = AppL.of(context);
    final z = app.currentZone;
    final t = z?.currentTrack;
    final cs = Theme.of(context).colorScheme;

    if (z == null || t == null || z.state == 'stopped') {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              onPressed: () => Navigator.maybePop(context)),
        ),
        body: Center(child: Text(l.nothingPlaying)),
      );
    }

    final dur = t.durationMs ?? 0;
    final pos = _drag ?? z.positionMs.toDouble();
    final size = MediaQuery.of(context).size;
    final wide = size.width >= Breakpoints.rail;
    final artSide = wide
        ? (size.height - 140).clamp(220.0, 460.0)
        : size.width - 56;

    // Cover ⇄ visualizer
    final art = SizedBox(
      width: artSide,
      height: artSide,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _viz
            ? Container(
                key: const ValueKey('viz'),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child:
                    SpectrumVisualizer(active: z.isPlaying, color: cs.primary),
              )
            : Cover(
                key: const ValueKey('cover'),
                path: t.coverPath,
                size: artSide,
                radius: 16),
      ),
    );

    // Title / artist / album / quality
    final info = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(t.title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          // Artist · Album — both tappable to open their pages.
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (t.artistName != null && t.artistName!.isNotEmpty)
                _LinkText(text: t.artistName!, onTap: () => _openArtist(t)),
              if (t.artistName != null &&
                  t.artistName!.isNotEmpty &&
                  t.albumTitle != null &&
                  t.albumTitle!.isNotEmpty)
                Text('  ·  ', style: TextStyle(color: cs.onSurfaceVariant)),
              if (t.albumTitle != null && t.albumTitle!.isNotEmpty)
                _LinkText(text: t.albumTitle!, onTap: () => _openAlbum(t)),
            ],
          ),
          if (t.quality != null && !t.quality!.isEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(t.quality!.label,
                  style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );

    final seekBar = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: dur > 0 ? pos.clamp(0, dur.toDouble()) : 0,
              max: dur > 0 ? dur.toDouble() : 1,
              onChanged: dur > 0 ? (v) => setState(() => _drag = v) : null,
              onChangeEnd: (v) {
                setState(() => _drag = null);
                app.seek(v.toInt());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(pos.toInt()),
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                Text(_fmt(dur),
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );

    final controls = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            iconSize: 40,
            icon: const Icon(Icons.skip_previous),
            onPressed: app.previous),
        const SizedBox(width: 16),
        IconButton.filled(
          iconSize: 44,
          icon: Icon(z.isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: app.togglePlay,
        ),
        const SizedBox(width: 16),
        IconButton(
            iconSize: 40,
            icon: const Icon(Icons.skip_next),
            onPressed: app.next),
      ],
    );

    final volumeRow = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Icon(
            z.volume <= 0
                ? Icons.volume_off
                : z.volume < 0.5
                    ? Icons.volume_down
                    : Icons.volume_up,
            size: 20,
            color: cs.onSurfaceVariant,
          ),
          Expanded(
            child: Slider(
              value: z.volume.clamp(0.0, 1.0),
              onChanged: z.fixedVolume ? null : (v) => app.setVolume(v),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${(z.volume * 100).round()}',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(z.name, style: const TextStyle(fontSize: 14)),
        actions: [
          FavoriteButton(source: t.source, type: 'tracks', id: t.sourceId),
          IconButton(
            tooltip: _viz ? l.cover : l.visualizer,
            icon: Icon(_viz ? Icons.album : Icons.graphic_eq),
            onPressed: () => setState(() => _viz = !_viz),
          ),
        ],
      ),
      body: SafeArea(
        child: wide
            // Two-pane: artwork left, info + controls right.
            ? Row(
                children: [
                  Expanded(child: Center(child: art)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          info,
                          const SizedBox(height: 32),
                          seekBar,
                          const SizedBox(height: 12),
                          controls,
                          const SizedBox(height: 8),
                          volumeRow,
                        ],
                      ),
                    ),
                  ),
                ],
              )
            // Single column (phones).
            : Column(
                children: [
                  const Spacer(),
                  art,
                  const SizedBox(height: 28),
                  info,
                  const Spacer(),
                  seekBar,
                  const SizedBox(height: 8),
                  controls,
                  const SizedBox(height: 8),
                  volumeRow,
                  const SizedBox(height: 28),
                ],
              ),
      ),
    );
  }
}

/// A tappable, lightly-emphasized inline label (artist / album link).
class _LinkText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _LinkText({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Text(
          text,
          style: TextStyle(
              color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
