import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import 'media_entry.dart';
import 'media_type.dart';
import 'series_models.dart';

/// Biblioteca de conteudo agregada apos parse da(s) playlist(s).
/// Imutavel; obtida por [MediaLibrary.fromEntries].
class MediaLibrary extends Equatable {
  const MediaLibrary({
    required this.entries,
    required this.channels,
    required this.movies,
    required this.series,
    required this.channelGroups,
    required this.movieGroups,
  });

  /// Todos os itens (para busca global).
  final List<MediaEntry> entries;
  final List<MediaEntry> channels;
  final List<MediaEntry> movies;
  final List<Series> series;

  /// Grupos (categorias) ordenados, cada um com seus itens.
  final List<MediaGroup> channelGroups;
  final List<MediaGroup> movieGroups;

  bool get isEmpty => entries.isEmpty;
  int get total => entries.length;

  MediaEntry? byId(String id) {
    for (final e in entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// Constrói a biblioteca a partir de entradas parseadas, inferindo tipos
  /// e agrupando series por [seriesKey].
  factory MediaLibrary.fromEntries(List<MediaEntry> raw) {
    final entries = raw.map((e) {
      if (e.type != MediaType.unknown) return e;
      return e.copyWith(type: MediaType.fromGroupName(e.groupTitle));
    }).toList();

    final channels =
        entries.where((e) => e.type == MediaType.live).toList(growable: false);
    final movies =
        entries.where((e) => e.type == MediaType.movie).toList(growable: false);
    final seriesEntries =
        entries.where((e) => e.type == MediaType.series).toList();

    // Agrupa series pela seriesKey (ou titulo base se ausente).
    final bySeries = groupBy<MediaEntry, String>(
      seriesEntries,
      (e) => e.seriesKey ?? _baseSeriesTitle(e.title),
    );
    final series = bySeries.entries.map((kv) {
      final bySeason = groupBy<MediaEntry, int>(
        kv.value,
        (e) => e.season ?? 0,
      );
      final seasons = bySeason.entries.map((s) {
        final eps = [...s.value]
          ..sort((a, b) => (a.episode ?? 0).compareTo(b.episode ?? 0));
        return Season(number: s.key, episodes: eps);
      }).toList()
        ..sort((a, b) => a.number.compareTo(b.number));
      return Series(
        key: kv.key,
        title: kv.value.firstOrNull?.title ?? kv.key,
        logoUrl: kv.value.firstWhereOrNull((e) => e.hasLogo)?.logoUrl,
        seasons: seasons,
      );
    }).toList()
      ..sort((a, b) => a.title.compareTo(b.title));

    return MediaLibrary(
      entries: List.unmodifiable(entries),
      channels: channels,
      movies: movies,
      series: List.unmodifiable(series),
      channelGroups: MediaGroup.groupBy(channels, (e) => e.groupTitle),
      movieGroups: MediaGroup.groupBy(movies, (e) => e.groupTitle),
    );
  }

  static String _baseSeriesTitle(String title) {
    // Remove "S01E05", "1x05", "- Episodio X" do titulo para obter nome da serie.
    return title
        .replaceAll(RegExp(r'\bS\d{1,2}E\d{1,3}\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\b\d{1,2}x\d{1,3}\b'), '')
        .replaceAll(RegExp(r'\s*[-:|]\s*.*$'), '')
        .trim();
  }

  static const empty = MediaLibrary(
    entries: [],
    channels: [],
    movies: [],
    series: [],
    channelGroups: [],
    movieGroups: [],
  );

  @override
  List<Object?> get props => [entries, channels, movies, series, channelGroups, movieGroups];
}

/// Um grupo (categoria) de itens de midia.
class MediaGroup extends Equatable {
  const MediaGroup({required this.name, required this.items});

  final String name;
  final List<MediaEntry> items;

  static List<MediaGroup> groupBy(
    List<MediaEntry> items,
    String? Function(MediaEntry) keyOf,
  ) {
    final groups = <String, List<MediaEntry>>{};
    for (final e in items) {
      final key = (keyOf(e)?.trim().isNotEmpty ?? false)
          ? keyOf(e)!
          : 'Sem Categoria';
      groups.putIfAbsent(key, () => []).add(e);
    }
    return groups.entries
        .map((e) => MediaGroup(name: e.key, items: List.unmodifiable(e.value)))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  List<Object?> get props => [name, items];
}
