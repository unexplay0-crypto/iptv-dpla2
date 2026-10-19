import 'dart:convert';

import 'package:collection/collection.dart';

import '../models/media_entry.dart';
import '../models/media_type.dart';

/// Resultado do parse: entradas validas + numero de linhas ignoradas.
class M3uParseResult {
  const M3uParseResult(this.entries, this.skippedLines);
  final List<MediaEntry> entries;
  final int skippedLines;
}

/// Analisador robusto de playlists M3U / M3U Plus.
///
/// Caracteristicas:
///  - Nao depende da ordem dos atributos, de espacos fixos ou de um
///    unico padrao de formatacao.
///  - Ignora linhas vazias, comentarios e metadados desconhecidos.
///  - Trata playlists parcialmente malformadas sem encerrar o processo.
///  - Inferencia de temporada/episodio e tipo (live/movie/series) por
///    heuristica sobre titulo e grupo.
class M3uParser {
  const M3uParser();

  static final _attrPattern = RegExp(r'([a-zA-Z0-9_-]+)="([^"]*)"');
  static final _seasonEpisodePattern = RegExp(
    r'\bS(\d{1,2})E(\d{1,3})\b',
    caseSensitive: false,
  );
  static final _seasonEpisodeAltPattern = RegExp(r'\b(\d{1,2})x(\d{1,3})\b');
  static final _seriesTitlePattern = RegExp(
    r'^(.+?)\s*(?:S\d{1,2}E\d{1,3}|\d{1,2}x\d{1,3})',
    caseSensitive: false,
  );

  /// Faz o parse de [content] (texto completo da playlist).
  M3uParseResult parse(String content) {
    final entries = <MediaEntry>[];
    var skipped = 0;

    // Normaliza quebras de linha.
    final lines = const LineSplitter().convert(content);

    Map<String, String> pendingAttrs = {};
    int pendingDuration = -1;
    String pendingTitle = '';
    String? pendingGroup;
    var hasPendingExtinf = false;

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('#')) {
        if (line.toUpperCase().startsWith('#EXTINF')) {
          final parsed = _parseExtInf(line);
          pendingAttrs = parsed.attrs;
          pendingDuration = parsed.duration;
          pendingTitle = parsed.title;
          pendingGroup = parsed.attrs['group-title'];
          hasPendingExtinf = true;
        } else if (line.toUpperCase().startsWith('#EXTGRP')) {
          // Grupo declarado apos o titulo.
          final g = line.substring(line.indexOf(':') + 1).trim();
          if (g.isNotEmpty) pendingGroup = g;
        } else if (line.toUpperCase().startsWith('#EXTM3U')) {
          // Cabeçalho; atributos globais (ex.: url-tvg) podem ser lidos aqui.
        }
        // Outros comentarios/#EXTXXX sao ignorados com seguranca.
        continue;
      }

      // Linha de URL.
      if (!_looksLikeUrl(line)) {
        skipped++;
        hasPendingExtinf = false;
        continue;
      }

      final title = hasPendingExtinf && pendingTitle.isNotEmpty
          ? pendingTitle
          : _titleFromUrl(line);

      final group = pendingGroup ?? pendingAttrs['group-title'];
      final tvgId = pendingAttrs['tvg-id'];
      final tvgName = pendingAttrs['tvg-name'];
      final logo = pendingAttrs['tvg-logo'];

      final se = _inferSeasonEpisode(title);
      final type = _inferType(group, pendingDuration, se != null);
      final seriesKey = se?.$3;

      entries.add(MediaEntry(
        id: _stableId(line, title),
        title: title,
        url: line,
        logoUrl: (logo?.isNotEmpty ?? false) ? logo : null,
        groupTitle: (group?.isNotEmpty ?? false) ? group : null,
        tvgId: (tvgId?.isNotEmpty ?? false) ? tvgId : null,
        tvgName: (tvgName?.isNotEmpty ?? false) ? tvgName : null,
        duration: pendingDuration,
        type: type,
        attributes: Map.unmodifiable(pendingAttrs),
        season: se?.$1,
        episode: se?.$2,
        seriesKey: seriesKey,
      ));

      // Reseta estado.
      pendingAttrs = {};
      pendingDuration = -1;
      pendingTitle = '';
      pendingGroup = null;
      hasPendingExtinf = false;
    }

    return M3uParseResult(List.unmodifiable(entries), skipped);
  }

  _ExtInf _parseExtInf(String line) {
    // Formato: #EXTINF:<duracao> atributos... ,Titulo
    final afterTag = line.substring(line.indexOf(':') + 1);
    final commaIndex = afterTag.lastIndexOf(',');
    final metaPart = commaIndex >= 0 ? afterTag.substring(0, commaIndex) : afterTag;
    final title = commaIndex >= 0 ? afterTag.substring(commaIndex + 1).trim() : '';

    var duration = -1;
    final firstSpace = metaPart.indexOf(' ');
    final durationStr = (firstSpace > 0 ? metaPart.substring(0, firstSpace) : metaPart).trim();
    duration = int.tryParse(durationStr) ?? -1;

    final attrs = <String, String>{};
    for (final m in _attrPattern.allMatches(metaPart)) {
      attrs[m.group(1)!.toLowerCase()] = m.group(2)!;
    }
    return _ExtInf(duration, attrs, title);
  }

  bool _looksLikeUrl(String line) {
    final lower = line.toLowerCase();
    return lower.startsWith('http://') ||
        lower.startsWith('https://') ||
        lower.startsWith('rtmp://') ||
        lower.startsWith('rtsp://') ||
        lower.startsWith('udp://') ||
        lower.startsWith('/') ||
        line.endsWith('.m3u8') ||
        line.endsWith('.ts') ||
        line.endsWith('.mp4');
  }

  String _titleFromUrl(String url) {
    final lastSlash = url.lastIndexOf('/');
    final file = lastSlash >= 0 ? url.substring(lastSlash + 1) : url;
    return Uri.decodeComponent(file.split('?').first).trim();
  }

  (int, int, String)? _inferSeasonEpisode(String title) {
    var m = _seasonEpisodePattern.firstMatch(title);
    if (m != null) {
      final s = int.parse(m.group(1)!);
      final e = int.parse(m.group(2)!);
      final key = _seriesTitlePattern.firstMatch(title)?.group(1)?.trim() ?? title;
      return (s, e, key);
    }
    m = _seasonEpisodeAltPattern.firstMatch(title);
    if (m != null) {
      final s = int.parse(m.group(1)!);
      final e = int.parse(m.group(2)!);
      final key = _seriesTitlePattern.firstMatch(title)?.group(1)?.trim() ?? title;
      return (s, e, key);
    }
    return null;
  }

  MediaType _inferType(String? group, int duration, bool isSeriesPattern) {
    if (isSeriesPattern) return MediaType.series;
    if (duration > 0) {
      // Conteudo com duracao declarada = sob demanda.
      final byGroup = MediaType.fromGroupName(group);
      if (byGroup == MediaType.live) return MediaType.movie;
      return byGroup == MediaType.unknown ? MediaType.movie : byGroup;
    }
    return MediaType.fromGroupName(group);
  }

  /// Hash estavel (FNV-1a 64 bits) em hexadecimal — evita dependencia extra.
  String _stableId(String url, String title) {
    const int offset = 0xcbf29ce484222325;
    const int prime = 0x100000001b3;
    var hash = offset;
    final bytes = utf8.encode('$url|$title');
    for (final b in bytes) {
      hash ^= b;
      hash = (hash * prime) & 0xFFFFFFFFFFFFFFFF; // ignore: unnecessary_cast
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }
}

class _ExtInf {
  const _ExtInf(this.duration, this.attrs, this.title);
  final int duration;
  final Map<String, String> attrs;
  final String title;
}
