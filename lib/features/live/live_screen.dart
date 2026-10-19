import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation_helper.dart';
import '../../data/models/media_entry.dart';
import '../../state/providers.dart';
import '../widgets/category_chip.dart';
import '../widgets/media_card.dart';
import '../widgets/state_views.dart';

/// Tela de canais ao vivo: filtro por categoria + grade de canais.
class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  String _selectedGroup = 'Todos';

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(libraryAutoRefreshProvider);
    final isTv = MediaQuery.sizeOf(context).width >= 960;

    return libraryAsync.when(
      loading: () => StateViews.loading(),
      error: (e, _) => StateViews.error(
        message: 'Erro ao carregar canais.',
        onRetry: () => ref.read(libraryRefreshProvider.notifier).state++,
      ),
      data: (library) {
        if (library.channels.isEmpty) {
          return StateViews.empty(
            icon: Icons.live_tv,
            title: 'Nenhum canal ao vivo encontrado',
            subtitle: 'Sua playlist pode nao conter canais ao vivo.',
          );
        }
        final groups = ['Todos', ...library.channelGroups.map((g) => g.name)];
        final List<MediaEntry> filtered = _selectedGroup == 'Todos'
            ? library.channels
            : library.channelGroups
                .firstWhere((g) => g.name == _selectedGroup,
                    orElse: () => const MediaGroup(name: '', items: []))
                .items;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Canais ao Vivo',
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
                  final selected = g == _selectedGroup;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CategoryChip(
                      label: g,
                      selected: selected,
                      onTap: () => setState(() => _selectedGroup = g),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? StateViews.empty(
                      icon: Icons.category, title: 'Categoria vazia')
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: isTv ? 200 : 160,
                        childAspectRatio: 16 / 10,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => MediaCard(
                        entry: filtered[i],
                        width: double.infinity,
                        showTitle: true,
                        autofocus: isTv && i == 0,
                        onSelected: () => openPlayer(context, filtered[i]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
