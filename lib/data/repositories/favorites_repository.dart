import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../models/media_entry.dart';

/// Favoritos persistidos localmente. Armazena os itens completos (para
/// exibicao mesmo sem a playlist carregada), com prevencao de duplicatas.
class FavoritesRepository {
  FavoritesRepository(this._prefs);

  final SharedPreferences _prefs;

  List<MediaEntry> getFavorites() {
    final raw = _prefs.getStringList(AppConstants.keyFavorites) ?? const [];
    return raw
        .map((s) {
          try {
            return MediaEntry.fromJson(jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<MediaEntry>()
        .toList();
  }

  Future<void> _save(List<MediaEntry> items) async {
    final limited = items.take(AppConstants.maxFavorites).toList();
    final raw = limited.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(AppConstants.keyFavorites, raw);
  }

  bool isFavorite(String id) => getFavorites().any((e) => e.id == id);

  Future<void> toggle(MediaEntry entry) async {
    final all = getFavorites();
    final idx = all.indexWhere((e) => e.id == entry.id);
    if (idx >= 0) {
      all.removeAt(idx);
    } else {
      all.insert(0, entry);
    }
    await _save(all);
  }

  Future<void> remove(String id) async {
    final all = getFavorites()..removeWhere((e) => e.id == id);
    await _save(all);
  }

  Future<void> clear() async => _prefs.remove(AppConstants.keyFavorites);
}
