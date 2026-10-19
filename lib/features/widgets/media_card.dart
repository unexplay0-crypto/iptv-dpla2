import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/media_entry.dart';
import 'focusable_card.dart';

/// Cartao de conteudo (canal/filme/episodio) — estilo Aurora: thumbnail
/// com fallback gradiente e letra, cantos arredondados 20dp.
class MediaCard extends StatelessWidget {
  const MediaCard({
    super.key,
    required this.entry,
    required this.onSelected,
    this.width = 160,
    this.showTitle = true,
    this.autofocus = false,
    this.aspectRatio = 16 / 9,
  });
  final MediaEntry entry;
  final VoidCallback onSelected;
  final double width;
  final bool showTitle;
  final bool autofocus;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: FocusableCard(
        autofocus: autofocus,
        onSelected: onSelected,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: aspectRatio,
              child: _Thumbnail(entry: entry),
            ),
            if (showTitle) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  entry.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, height: 1.25, color: AuroraColors.onSurface),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.entry});
  final MediaEntry entry;

  @override
  Widget build(BuildContext context) {
    if (entry.hasLogo) {
      return CachedNetworkImage(
        imageUrl: entry.logoUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, __) => _Fallback(title: entry.title, loading: true),
        errorWidget: (_, __, ___) => _Fallback(title: entry.title),
        memCacheWidth: 400,
      );
    }
    return _Fallback(title: entry.title);
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.title, this.loading = false});
  final String title;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final letter =
        title.trim().isNotEmpty ? title.trim()[0].toUpperCase() : '?';
    return Container(
      decoration: const BoxDecoration(gradient: AuroraColors.accentGradient),
      child: Container(
        color: AuroraColors.surface.withOpacity(0.55),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AuroraColors.accentCyan),
                )
              : Text(
                  letter,
                  style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
        ),
      ),
    );
  }
}
