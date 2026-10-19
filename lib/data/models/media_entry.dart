import 'package:equatable/equatable.dart';

import 'media_type.dart';

/// Um item de conteudo extraido de uma playlist M3U/M3U Plus.
/// Imutavel; identificador unico gerado a partir de URL + titulo.
class MediaEntry extends Equatable {
  const MediaEntry({
    required this.id,
    required this.title,
    required this.url,
    this.logoUrl,
    this.groupTitle,
    this.tvgId,
    this.tvgName,
    this.duration = -1,
    this.type = MediaType.unknown,
    this.attributes = const {},
    this.season,
    this.episode,
    this.seriesKey,
  });

  final String id;
  final String title;
  final String url;
  final String? logoUrl;
  final String? groupTitle;
  final String? tvgId;
  final String? tvgName;

  /// Duracao em segundos (-1 = ao vivo / desconhecida).
  final int duration;
  final MediaType type;

  /// Atributos extras do #EXTINF (tvg-shift, parent-code, etc.).
  final Map<String, String> attributes;

  /// Inferidos a partir do titulo (ex.: "Serie X S01E05").
  final int? season;
  final int? episode;
  final String? seriesKey;

  bool get isLive => type == MediaType.live || duration < 0;
  bool get hasLogo => logoUrl != null && logoUrl!.isNotEmpty;

  MediaEntry copyWith({MediaType? type, int? season, int? episode, String? seriesKey}) {
    return MediaEntry(
      id: id,
      title: title,
      url: url,
      logoUrl: logoUrl,
      groupTitle: groupTitle,
      tvgId: tvgId,
      tvgName: tvgName,
      duration: duration,
      type: type ?? this.type,
      attributes: attributes,
      season: season ?? this.season,
      episode: episode ?? this.episode,
      seriesKey: seriesKey ?? this.seriesKey,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'url': url,
        'logoUrl': logoUrl,
        'groupTitle': groupTitle,
        'tvgId': tvgId,
        'tvgName': tvgName,
        'duration': duration,
        'type': type.name,
        'season': season,
        'episode': episode,
        'seriesKey': seriesKey,
      };

  factory MediaEntry.fromJson(Map<String, dynamic> json) => MediaEntry(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        url: json['url'] as String? ?? '',
        logoUrl: json['logoUrl'] as String?,
        groupTitle: json['groupTitle'] as String?,
        tvgId: json['tvgId'] as String?,
        tvgName: json['tvgName'] as String?,
        duration: (json['duration'] as num?)?.toInt() ?? -1,
        type: MediaType.values.byName(json['type'] as String? ?? 'unknown'),
        season: (json['season'] as num?)?.toInt(),
        episode: (json['episode'] as num?)?.toInt(),
        seriesKey: json['seriesKey'] as String?,
      );

  @override
  List<Object?> get props =>
      [id, title, url, logoUrl, groupTitle, tvgId, duration, type, season, episode, seriesKey];
}
