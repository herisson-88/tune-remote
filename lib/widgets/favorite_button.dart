import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/app_state.dart';

/// Heart toggle for any streaming item (track / album / artist / playlist).
/// Hidden for local items, which aren't favoritable via the streaming API.
class FavoriteButton extends StatelessWidget {
  final String source;
  final String type; // 'tracks' | 'albums' | 'artists' | 'playlists'
  final String id;
  final double size;

  const FavoriteButton({
    super.key,
    required this.source,
    required this.type,
    required this.id,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    if (source.isEmpty || source == 'smart' || id.isEmpty) {
      return const SizedBox.shrink();
    }
    final fav =
        context.select<AppState, bool>((a) => a.isFavorite(source, type, id));
    final cs = Theme.of(context).colorScheme;
    final t = AppL.of(context);
    return IconButton(
      iconSize: size,
      visualDensity: VisualDensity.compact,
      tooltip: fav ? t.removeFavorite : t.addFavorite,
      icon: Icon(fav ? Icons.favorite : Icons.favorite_border,
          color: fav ? cs.primary : null),
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await context.read<AppState>().toggleFavorite(source, type, id);
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text(t.favError('$e'))));
        }
      },
    );
  }
}
