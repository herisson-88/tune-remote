import 'package:flutter/material.dart';

import 'cover.dart';

/// A small vertical card (cover + title + subtitle) for albums / artists /
/// playlists shown in horizontal lists.
class MediaCard extends StatelessWidget {
  final String? coverPath;
  final String title;
  final String? subtitle;
  final bool round;
  final IconData fallback;
  final double width;
  final VoidCallback onTap;

  const MediaCard({
    super.key,
    required this.coverPath,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.round = false,
    this.fallback = Icons.album,
    this.width = 124,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Cover(
              path: coverPath,
              size: width,
              radius: round ? width / 2 : 10,
              fallback: fallback,
            ),
            const SizedBox(height: 6),
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            if (subtitle != null && subtitle!.isNotEmpty)
              Text(subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

/// A horizontal scrolling row of cards under a section title.
class CardRow extends StatelessWidget {
  final String title;
  final List<Widget> cards;
  const CardRow({super.key, required this.title, required this.cards});

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        SizedBox(
          height: 178,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => cards[i],
          ),
        ),
      ],
    );
  }
}
