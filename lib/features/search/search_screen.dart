import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation_helper.dart';
import '../../state/providers.dart';
import '../widgets/media_card.dart';
import '../widgets/state_views.dart';

/// Busca local sobre o conteudo carregado (sem requisicao remota).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (MediaQuery.sizeOf(context).width < 960) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final isTv = MediaQuery.sizeOf(context).width >= 960;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: !isTv,
            style: TextStyle(fontSize: isTv ? 22 : 16),
            decoration: InputDecoration(
              hintText: 'Buscar canais, filmes, series...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white10,
            ),
            onChanged: (v) =>
                ref.read(searchQueryProvider.notifier).state = v,
          ),
        ),
        Expanded(
          child: results.when(
            loading: () => StateViews.loading(),
            error: (e, _) => StateViews.error(message: 'Erro na busca.'),
            data: (items) {
              if (_controller.text.trim().isEmpty) {
                return StateViews.empty(
                  icon: Icons.search,
                  title: 'Digite para buscar',
                  subtitle:
                      'A busca e local e instantanea sobre sua playlist.',
                );
              }
              if (items.isEmpty) {
                return StateViews.empty(
                  icon: Icons.search_off,
                  title: 'Nenhum resultado',
                  subtitle: 'Tente palavras-chave diferentes.',
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: isTv ? 200 : 160,
                  childAspectRatio: 16 / 10,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) => MediaCard(
                  entry: items[i],
                  width: double.infinity,
                  autofocus: isTv && i == 0,
                  onSelected: () {
                    if (items[i].url.isNotEmpty) {
                      openPlayer(context, items[i]);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
