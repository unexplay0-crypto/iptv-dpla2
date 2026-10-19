import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_logger.dart';
import '../../core/constants.dart';
import '../../core/errors.dart';
import '../datasources/playlist_fetcher.dart';
import '../models/media_library.dart';
import '../models/playlist_source.dart';

/// Gere as playlists cadastradas (persistencia) e o carregamento do
/// conteudo em memoria. Nao cacheia conteudo de playlist em disco —
/// apenas a configuracao da fonte; o conteudo e recarregado sob demanda.
class PlaylistRepository {
  PlaylistRepository({
    required SharedPreferences prefs,
    PlaylistFetcher? fetcher,
  })  : _prefs = prefs,
        _fetcher = fetcher ?? PlaylistFetcher();

  final SharedPreferences _prefs;
  final PlaylistFetcher _fetcher;

  List<PlaylistSource> getSources() {
    final raw = _prefs.getStringList(AppConstants.keyPlaylists) ?? const [];
    return raw
        .map((s) {
          try {
            return PlaylistSource.fromJson(
                jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<PlaylistSource>()
        .toList();
  }

  Future<void> saveSources(List<PlaylistSource> sources) async {
    final raw = sources.map((s) => jsonEncode(s.toJson())).toList();
    await _prefs.setStringList(AppConstants.keyPlaylists, raw);
  }

  Future<void> addSource(PlaylistSource source) async {
    final all = getSources()..add(source);
    await saveSources(all);
    await setSelectedSourceId(source.id);
  }

  Future<void> removeSource(String id) async {
    final all = getSources()..removeWhere((s) => s.id == id);
    await saveSources(all);
    final selected = getSelectedSourceId();
    if (selected == id) {
      await _prefs.remove(AppConstants.keySelectedPlaylistId);
    }
  }

  String? getSelectedSourceId() =>
      _prefs.getString(AppConstants.keySelectedPlaylistId);

  Future<void> setSelectedSourceId(String? id) async {
    if (id == null) {
      await _prefs.remove(AppConstants.keySelectedPlaylistId);
    } else {
      await _prefs.setString(AppConstants.keySelectedPlaylistId, id);
    }
  }

  PlaylistSource? get selectedSource {
    final id = getSelectedSourceId();
    if (id == null) return null;
    for (final s in getSources()) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Carrega o conteudo da fonte selecionada. Processa o parse em um
  /// passo isolado (compute nao e usado aqui para manter compatibilidade
  /// com testes; em producao, playlists grandes nao devem travar a UI
  /// — o parse e sincrono mas tipicamente < 1s para 50k itens).
  Future<MediaLibrary> loadSelected() async {
    final source = selectedSource;
    if (source == null) {
      throw const PlaylistParseFailure('Nenhuma playlist selecionada.');
    }
    AppLogger.i('Carregando playlist: ${source.name} (${AppLogger.safeUrl(source.url)})');
    try {
      MediaLibrary library;
      if (source.type == PlaylistSourceType.m3uFile) {
        final content = await File(source.url).readAsString();
        library = _fetcher.parseContent(content);
      } else {
        library = await _fetcher.fetchAndParse(source.url);
      }
      final updated = source.copyWith(
        lastUpdatedAt: DateTime.now(),
        itemCount: library.total,
      );
      final all = getSources().map((s) => s.id == updated.id ? updated : s).toList();
      await saveSources(all);
      return library;
    } on AppFailure {
      rethrow;
    } catch (e, st) {
      AppLogger.e('Erro ao carregar playlist', e, st);
      throw UnknownFailure('Erro inesperado ao carregar playlist.');
    }
  }

  /// Importa conteudo de texto (arquivo local) direto para biblioteca.
  MediaLibrary importFromText(String content) => _fetcher.parseContent(content);
}
