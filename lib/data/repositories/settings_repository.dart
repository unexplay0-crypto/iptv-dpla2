import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';

/// Preferencias do usuario (tema, avanco do player, etc.).
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  int get skipSeconds =>
      _prefs.getInt(AppConstants.keyPlayerSkipSeconds) ??
      AppConstants.defaultSkipSeconds;

  Future<void> setSkipSeconds(int seconds) =>
      _prefs.setInt(AppConstants.keyPlayerSkipSeconds, seconds);

  bool get useTvLayout => _prefs.getBool('force_tv_layout') ?? false;
  Future<void> setUseTvLayout(bool value) =>
      _prefs.setBool('force_tv_layout', value);
}
