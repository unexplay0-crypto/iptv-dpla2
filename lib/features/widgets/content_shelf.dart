import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/media_entry.dart';
import 'media_card.dart';

/// "Shelf" horizontal (padrao Leanback/Netflix) com titulo e barra de
/// destaque gradiente Aurora.
class ContentShelf extends StatelessWidget {
  const ContentShelf({
    super.key,
    required this.title,
    required this.items,
    this.onItemSelected,
    this.cardWidth = 160,
    this.autofocusFirst = false,
  });
  final String title;
  final List<MediaEntry> items;
  final void Function(MediaEntry)? onItemSelected;
  final double cardWidth;
  final bool autofocusFirst;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final isTv = MediaQuery.sizeOf(context).width >= 960;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTv ? 16 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: isTv ? 26 : 20,
                  decoration: const BoxDecoration(
                    gradient: AuroraColors.accentGradient,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTv ? 24 : 18,
                    fontWeight: FontWeight.bold,
                    color: AuroraColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: (cardWidth * 9 / 16) + (isTv ? 52 : 46),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final e = items[i];
                return MediaCard(
                  entry: e,
                  width: cardWidth,
                  autofocus: autofocusFirst && i == 0,
                  onSelected: () => onItemSelected?.call(e),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
