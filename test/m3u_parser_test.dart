import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_streamer/data/datasources/m3u_parser.dart';
import 'package:iptv_streamer/data/models/media_type.dart';

void main() {
  const parser = M3uParser();

  group('M3uParser - basico', () {
    test('parse de playlist simples com um canal', () {
      const content = '''
#EXTM3U
#EXTINF:-1 tvg-id="globo" tvg-name="Globo" tvg-logo="http://x/globo.png" group-title="Noticias",TV Globo
http://example.com/globo.ts
''';
      final result = parser.parse(content);
      expect(result.entries.length, 1);
      final e = result.entries.first;
      expect(e.title, 'TV Globo');
      expect(e.url, 'http://example.com/globo.ts');
      expect(e.tvgId, 'globo');
      expect(e.tvgName, 'Globo');
      expect(e.logoUrl, 'http://x/globo.png');
      expect(e.groupTitle, 'Noticias');
    });

    test('atributos em qualquer ordem', () {
      const content = '''
#EXTM3U
#EXTINF:-1 group-title="Filmes" tvg-logo="http://x/a.png" tvg-id="a",Filme A
http://example.com/a.mp4
''';
      final e = parser.parse(content).entries.first;
      expect(e.groupTitle, 'Filmes');
      expect(e.logoUrl, 'http://x/a.png');
      expect(e.tvgId, 'a');
      expect(e.title, 'Filme A');
    });

    test('URL sem #EXTINF anterior gera titulo a partir da URL', () {
      const content = '#EXTM3U\nhttp://example.com/canal_xyz.ts\n';
      final e = parser.parse(content).entries.first;
      expect(e.title, 'canal_xyz.ts');
      expect(e.url, 'http://example.com/canal_xyz.ts');
    });

    test('linhas invalidas e comentarios sao ignorados', () {
      const content = '''
#EXTM3U
#COMANDO-DESCONHECIDO: lixo

#EXTINF:-1,Canal Valido
http://example.com/valido.ts
isto-nao-e-uma-url
#EXTINF:-1,Outro
http://example.com/outro.ts
''';
      final result = parser.parse(content);
      expect(result.entries.length, 2);
      expect(result.skippedLines, greaterThanOrEqualTo(1));
    });

    test('playlist vazia retorna zero entradas', () {
      expect(parser.parse('#EXTM3U\n\n\n').entries, isEmpty);
      expect(parser.parse('').entries, isEmpty);
    });

    test('ids estaveis para mesma url+titulo', () {
      const c = '#EXTINF:-1,A\nhttp://x/a.ts\n';
      final id1 = parser.parse(c).entries.first.id;
      final id2 = parser.parse(c).entries.first.id;
      expect(id1, id2);
    });
  });

  group('M3uParser - inferencia de tipo', () {
    test('duracao > 0 + grupo filme = movie', () {
      const c = '#EXTINF:120 group-title="Filmes",Filme X\nhttp://x/f.mp4\n';
      expect(parser.parse(c).entries.first.type, MediaType.movie);
    });

    test('grupo ao vivo com duracao -1 = live', () {
      const c = '#EXTINF:-1 group-title="Esportes ao vivo",Canal Esporte\nhttp://x/c.ts\n';
      expect(parser.parse(c).entries.first.type, MediaType.live);
    });

    test('padrao S01E05 no titulo = serie com temporada/episodio', () {
      const c = '#EXTINF:-1,Minha Serie S01E05\nhttp://x/e.mp4\n';
      final e = parser.parse(c).entries.first;
      expect(e.type, MediaType.series);
      expect(e.season, 1);
      expect(e.episode, 5);
      expect(e.seriesKey, 'Minha Serie');
    });

    test('padrao alternativo 2x10', () {
      const c = '#EXTINF:-1,Outra Serie 2x10\nhttp://x/e2.mp4\n';
      final e = parser.parse(c).entries.first;
      expect(e.type, MediaType.series);
      expect(e.season, 2);
      expect(e.episode, 10);
    });

    test('titulo sem padrao de serie nao vira serie', () {
      const c = '#EXTINF:-1 group-title="Filmes",Um Filme Qualquer\nhttp://x/f.mp4\n';
      final e = parser.parse(c).entries.first;
      expect(e.type, isNot(MediaType.series));
      expect(e.season, isNull);
    });
  });

  group('M3uParser - robustez', () {
    test('atributos com valores vazios', () {
      const c = '#EXTINF:-1 tvg-id="" tvg-logo="",Canal\nhttp://x/c.ts\n';
      final e = parser.parse(c).entries.first;
      expect(e.tvgId, isNull);
      expect(e.logoUrl, isNull);
    });

    test('multiplas entradas preservam ordem', () {
      const c = '''
#EXTINF:-1,A
http://x/a.ts
#EXTINF:-1,B
http://x/b.ts
#EXTINF:-1,C
http://x/c.ts
''';
      final titles = parser.parse(c).entries.map((e) => e.title).toList();
      expect(titles, ['A', 'B', 'C']);
    });

    test('quebras de linha Windows (\\r\\n)', () {
      const c = '#EXTM3U\r\n#EXTINF:-1,Canal Win\r\nhttp://x/w.ts\r\n';
      expect(parser.parse(c).entries.length, 1);
    });
  });
}
