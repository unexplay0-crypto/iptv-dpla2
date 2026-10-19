import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation_helper.dart';
import '../../state/providers.dart';
import '../widgets/state_views.dart';

/// Favoritos persistidos. Toque reproduz; botao de lixeira remove.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isTv = MediaQuery.sizeOf(context).width >= 960;

    if (favorites.isEmpty) {
      return StateViews.empty(
        icon: Icons.favorite_border,
        title: 'Sem favoritos',
        subtitle:
            'Ao selecionar um conteudo, use o coracao para salvar aqui.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text('Favoritos (${favorites.length})',
              style: TextStyle(
                  fontSize: isTv ? 32 : 24, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: favorites.length,
            itemBuilder: (context, i) {
              final e = favorites[i];
              return _FavoriteRow(
                entry: e,
                onPlay: () => openPlayer(context, e),
                onRemove: () =>
                    ref.read(favoritesProvider.notifier).remove(e.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FavoriteRow extends StatefulWidget {
  const _FavoriteRow(
      {required this.entry, required this.onPlay, required this.onRemove});
  final dynamic entry;
  final VoidCallback onPlay;
  final VoidCallback onRemove;

  @override
  State<_FavoriteRow> createState() => _FavoriteRowState();
}

class _FavoriteRowState extends State<_FavoriteRow> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: FocusableActionDetector(
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPlay();
              return null;
            },
          ),
        },
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        child: GestureDetector(
          onTap: widget.onPlay,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _focused ? Colors.white12 : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: _focused
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.play_circle_outline,
                      color: Colors.white54),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.title as String,
                    style: TextStyle(
                        color: _focused ? Colors.white : Colors.white70,
                        fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white54),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
