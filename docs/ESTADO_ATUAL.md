# Relatório de continuidade — estado do projeto

> Última atualização: geração inicial do projeto.

## O que foi entregue nesta versão

- [x] Projeto Flutter completo (Dart), estrutura modular em camadas
- [x] Parser M3U/M3U Plus robusto (testado automaticamente)
- [x] Repositórios: playlists, favoritos, configurações (persistência local)
- [x] Player em tela cheia (video_player/Media3) com ciclo de vida, erro, retry
- [x] Telas: Início (shelves + banner), Ao Vivo (categorias), Filmes, Séries
      (temporadas/episódios), Busca local, Favoritos, Configurações, Detalhe
- [x] Navegação adaptativa: bottom nav (celular) / sidebar (TV) + overscan
- [x] Suporte a D-pad/controle remoto (FocusableActionDetector, foco destacado)
- [x] Manifest Android TV (LEANBACK_LAUNCHER, banner, cleartext, leanback=false)
- [x] Testes automatizados: parser (20+ casos), biblioteca/agrupamento,
      favoritos, smoke test de widget
- [x] Workflow GitHub Actions: analyze, testes, APK debug/release, AAB
- [x] Documentação: README, arquitetura, limitações, build, configuração IPTV

## Validado no ambiente de desenvolvimento

- Código escrito e revisado manualmente linha a linha (estrutura, imports,
  tipos, padrões Riverpod/go_router/video_player).
- **Limitação do ambiente:** a sandbox de desenvolvimento apresentou
  instabilidade de rede (pub.dev muito lento) e do shell, impedindo a
  conclusão de `flutter pub get` e, por consequência, de `flutter analyze`
  e `flutter test` localmente. Estes **não foram executados com sucesso**
  neste ambiente — não afirmo que passaram.
- **A validação completa ocorrerá no GitHub Actions** (workflow incluso):
  `flutter analyze --no-fatal-infos`, `flutter test`, e build de APK/AAB.
  Recomenda-se acompanhar a primeira execução do workflow e corrigir qualquer
  aviso de versão de dependência que possa surgir (as versões no pubspec usam
  intervalos `^` e devem resolver no Flutter stable do CI).
- Lógica de parser e agrupamento coberta por testes automatizados
  (a executar no CI).

## Pendente — requer dispositivo / rede / serviços externos

- [ ] Reprodução real de HLS, MPEG-TS e MP4 em dispositivo físico (o ambiente
      de build não executa emulador Android).
- [ ] Teste de foco/D-pad em Android TV real com controle remoto.
- [ ] Importação de arquivo via Storage Access Framework em Android 13+.
- [ ] Build APK/AAB final (acontece no GitHub Actions, não no ambiente local).
- [ ] Assinatura de release com keystore próprio (requer secrets configurados).
- [ ] API Xtream Codes (não implementada; ponto de extensão).
- [ ] EPG / legendas / troca de áudio (não implementado).

## Próximos passos sugeridos (por ordem)

1. Fazer push para o GitHub e confirmar que o workflow gera os APKs.
2. Instalar o APK debug em um celular e validar fluxo completo (adicionar
   playlist → navegar → reproduzir → voltar).
3. Instalar em Android TV e validar navegação por D-pad em todas as telas.
4. Se streams TS problemáticos aparecerem, implementar `MediaKitEngine` como
   alternativa (a abstração `PlayerEngine` já está pronta).
5. Adicionar `flutter_secure_storage` para credenciais.
6. (Opcional) EPG via XMLTV e API Xtream.

## Arquivos criados/alterados

- Raiz: `pubspec.yaml`, `analysis_options.yaml`, `.gitignore`, `README.md`
- `lib/`: 25+ arquivos Dart (main, core, data, player, features, state)
- `android/`: manifest, build.gradle (raiz e app), settings.gradle,
  gradle.properties, MainActivity.kt, recursos (ícones, banner, tema)
- `.github/workflows/build.yml`
- `test/`: 4 arquivos de teste
- `docs/`: 5 documentos
