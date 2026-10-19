import 'package:equatable/equatable.dart';

import 'media_entry.dart';

/// Agrupamento de episodios de uma mesma serie (inferido de M3U).
/// Playlists M3U simples nem sempre proveem temporada/episodio; nestes
/// casos a serie vira uma lista simples de episodios sem ordem garantida.
class Series extends Equatable {
  const Series({
    required this.key,
    required this.title,
    required this.seasons,
    this.logoUrl,
  });

  final String key;
  final String title;
  final String? logoUrl;
  final List<Season> seasons;

  int get totalEpisodes =>
      seasons.fold(0, (sum, s) => sum + s.episodes.length);

  @override
  List<Object?> get props => [key, title, logoUrl, seasons];
}

class Season extends Equatable {
  const Season({required this.number, required this.episodes});

  final int number; // 0 = sem numero de temporada (agrupador residual)
  final List<MediaEntry> episodes;

  String get label => number == 0 ? 'Episodios' : 'Temporada $number';

  @override
  List<Object?> get props => [number, episodes];
}
