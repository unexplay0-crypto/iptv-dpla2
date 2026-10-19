import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation_helper.dart';
import '../../data/models/media_entry.dart';
import '../../state/providers.dart';
import '../widgets/category_chip.dart';
import '../widgets/media_card.dart';
import '../widgets/state_views.dart';

/// Tela de filmes: filtro por categoria + grade de capas.
class MoviesScreen extends ConsumerStatefulWidget {
  const MoviesScreen({super.key});

  @override
  ConsumerState<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends ConsumerState<MoviesScreen> {
  String _selectedGroup = 'Todos';

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(libraryAutoRefreshProvider);
    final isTv = MediaQuery.sizeOf(context).width >= 960;

    return libraryAsync.when(
      loading: () => StateViews.loading(),
      error: (e, _) => StateViews.error(
        message: 'Erro ao carregar filmes.',
        onRetry: () => ref.read(libraryRefreshProvider.notifier).state++,
      ),
      data: (library) {
        if (library.movies.isEmpty) {
          return StateViews.empty(
            icon: Icons.movie,
            title: 'Nenhum filme encontrado',
            subtitle: 'Sua playlist pode nao conter filmes sob demanda.',
          );
        }
        final groups = ['Todos', ...library.movieGroups.map((g) => g.name)];
        final List<MediaEntry> filtered = _selectedGroup == 'Todos'
            ? library.movies
            : library.movieGroups
                .firstWhere((g) => g.name == _selectedGroup,
                    orElse: () => const MediaGroup(name: '', items: []))
                .items;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Filmes',
                  style: TextStyle(
                      fontSize: isTv ? 32 : 24, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: groups.length,
                itemBuilder: (context, i) {
                  final g = groups[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CategoryChip(
                      label: g,
                      selected: g == _selectedGroup,
                      onTap: () => setState(() => _selectedGroup = g),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? StateViews.empty(icon: Icons.category, title: 'Categoria vazia')
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: isTv ? 180 : 150,
                        childAspectRatio: 2 / 3, // poster 2:3
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => MediaCard(
                        entry: filtered[i],
                        aspectRatio: 2 / 3,
                        width: double.infinity,
                        autofocus: isTv && i == 0,
                        onSelected: () => openDetail(context, filtered[i]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
