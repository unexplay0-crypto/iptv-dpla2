import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation_helper.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/media_entry.dart';
import '../../data/models/media_type.dart';
import '../../state/providers.dart';
import '../widgets/content_shelf.dart';
import '../widgets/focusable_card.dart';
import '../widgets/state_views.dart';

/// Tela inicial: banner de destaque + shelves horizontais.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryAutoRefreshProvider);
    final favorites = ref.watch(favoritesProvider);

    return libraryAsync.when(
      loading: () => StateViews.loading(message: 'Carregando conteudo...'),
      error: (e, _) {
        final msg = e is String ? e : 'Nao foi possivel carregar a playlist.';
        return StateViews.error(
          message: msg,
          onRetry: () =>
              ref.read(libraryRefreshProvider.notifier).state++,
        );
      },
      data: (library) {
        if (library.isEmpty) {
          return StateViews.noSource(
            onAddPlaylist: () => context.go(AppRouter.settings),
          );
        }
        final isTv = MediaQuery.sizeOf(context).width >= 960;
        final featured = library.channels.isNotEmpty
            ? library.channels.first
            : (library.movies.isNotEmpty ? library.movies.first : library.entries.first);

        return RefreshIndicator(
          onRefresh: () async => ref.read(libraryRefreshProvider.notifier).state++,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _HeroBanner(entry: featured, isTv: isTv),
              if (library.channels.isNotEmpty)
                ContentShelf(
                  title: 'Canais ao Vivo',
                  items: library.channels.take(20).toList(),
                  autofocusFirst: isTv,
                  onItemSelected: (e) => openPlayer(context, e),
                ),
              if (library.movies.isNotEmpty)
                ContentShelf(
                  title: 'Filmes',
                  items: library.movies.take(20).toList(),
                  onItemSelected: (e) => openDetail(context, e),
                ),
              if (library.series.isNotEmpty)
                ContentShelf(
                  title: 'Series',
                  items: library.series
                      .map((s) => MediaEntry(
                            id: s.key,
                            title: s.title,
                            url: '',
                            logoUrl: s.logoUrl,
                            type: MediaType.series,
                          ))
                      .take(20)
                      .toList(),
                  onItemSelected: (e) => context.go(AppRouter.series),
                ),
              if (favorites.isNotEmpty)
                ContentShelf(
                  title: 'Seus Favoritos',
                  items: favorites,
                  onItemSelected: (e) => openPlayer(context, e),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.entry, required this.isTv});
  final MediaEntry entry;
  final bool isTv;

  @override
  Widget build(BuildContext context) {
    final height = isTv ? 320.0 : 200.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: FocusableCard(
        borderRadius: 16,
        onSelected: () => openPlayer(context, entry),
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFF1A1A1E),
                const Color(0xFF1A1A1E).withOpacity(0.3),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AuroraColors.accentMagenta,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    entry.isLive ? 'AO VIVO' : 'EM DESTAQUE',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  entry.title,
                  style: TextStyle(
                    fontSize: isTv ? 32 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => openPlayer(context, entry),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Assistir'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AuroraColors.accentCyan,
                    foregroundColor: const Color(0xFF070B14),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
