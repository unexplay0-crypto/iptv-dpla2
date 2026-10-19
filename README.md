# IPTV Streamer — App Flutter (Android / Android TV)

Aplicativo IPTV desenvolvido em **Flutter/Dart**, compatível com celulares Android,
tablets e **Android TV / Google TV (Leanback)**. Suporta playlists **M3U / M3U Plus**
(URL ou arquivo local), canais ao vivo, filmes e séries, com player em tela cheia,
favoritos, busca local e navegação por controle remoto (D-pad).

> Projeto construído do zero, com arquitetura modular, foco na **estabilidade do
> player** e compilação automatizada via **GitHub Actions** (APK + AAB).

## Funcionalidades

- Importação de playlist M3U/M3U Plus por **URL** ou **arquivo local**
- Canais ao vivo (com filtro por categoria / grupo)
- Filmes (grade de pôsteres 2:3)
- Séries (agrupamento por temporada/episódio quando identificado no título)
- Busca local instantânea (sem requisição remota a cada caractere)
- Favoritos persistentes
- Player em tela cheia com controles adaptados a toque e D-pad
  (play/pausa, seek ±10s, barra de progresso, auto-ocultação, tratamento de erro)
- Interface adaptativa: **bottom nav no celular**, **barra lateral fixa na TV**
  (com margens de segurança para overscan)
- Estados de foco destacados (escala + brilho) para navegação por controle remoto
- Tratamento de estados: carregando, vazio, erro, fonte não configurada
- Segurança: credenciais (usuário/senha/token) nunca são registradas em logs

## Estrutura do projeto

```
lib/
  main.dart                     # ponto de entrada (ProviderScope + SharedPreferences)
  core/                         # constantes, tema, roteador, logger, erros, detecção TV
  data/
    models/                     # MediaEntry, MediaLibrary, Series, PlaylistSource...
    datasources/                # M3uParser (robusto), PlaylistFetcher (rede)
    repositories/               # Playlist, Favoritos, Configurações
  player/                       # PlayerEngine (abstração) + VideoPlayerEngine (Media3)
  features/                     # telas: home, live, movies, series, search,
                                #         favorites, settings, detail, player, widgets
  state/                        # providers Riverpod
test/                           # testes automatizados (parser, biblioteca, favoritos, UI)
android/                        # configuração Android (manifest com Leanback, banner)
.github/workflows/build.yml     # CI: analyze + testes + APK/AAB
docs/                           # documentação técnica
```

## Compilação

### GitHub Actions (recomendado)

1. Crie um repositório no GitHub e faça push deste projeto.
2. O workflow em `.github/workflows/build.yml` roda automaticamente a cada push
   na branch `main` (ou manualmente em **Actions → Run workflow**).
3. Baixe os artefatos: `apk-debug`, `apk-release`, `app-bundle` (AAB).

Ver detalhes em [`docs/BUILD_E_GITHUB_ACTIONS.md`](docs/BUILD_E_GITHUB_ACTIONS.md).

### Localmente

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug     # APK instalável
flutter build apk --release   # APK release (assinado com chave de debug no CI)
flutter build appbundle       # AAB para Play Store
```

## Configurando uma playlist

1. Abra o app → **Configurações**.
2. **Adicionar por URL**: informe o endereço da sua lista M3U/M3U Plus, ou
   **Importar arquivo**: selecione um arquivo `.m3u`/`.m3u8`.
3. Volte à tela inicial — o conteúdo é carregado automaticamente.

Use apenas playlists de fontes legítimas e às quais você tem direito de acesso.

## Decisões técnicas e limitações

Consulte [`docs/LIMITACOES_E_DECISOES.md`](docs/LIMITACOES_E_DECISOES.md) — inclui
a escolha do motor de reprodução (ExoPlayer/Media3 via `video_player`), suporte
real a HLS/MPEG-TS/MP4, codecs dependentes de dispositivo, e o plano para motor
alternativo (libmpv via `media_kit`) se necessário.

## Documentação complementar

- [`docs/ARQUITETURA.md`](docs/ARQUITETURA.md) — camadas, estado, fluxo de dados
- [`docs/CONFIGURAR_IPTV.md`](docs/CONFIGURAR_IPTV.md) — formatos suportados e dicas
- [`docs/ESTADO_ATUAL.md`](docs/ESTADO_ATUAL.md) — relatório de continuidade
  (o que foi validado, o que depende de teste em dispositivo real)
