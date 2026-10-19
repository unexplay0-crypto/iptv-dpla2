import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/playlist_fetcher.dart';
import '../data/models/media_entry.dart';
import '../data/models/media_library.dart';
import '../data/repositories/favorites_repository.dart';
import '../data/repositories/playlist_repository.dart';
import '../data/repositories/settings_repository.dart';

/// SharedPreferences e inicializado em main() e sobrescrito aqui.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences deve ser sobrescrito em main()');
});

final playlistFetcherProvider = Provider<PlaylistFetcher>((ref) {
  final fetcher = PlaylistFetcher();
  ref.onDispose(fetcher.dispose);
  return fetcher;
});

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepository(
    prefs: ref.watch(sharedPreferencesProvider),
    fetcher: ref.watch(playlistFetcherProvider),
  );
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.watch(sharedPreferencesProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
});

/// Biblioteca de conteudo carregada da playlist selecionada.
final libraryProvider = FutureProvider<MediaLibrary>((ref) async {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.loadSelected();
});

/// Contador para forcar recarga da biblioteca.
final libraryRefreshProvider = StateProvider<int>((ref) => 0);

final libraryAutoRefreshProvider = FutureProvider<MediaLibrary>((ref) async {
  ref.watch(libraryRefreshProvider);
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.loadSelected();
});

/// Favoritos reativos.
class FavoritesNotifier extends StateNotifier<List<MediaEntry>> {
  FavoritesNotifier(this._repo) : super(_repo.getFavorites());
  final FavoritesRepository _repo;

  bool isFavorite(String id) => state.any((e) => e.id == id);

  Future<void> toggle(MediaEntry entry) async {
    await _repo.toggle(entry);
    state = _repo.getFavorites();
  }

  Future<void> remove(String id) async {
    await _repo.remove(id);
    state = _repo.getFavorites();
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<MediaEntry>>((ref) {
  return FavoritesNotifier(ref.watch(favoritesRepositoryProvider));
});

/// Busca local (nao faz requisicao remota a cada caractere).
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<AsyncValue<List<MediaEntry>>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final library = ref.watch(libraryAutoRefreshProvider);
  return library.whenData((lib) {
    if (query.isEmpty) return const <MediaEntry>[];
    return lib.entries
        .where((e) =>
            e.title.toLowerCase().contains(query) ||
            (e.groupTitle ?? '').toLowerCase().contains(query))
        .take(200)
        .toList();
  });
});
