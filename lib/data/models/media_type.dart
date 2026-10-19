/// Tipo de midia inferido a partir dos metadados da playlist.
/// M3U simples nao garante essa classificacao; a inferencia e por heuristica.
enum MediaType {
  live, // canal ao vivo
  movie, // filme sob demanda
  series, // episodio de serie
  unknown;

  static MediaType fromGroupName(String? group) {
    final g = (group ?? '').toLowerCase();
    if (g.contains('filme') || g.contains('movie') || g.contains('vod')) {
      return MediaType.movie;
    }
    if (g.contains('serie') || g.contains('series')) return MediaType.series;
    if (g.contains('ao vivo') ||
        g.contains('live') ||
        g.contains('esporte') ||
        g.contains('sport') ||
        g.contains('noticia') ||
        g.contains('news') ||
        g.contains('tv')) {
      return MediaType.live;
    }
    return MediaType.unknown;
  }

  String get label {
    switch (this) {
      case MediaType.live:
        return 'Ao Vivo';
      case MediaType.movie:
        return 'Filme';
      case MediaType.series:
        return 'Serie';
      case MediaType.unknown:
        return 'Conteudo';
    }
  }
}
