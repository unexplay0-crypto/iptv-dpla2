import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/app_logger.dart';
import '../../core/constants.dart';
import '../../data/models/playlist_source.dart';
import '../../state/providers.dart';
import '../widgets/state_views.dart';

/// Configuracoes: gerenciar playlists (URL ou arquivo), atualizar, remover.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  bool _adding = false;
  bool _busy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _addUrl() async {
    final name = _nameController.text.trim();
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _snack('Informe a URL da playlist.');
      return;
    }
    setState(() => _busy = true);
    try {
      final source = PlaylistSource(
        id: DateTime.now().microsecondsSinceEpoch.toRadixString(16),
        name: name.isEmpty ? 'Playlist ${DateTime.now().day}/${DateTime.now().month}' : name,
        type: PlaylistSourceType.m3uUrl,
        url: url,
        addedAt: DateTime.now(),
      );
      await ref.read(playlistRepositoryProvider).addSource(source);
      ref.read(libraryRefreshProvider.notifier).state++;
      _nameController.clear();
      _urlController.clear();
      _snack('Playlist adicionada. Carregando conteudo...');
    } catch (e) {
      _snack('Erro ao adicionar: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importFile() async {
    setState(() => _busy = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['m3u', 'm3u8', 'txt'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        setState(() => _busy = false);
        return;
      }
      final file = result.files.first;
      String? content;
      if (file.bytes != null) {
        content = String.fromCharCodes(file.bytes!);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      }
      if (content == null) throw 'Nao foi possivel ler o arquivo.';

      // Salva o conteudo localmente para recarregar depois.
      final dir = await getApplicationDocumentsDirectory();
      final id = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
      final localFile = File('${dir.path}/playlist_$id.m3u');
      await localFile.writeAsString(content);

      final source = PlaylistSource(
        id: id,
        name: file.name,
        type: PlaylistSourceType.m3uFile,
        url: localFile.path,
        addedAt: DateTime.now(),
      );
      await ref.read(playlistRepositoryProvider).addSource(source);
      ref.read(libraryRefreshProvider.notifier).state++;
      _snack('Playlist importada: ${file.name}');
    } catch (e, st) {
      AppLogger.e('Erro ao importar arquivo', e, st);
      _snack('Erro ao importar arquivo.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(playlistRepositoryProvider);
    final sources = repo.getSources();
    final selectedId = repo.getSelectedSourceId();
    final isTv = MediaQuery.sizeOf(context).width >= 960;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuracoes')),
      body: _busy
          ? StateViews.loading(message: 'Processando...')
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Playlists cadastradas',
                    style: TextStyle(
                        fontSize: isTv ? 26 : 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (sources.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Nenhuma playlist. Adicione uma URL ou importe um arquivo M3U abaixo.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ...sources.map((s) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: Icon(
                          s.type == PlaylistSourceType.m3uFile
                              ? Icons.folder_open
                              : Icons.link,
                          color: s.id == selectedId ? Colors.red : Colors.white54,
                        ),
                        title: Text(s.name,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${s.itemCount ?? 0} itens'
                          '${s.lastUpdatedAt != null ? ' - atualizado ${s.lastUpdatedAt!.day}/${s.lastUpdatedAt!.month}/${s.lastUpdatedAt!.year}' : ''}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Atualizar',
                              onPressed: () {
                                ref.read(libraryRefreshProvider.notifier).state++;
                                _snack('Atualizando playlist...');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Remover',
                              onPressed: () async {
                                await repo.removeSource(s.id);
                                ref.read(libraryRefreshProvider.notifier).state++;
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        onTap: () async {
                          await repo.setSelectedSourceId(s.id);
                          ref.read(libraryRefreshProvider.notifier).state++;
                          setState(() {});
                        },
                      ),
                    )),
                const SizedBox(height: 24),
                _SectionTitle('Adicionar por URL'),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL da playlist M3U / M3U Plus',
                    hintText: 'https://exemplo.com/playlist.m3u8',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _busy ? null : _addUrl,
                  icon: const Icon(Icons.add_link),
                  label: const Text('Adicionar URL'),
                ),
                const SizedBox(height: 24),
                _SectionTitle('Importar arquivo'),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _importFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Selecionar arquivo .m3u / .m3u8'),
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),
                const Text(
                  'Seguranca: credenciais nao sao registradas em logs. '
                  'Recomenda-se usar apenas playlists de fontes legitimas.',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text('Versao ${AppConstants.appVersion}',
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
