import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/detail/detail_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/home_shell.dart';
import '../../features/live/live_screen.dart';
import '../../features/movies/movies_screen.dart';
import '../../features/player/player_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/series/series_screen.dart';
import '../../features/settings/settings_screen.dart';

/// Rotas do aplicativo. Cada rota e navegavel por foco (D-pad) na TV.
class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String live = '/live';
  static const String movies = '/movies';
  static const String series = '/series';
  static const String favorites = '/favorites';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String detail = '/detail';
  static const String player = '/player';

  static GoRouter create() {
    return GoRouter(
      initialLocation: home,
      debugLogDiagnostics: false,
      routes: [
        ShellRoute(
          builder: (context, state, child) => HomeShell(child: child),
          routes: [
            GoRoute(path: home, pageBuilder: _fade((s) => const HomeScreen())),
            GoRoute(path: live, pageBuilder: _fade((s) => const LiveScreen())),
            GoRoute(
                path: movies, pageBuilder: _fade((s) => const MoviesScreen())),
            GoRoute(
                path: series, pageBuilder: _fade((s) => const SeriesScreen())),
            GoRoute(path: favorites,
                pageBuilder: _fade((s) => const FavoritesScreen())),
            GoRoute(
                path: search, pageBuilder: _fade((s) => const SearchScreen())),
            GoRoute(path: settings,
                pageBuilder: _fade((s) => const SettingsScreen())),
            GoRoute(
              path: detail,
              pageBuilder: _fade((s) {
                final id = s.uri.queryParameters['id'] ?? '';
                return DetailScreen(mediaId: id);
              }),
            ),
          ],
        ),
        GoRoute(
          path: player,
          pageBuilder: (context, state) {
            final id = state.uri.queryParameters['id'] ?? '';
            final title = state.uri.queryParameters['title'] ?? '';
            final url = state.uri.queryParameters['url'] ?? '';
            final isLive = state.uri.queryParameters['live'] == '1';
            return MaterialPage(
              fullscreenDialog: true,
              child: PlayerScreen(
                mediaId: id,
                title: title,
                url: url,
                isLive: isLive,
              ),
            );
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Rota nao encontrada: ${state.uri}')),
      ),
    );
  }

  static Page<dynamic> Function(BuildContext, GoRouterState) _fade(
    Widget Function(GoRouterState) builder,
  ) {
    return (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: builder(state),
          transitionsBuilder: (c, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 180),
        );
  }
}


