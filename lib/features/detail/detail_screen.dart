import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation_helper.dart';
import '../../state/providers.dart';
import '../widgets/state_views.dart';

/// Pagina de detalhe do conteudo. Exibe apenas os metadados efetivamente
/// fornecidos pela playlist — nunca inventa sinopse ou classificacao.
class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key, required this.mediaId});

  final String mediaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryAutoRefreshProvider);
    final favorites = ref.watch(favoritesProvider);
    final isTv = MediaQuery.sizeOf(context).width >= 960;

    return libraryAsync.when(
      loading: () => StateViews.loading(),
      error: (e, _) => StateViews.error(message: 'Conteudo nao encontrado.'),
      data: (library) {
        final entry = library.byId(mediaId);
        if (entry == null) {
          return StateViews.empty(
              icon: Icons.help_outline, title: 'Conteudo nao encontrado');
        }
        final isFav = favorites.any((f) => f.id == entry.id);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: isTv ? 200 : 140,
                    height: isTv ? 300 : 210,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.movie,
                        size: 64, color: Colors.white38),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.title,
                            style: TextStyle(
                                fontSize: isTv ? 32 : 24,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _MetaChip(label: entry.type.label),
                            if (entry.groupTitle != null)
                              _MetaChip(label: entry.groupTitle!),
                            if (entry.duration > 0)
                              _MetaChip(
                                  label:
                                      '${(entry.duration / 60).round()} min'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            FilledButton.icon(
                              onPressed: () => openPlayer(context, entry),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Assistir'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF00E5FF),
                                foregroundColor: const Color(0xFF070B14),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton.filledTonal(
                              onPressed: () => ref
                                  .read(favoritesProvider.notifier)
                                  .toggle(entry),
                              icon: Icon(isFav
                                  ? Icons.favorite
                                  : Icons.favorite_border),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Metadados disponiveis na playlist:',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70),
              ),
              const SizedBox(height: 8),
              _MetaRow(label: 'Tipo', value: entry.type.label),
              if (entry.groupTitle != null)
                _MetaRow(label: 'Categoria', value: entry.groupTitle!),
              if (entry.tvgName != null)
                _MetaRow(label: 'Nome (tvg-name)', value: entry.tvgName!),
              if (entry.tvgId != null)
                _MetaRow(label: 'ID (tvg-id)', value: entry.tvgId!),
              _MetaRow(
                  label: 'Transmissao',
                  value: entry.isLive ? 'Ao vivo (sem seek)' : 'Sob demanda'),
              const SizedBox(height: 16),
              const Text(
                'Aviso: playlists M3U nao fornecem sinopse, elenco ou '
                'classificacao indicativa. Estas informacoes so estarao '
                'disponiveis se a fonte (ex.: API Xtream) as fornecer.',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 140,
              child: Text(label,
                  style: const TextStyle(color: Colors.white54, fontSize: 14))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(color: Colors.white, fontSize: 14))),
        ],
      ),
    );
  }
}
