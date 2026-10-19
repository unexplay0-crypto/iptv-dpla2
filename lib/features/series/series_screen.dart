import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation_helper.dart';
import '../../data/models/media_entry.dart';
import '../../data/models/media_type.dart';
import '../../data/models/series_models.dart';
import '../../state/providers.dart';
import '../widgets/media_card.dart';
import '../widgets/state_views.dart';

/// Tela de series: grade de series; ao selecionar, abre dialog com
/// temporadas e episodios. Series inferidas de M3U — metadata limitada.
class SeriesScreen extends ConsumerWidget {
  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryAutoRefreshProvider);
    final isTv = MediaQuery.sizeOf(context).width >= 960;

    return libraryAsync.when(
      loading: () => StateViews.loading(),
      error: (e, _) => StateViews.error(
        message: 'Erro ao carregar series.',
        onRetry: () => ref.read(libraryRefreshProvider.notifier).state++,
      ),
      data: (library) {
        if (library.series.isEmpty) {
          return StateViews.empty(
            icon: Icons.tv,
            title: 'Nenhuma serie encontrada',
            subtitle:
                'Playlists M3U simples nem sempre identificam series. '
                'A deteccao depende de padroes como S01E05 no titulo.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Series (${library.series.length})',
                  style: TextStyle(
                      fontSize: isTv ? 32 : 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: isTv ? 180 : 150,
                  childAspectRatio: 2 / 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: library.series.length,
                itemBuilder: (context, i) {
                  final s = library.series[i];
                  return MediaCard(
                    entry: MediaEntry(
                      id: s.key,
                      title: s.title,
                      url: '',
                      logoUrl: s.logoUrl,
                      type: MediaType.series,
                    ),
                    aspectRatio: 2 / 3,
                    width: double.infinity,
                    autofocus: isTv && i == 0,
                    onSelected: () => _openEpisodes(context, s),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _openEpisodes(BuildContext context, Series series) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1E),
        title: Text(series.title,
            style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: series.seasons.length,
            itemBuilder: (_, si) {
              final season = series.seasons[si];
              return ExpansionTile(
                initiallyExpanded: si == 0,
                title: Text('${season.label} (${season.episodes.length} eps)',
                    style: const TextStyle(color: Colors.white)),
                children: season.episodes.map((ep) {
                  return ListTile(
                    title: Text(ep.title,
                        style: const TextStyle(color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.play_arrow, color: Colors.red),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      openPlayer(context, ep);
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
