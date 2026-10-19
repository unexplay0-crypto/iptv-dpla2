import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Estados de tela (Aurora): carregamento, vazio, erro, fonte nao configurada.
class StateViews {
  StateViews._();

  static Widget loading({String message = 'Carregando...'}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
                color: AuroraColors.accentCyan, strokeWidth: 3),
          ),
          const SizedBox(height: 18),
          Text(message,
              style: const TextStyle(color: AuroraColors.onSurfaceMuted)),
        ],
      ),
    );
  }

  static Widget empty({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AuroraColors.accentGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 44, color: Colors.white),
            ),
            const SizedBox(height: 18),
            Text(title,
                style: const TextStyle(
                    fontSize: 20,
                    color: AuroraColors.onSurface,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 15, color: AuroraColors.onSurfaceMuted),
                  textAlign: TextAlign.center),
            ],
            if (action != null) ...[const SizedBox(height: 24), action],
          ],
        ),
      ),
    );
  }

  static Widget error({
    required String message,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 56, color: AuroraColors.accentMagenta),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(
                    fontSize: 18, color: AuroraColors.onSurface),
                textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget noSource({required VoidCallback onAddPlaylist}) {
    return empty(
      icon: Icons.playlist_add,
      title: 'Nenhuma playlist configurada',
      subtitle:
          'Adicione uma lista M3U/M3U Plus em Configuracoes para comecar a assistir.',
      action: FilledButton.icon(
        onPressed: onAddPlaylist,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar playlist'),
      ),
    );
  }
}
