import 'package:equatable/equatable.dart';

/// Origem de conteudo cadastrada pelo usuario.
/// Suporta M3U por URL, M3U por arquivo local e (futuro) Xtream Codes.
enum PlaylistSourceType { m3uUrl, m3uFile, xtream }

class PlaylistSource extends Equatable {
  const PlaylistSource({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    this.username,
    this.password,
    this.addedAt,
    this.lastUpdatedAt,
    this.itemCount,
  });

  final String id;
  final String name;
  final PlaylistSourceType type;

  /// URL da playlist (ou endpoint Xtream). Nunca logada com credenciais.
  final String url;
  final String? username;
  final String? password;
  final DateTime? addedAt;
  final DateTime? lastUpdatedAt;
  final int? itemCount;

  bool get hasCredentials =>
      (username?.isNotEmpty ?? false) || (password?.isNotEmpty ?? false);

  PlaylistSource copyWith({
    String? name,
    DateTime? lastUpdatedAt,
    int? itemCount,
  }) =>
      PlaylistSource(
        id: id,
        name: name ?? this.name,
        type: type,
        url: url,
        username: username,
        password: password,
        addedAt: addedAt,
        lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
        itemCount: itemCount ?? this.itemCount,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'url': url,
        'username': username,
        'password': password,
        'addedAt': addedAt?.toIso8601String(),
        'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
        'itemCount': itemCount,
      };

  factory PlaylistSource.fromJson(Map<String, dynamic> json) => PlaylistSource(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Playlist',
        type: PlaylistSourceType.values
            .byName(json['type'] as String? ?? 'm3uUrl'),
        url: json['url'] as String? ?? '',
        username: json['username'] as String?,
        password: json['password'] as String?,
        addedAt: DateTime.tryParse(json['addedAt'] as String? ?? ''),
        lastUpdatedAt: DateTime.tryParse(json['lastUpdatedAt'] as String? ?? ''),
        itemCount: (json['itemCount'] as num?)?.toInt(),
      );

  @override
  List<Object?> get props => [id, name, type, url, username, password];
}
