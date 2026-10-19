/// Constantes globais do aplicativo.
class AppConstants {
  AppConstants._();

  static const String appName = 'Aurora IPTV';
  static const String appVersion = '1.0.0';

  // Chaves de persistencia (SharedPreferences).
  static const String keyPlaylists = 'playlists_v1';
  static const String keyFavorites = 'favorites_v1';
  static const String keySelectedPlaylistId = 'selected_playlist_id_v1';
  static const String keyThemeMode = 'theme_mode_v1';
  static const String keyPlayerSkipSeconds = 'player_skip_seconds_v1';
  static const String keyLastView = 'last_view_v1';

  // Limites e padroes.
  static const int maxRetriesPlaylist = 2;
  static const Duration networkTimeout = Duration(seconds: 20);
  static const int defaultSkipSeconds = 10;
  static const int maxFavorites = 500;

  // Margens de seguranca (overscan) para Android TV (~5% em 960x540dp MDPI).
  static const double tvOverscanHorizontal = 48.0;
  static const double tvOverscanVertical = 27.0;
  static const double tvGridSpacing = 20.0;

  // Tamanhos de fonte minimos para TV (legibilidade a ~3m).
  static const double tvBodyFont = 20.0;
  static const double tvTitleFont = 28.0;
  static const double tvHeaderFont = 40.0;
}
