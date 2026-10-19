import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/app_logger.dart';
import '../../core/constants.dart';
import '../../core/errors.dart';
import '../models/media_library.dart';
import 'm3u_parser.dart';

/// Responsavel por baixar (ou ler) o conteudo da playlist e converte-lo
/// em [MediaLibrary]. Nao persiste nada — isso fica com o repositorio.
class PlaylistFetcher {
  PlaylistFetcher({http.Client? client, M3uParser? parser})
      : _client = client ?? http.Client(),
        _parser = parser ?? const M3uParser();

  final http.Client _client;
  final M3uParser _parser;

  /// Baixa uma playlist remota. Tenta [retries] vezes com backoff curto.
  Future<String> fetchRemote(String url, {int retries = 1}) async {
    Uri? uri;
    try {
      uri = Uri.parse(url);
    } catch (_) {
      throw const PlaylistParseFailure('URL invalida.');
    }
    Object? lastError;
    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await _client
            .get(uri, headers: const {'User-Agent': 'IPTVStreamer/1.0'})
            .timeout(AppConstants.networkTimeout);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return utf8.decode(response.bodyBytes, allowMalformed: true);
        }
        lastError = 'HTTP ${response.statusCode}';
      } catch (e) {
        lastError = e;
        AppLogger.w('Falha ao baixar playlist (tentativa $attempt): $e');
      }
      await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
    }
    throw NetworkFailure('Nao foi possivel baixar a playlist: $lastError');
  }

  /// Converte o texto da playlist em biblioteca de conteudo.
  MediaLibrary parseContent(String content) {
    final result = _parser.parse(content);
    AppLogger.i(
        'Playlist parse: ${result.entries.length} itens, ${result.skippedLines} linhas ignoradas');
    if (result.entries.isEmpty) throw const PlaylistEmptyFailure();
    return MediaLibrary.fromEntries(result.entries);
  }

  Future<MediaLibrary> fetchAndParse(String url) async {
    final content = await fetchRemote(url);
    return parseContent(content);
  }

  void dispose() => _client.close();
}
