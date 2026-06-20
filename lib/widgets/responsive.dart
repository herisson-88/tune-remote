import 'package:flutter/material.dart';

/// Layout breakpoints (logical pixels, shortest-relevant width).
class Breakpoints {
  /// At/above this, use a side NavigationRail instead of a bottom bar.
  static const double rail = 640;

  /// At/above this, the rail can show labels permanently (extended).
  static const double railExtended = 1000;

  static bool isWide(BuildContext c) =>
      MediaQuery.sizeOf(c).width >= rail;
  static bool isExtended(BuildContext c) =>
      MediaQuery.sizeOf(c).width >= railExtended;
}

/// Centers [child] and caps its width so content doesn't stretch edge-to-edge
/// on tablets / desktops. A no-op visually on phones (they're narrower).
class MaxWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const MaxWidth({super.key, required this.child, this.maxWidth = 900});

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      );
}
