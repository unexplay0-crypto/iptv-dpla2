# Arquitetura

## Visão geral

Arquitetura em camadas, com separação clara de responsabilidades e dependência
unidirecional (UI → estado → repositórios → fontes de dados).

```
UI (features/)  ──observa──▶  Providers Riverpod (state/)
                                    │
                                    ▼
                         Repositórios (data/repositories/)
                          (Playlist / Favoritos / Settings)
                                    │
                ┌───────────────────┴───────────────────┐
                ▼                                       ▼
     Fontes de dados (datasources/)            Persistência local
      - M3uParser (texto → MediaEntry)          SharedPreferences
      - PlaylistFetcher (http)                   (configs, favoritos,
      - Arquivo local (m3uFile)                   playlists cadastradas)
```

## Gerenciamento de estado

**Riverpod 2.x** (`flutter_riverpod`). Justificativa: compilador seguro,
testável, sem `BuildContext` em lógica, ideal para projeto de tamanho médio.

Providers principais (`lib/state/providers.dart`):
- `libraryAutoRefreshProvider` — `FutureProvider<MediaLibrary>` (conteúdo carregado)
- `libraryRefreshProvider` — contador para forçar recarga
- `favoritesProvider` — `StateNotifierProvider` (favoritos reativos)
- `searchQueryProvider` / `searchResultsProvider` — busca local derivada
- Repositórios e dependências (SharedPreferences, PlaylistFetcher)

`SharedPreferences` é inicializado em `main()` e injetado via `overrideWithValue`.

## Reprodução

Motor abstraído por `PlayerEngine` (`lib/player/player_engine.dart`), com
implementação `VideoPlayerEngine` baseada no pacote oficial `video_player`
(ExoPlayer / AndroidX Media3 no Android). A abstração permite trocar para
`media_kit` (libmpv) sem alterar a UI.

O player garante: uma única instância ativa, liberação de recursos ao sair
(`dispose`), tratamento de timeout (25s), tela de erro com "Tentar novamente",
controles auto-ocultos e suporte a teclas de mídia/D-pad.

## Navegação

`go_router` com `ShellRoute`:
- Rotas internas (Início, Ao Vivo, Filmes, Séries, Favoritos, Busca,
  Configurações, Detalhe) dentro do shell adaptativo.
- Rota `/player` em tela cheia (fullscreenDialog), fora do shell.

## Layout adaptativo

A decisão celular vs TV é baseada na **largura da tela** (breakpoint 960dp),
que coincide com o layout 960×540dp (MDPI) recomendado para Android TV:
- **Celular**: `NavigationBar` inferior, scroll vertical, grades flexíveis.
- **TV**: barra lateral fixa (padrão Leanback), margens de segurança de ~48dp
  laterais / ~27dp verticais (overscan), estados de foco com escala + brilho
  via `FocusableActionDetector` nativo (sem dependência externa).

## Parser M3U/M3U Plus

`M3uParser` (`lib/data/datasources/m3u_parser.dart`):
- Não depende de ordem de atributos, espaços fixos ou formatação única.
- Ignora comentários, linhas vazias e metadados desconhecidos com segurança.
- Inferência de tipo (live/movie/series) por grupo + duração + padrões de
  título (`S01E05`, `2x10`).
- IDs estáveis (hash FNV-1a de url+titulo) para favoritos sobreviverem a
  recargas da playlist.
- Playlists malformadas parciais não encerram o processo.
