import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'state/app_state.dart';
import 'screens/search_screen.dart';
import 'screens/playlists_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/mini_player.dart';
import 'widgets/responsive.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const TuneRemoteApp(),
    ),
  );
}

class TuneRemoteApp extends StatelessWidget {
  const TuneRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.select<AppState, Locale?>((s) => s.locale);
    return MaterialApp(
      title: 'Tune Remote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
        ),
      ),
      locale: locale,
      localizationsDelegates: AppL.localizationsDelegates,
      supportedLocales: AppL.supportedLocales,
      home: const HomeScaffold(),
    );
  }
}

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _index = 0;

  static const _screens = [
    SearchScreen(),
    PlaylistsScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  static const _icons = [
    (icon: Icons.search, selected: Icons.search),
    (icon: Icons.queue_music, selected: Icons.queue_music),
    (icon: Icons.favorite_border, selected: Icons.favorite),
    (icon: Icons.settings, selected: Icons.settings),
  ];

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final wide = Breakpoints.isWide(context);
    final t = AppL.of(context);
    final labels = [t.navSearch, t.navPlaylists, t.navFavorites, t.navSettings];
    final stack = IndexedStack(index: _index, children: _screens);

    return Scaffold(
      body: wide
          ? Row(
              children: [
                _Rail(
                  index: _index,
                  onSelect: _select,
                  labels: labels,
                  extended: Breakpoints.isExtended(context),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: stack),
              ],
            )
          : stack,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          if (!wide)
            NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _select,
              destinations: [
                for (var i = 0; i < _icons.length; i++)
                  NavigationDestination(
                    icon: Icon(_icons[i].icon),
                    selectedIcon: Icon(_icons[i].selected),
                    label: labels[i],
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Side navigation used on tablets / wide windows.
class _Rail extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  final List<String> labels;
  final bool extended;
  const _Rail(
      {required this.index,
      required this.onSelect,
      required this.labels,
      required this.extended});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minHeight: MediaQuery.sizeOf(context).height),
        child: IntrinsicHeight(
          child: NavigationRail(
            selectedIndex: index,
            onDestinationSelected: onSelect,
            extended: extended,
            labelType:
                extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            destinations: [
              for (var i = 0; i < _HomeScaffoldState._icons.length; i++)
                NavigationRailDestination(
                  icon: Icon(_HomeScaffoldState._icons[i].icon),
                  selectedIcon: Icon(_HomeScaffoldState._icons[i].selected),
                  label: Text(labels[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
