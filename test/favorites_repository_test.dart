import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_streamer/data/models/media_entry.dart';
import 'package:iptv_streamer/data/models/media_type.dart';
import 'package:iptv_streamer/data/repositories/favorites_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const entry = MediaEntry(
    id: 'abc123',
    title: 'Canal Teste',
    url: 'http://x/c.ts',
    type: MediaType.live,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('adiciona e remove favorito, sem duplicatas', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = FavoritesRepository(prefs);

    expect(repo.getFavorites(), isEmpty);
    expect(repo.isFavorite('abc123'), isFalse);

    await repo.toggle(entry);
    expect(repo.getFavorites().length, 1);
    expect(repo.isFavorite('abc123'), isTrue);

    // Adicionar de novo nao duplica.
    await repo.toggle(entry);
    expect(repo.getFavorites().length, 1);

    // Remover.
    await repo.toggle(entry);
    expect(repo.getFavorites(), isEmpty);
  });

  test('persiste entre instancias (simula restart)', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo1 = FavoritesRepository(prefs);
    await repo1.toggle(entry);

    // Nova instancia lendo os mesmos dados.
    final repo2 = FavoritesRepository(prefs);
    expect(repo2.isFavorite('abc123'), isTrue);
  });

  test('remove por id', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = FavoritesRepository(prefs);
    await repo.toggle(entry);
    await repo.remove('abc123');
    expect(repo.isFavorite('abc123'), isFalse);
  });
}
