import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

/// Cover art. [path] is usually an absolute Qobuz URL; if it's a relative
/// backend path it is prefixed with the configured server host.
class Cover extends StatelessWidget {
  final String? path;
  final double size;
  final double radius;
  final IconData fallback;

  const Cover({
    super.key,
    required this.path,
    this.size = 52,
    this.radius = 8,
    this.fallback = Icons.music_note,
  });

  @override
  Widget build(BuildContext context) {
    String? url;
    final p = path;
    if (p != null && p.isNotEmpty) {
      if (p.startsWith('http')) {
        url = p;
      } else {
        final base = context.read<AppState>().serverBase;
        if (base != null) url = p.startsWith('/') ? '$base$p' : '$base/$p';
      }
    }

    final placeholder = Container(
      width: size,
      height: size,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(fallback, size: size * 0.45, color: Colors.white24),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url == null
          ? placeholder
          : CachedNetworkImage(
              imageUrl: url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 150),
              placeholder: (_, __) => placeholder,
              errorWidget: (_, __, ___) => placeholder,
            ),
    );
  }
}
