import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_streamer/data/datasources/m3u_parser.dart';
import 'package:iptv_streamer/data/models/media_library.dart';
import 'package:iptv_streamer/data/models/media_type.dart';

void main() {
  const parser = M3uParser();

  test('agrupa canais e filmes por categoria', () {
    const content = '''
#EXTINF:-1 group-title="Noticias",Canal A
http://x/a.ts
#EXTINF:-1 group-title="Esportes",Canal B
http://x/b.ts
#EXTINF:90 group-title="Filmes",Filme 1
http://x/f1.mp4
#EXTINF:90 group-title="Filmes",Filme 2
http://x/f2.mp4
''';
    final entries = parser.parse(content).entries;
    final lib = MediaLibrary.fromEntries(entries);

    expect(lib.channels.length, 2);
    expect(lib.movies.length, 2);
    expect(lib.channelGroups.length, 2); // Noticias, Esportes
    expect(lib.movieGroups.length, 1); // Filmes
    expect(lib.movieGroups.first.items.length, 2);
  });

  test('agrupa episodios de mesma serie por temporada', () {
    const content = '''
#EXTINF:-1,Serie X S01E01
http://x/s1e1.mp4
#EXTINF:-1,Serie X S01E02
http://x/s1e2.mp4
#EXTINF:-1,Serie X S02E01
http://x/s2e1.mp4
''';
    final entries = parser.parse(content).entries;
    final lib = MediaLibrary.fromEntries(entries);

    expect(lib.series.length, 1);
    final serie = lib.series.first;
    expect(serie.seasons.length, 2);
    expect(serie.seasons.first.episodes.length, 2);
    expect(serie.totalEpisodes, 3);
    // Episodios ordenados por numero
    expect(serie.seasons.first.episodes.first.episode, 1);
  });

  test('itens sem categoria vao para "Sem Categoria"', () {
    const content = '#EXTINF:-1,Sem Grupo\nhttp://x/a.ts\n';
    final lib = MediaLibrary.fromEntries(parser.parse(content).entries);
    expect(lib.channelGroups.first.name, 'Sem Categoria');
  });

  test('byId encontra entrada', () {
    const content = '#EXTINF:-1,Alvo\nhttp://x/alvo.ts\n';
    final lib = MediaLibrary.fromEntries(parser.parse(content).entries);
    final id = lib.entries.first.id;
    expect(lib.byId(id)?.title, 'Alvo');
    expect(lib.byId('nao-existe'), isNull);
  });

  test('tipo unknown e inferido a partir do grupo', () {
    const content = '#EXTINF:-1 group-title="Series",Serie Y S03E04\nhttp://x/y.mp4\n';
    final lib = MediaLibrary.fromEntries(parser.parse(content).entries);
    expect(lib.series.length, 1);
    expect(lib.series.first.title.contains('Serie Y'), isTrue);
  });
}
