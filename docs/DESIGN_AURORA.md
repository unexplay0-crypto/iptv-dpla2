# Plano de Desenvolvimento e Design System — Aurora IPTV

## 1. Pesquisa e referências

Projetos open-source de IPTV em Flutter analisados como base de
funcionamento (arquitetura e player, não código copiado):
**Fred TV Mobile**, **Lotus IPTV**, **easy_tv_live**, **Another IPTV Player**,
**TvNinja**, **SkyStream**. Padrão comum: `video_player` (ExoPlayer/Media3)
com controles customizados, navegação por shelves + sidebar no TV, parser
M3U robusto e persistência local.

Motor de reprodução: `video_player` oficial (leve, estável no CI, suporta
HLS/MP4/MPEG-TS via ExoPlayer). A abstração `PlayerEngine` permite migrar para
`media_kit`/libmpv no futuro se streams TS não padronizados exigirem maior
tolerância — sem alterar a UI.

## 2. Identidade visual única: "Aurora"

Diferencia-se do vermelho Netflix/YouTube e do laranja Plex:
- **Fundo:** espaço profundo `#070B14` com gradiente sutil no topo.
- **Acento:** gradiente ciano `#00E5FF` → violeta `#7C4DFF` (aurora boreal).
- **Destaque ao vivo:** magenta `#FF2D92`.
- **Superfícies:** glassmorphism (branco a 10% translúcido) + cards `#0F1626`.
- **Foco na TV:** borda gradiente + escala 1.06 + brilho ciano (alto contraste).
- **Raio:** 20dp cards, 24dp chips, 14dp botões.
- **Tipografia:** Material 3, fator 1.18x na TV (corpo ≥20sp legível a 3m).

## 3. Arquitetura (mantida da base auditada)

- `core/` — tema Aurora, roteador (go_router ShellRoute + player fullscreen),
  logger com sanitização de credenciais, erros tipados.
- `data/` — parser M3U/M3U Plus robusto (atributos em qualquer ordem, ignora
  linhas ruins, IDs estáveis FNV-1a), fetcher HTTP com timeout/retry,
  repositórios (playlists/favoritos/configurações em SharedPreferences).
- `player/` — `PlayerEngine` abstrato + `VideoPlayerEngine` (ExoPlayer/Media3),
  ciclo de vida correto (dispose ao sair, sem instâncias duplicadas), retry
  limitado, timeout 25s, controles auto-ocultos e teclas D-pad/mídia.
- `features/` — Início (hero + shelves), Ao Vivo, Filmes, Séries (temporadas),
  Busca local, Favoritos, Configurações (URL + arquivo), Detalhe, Player.
- `state/` — Riverpod 2.
- Suporte Android TV: manifest LEANBACK_LAUNCHER + banner + cleartext,
  navegação D-pad via FocusableActionDetector nativo, overscan ~5%.

## 4. Fases executadas

1. Planejamento e pesquisa (esta seção).
2. Base do projeto (pubspec, Android config, manifest TV, workflow CI).
3. Player mínimo com abstração e ciclo de vida.
4. Parser M3U + organização de conteúdo (canais/filmes/séries).
5. Interface completa com design system Aurora.
6. Navegação/foco para Android TV.
7. Testes automatizados (parser, biblioteca, favoritos, widget) + CI.

## 5. Validação

O `flutter analyze`/`test` não puderam rodar localmente (rede da sandbox para
pub.dev estagnada) — validados no GitHub Actions. Código revisado linha a linha;
7 erros de compilação corrigidos em auditoria prévia. Workflow YAML validado
com parser. Compilação e APK gerados pelo Actions.
