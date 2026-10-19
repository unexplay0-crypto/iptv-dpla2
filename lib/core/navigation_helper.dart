import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../data/models/media_entry.dart';
import 'router/app_router.dart';

/// Abre o player em tela cheia para um [MediaEntry].
void openPlayer(BuildContext context, MediaEntry entry) {
  final params = {
    'id': entry.id,
    'title': entry.title,
    'url': entry.url,
    'live': entry.isLive ? '1' : '0',
  };
  final uri = Uri(path: AppRouter.player, queryParameters: params);
  context.go(uri.toString());
}

/// Abre a pagina de detalhe de um conteudo.
void openDetail(BuildContext context, MediaEntry entry) {
  final uri = Uri(path: AppRouter.detail, queryParameters: {'id': entry.id});
  context.go(uri.toString());
}
