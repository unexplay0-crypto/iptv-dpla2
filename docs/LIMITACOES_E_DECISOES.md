# Decisões técnicas e limitações conhecidas

## 1. Motor de reprodução

**Escolhido:** `video_player` (pacote oficial) → no Android utiliza
**ExoPlayer / AndroidX Media3**.

**Justificativa:**
- Oficial, mantido pela equipe Flutter, menor risco de quebra de build.
- Leve (não embuti codecs nativos pesados).
- Suporta HLS (`.m3u8`), MP4 e **MPEG-TS** (extrator TS nativo do ExoPlayer).
- Funciona em Android TV e integra-se bem ao ciclo de vida do Flutter.

**Limitações conhecidas (não afirmar compatibilidade universal):**
- Codecs de vídeo dependem do **dispositivo**: H.264/AVC é universal;
  **H.265/HEVC** só funciona se o hardware tiver decodificador.
- Streams MPEG-TS **não padronizados** ou com falhas de sincronização podem
  falhar no ExoPlayer. Nestes casos, o caminho previsto é trocar o motor para
  `media_kit` (libmpv), que é mais tolerante — a abstração `PlayerEngine`
  foi criada exatamente para permitir essa troca sem alterar a UI.
- Áudio: AAC e MP3 suportados; outros formatos dependem do dispositivo.
- Canais ao vivo **não permitem seek** (a barra de progresso é ocultada
  automaticamente quando `duration == null`).

**Não implementado (planejado para futuras iterações):** EPG (guia de
programação), legendas selecionáveis, troca de faixa de áudio, gravação.

## 2. Fontes de conteúdo

**Suportado:** M3U / M3U Plus por URL e por arquivo local.

**Limitado:** Séries em playlists M3U simples nem sempre trazem temporada/
episódio. O agrupamento é por **heurística** (padrões `S01E05`, `2x10` no
título). Quando a fonte não fornece esses dados, a série aparece como lista
simples. Metadados completos de série exigiriam **API Xtream Codes** (não
implementada; ponto de extensão claro, separado do parser M3U).

**Não inventamos dados:** sinopses, elenco e classificação indicativa não são
exibidos se a fonte não os fornecer. A tela de detalhe mostra apenas os
metadados disponíveis.

## 3. Android TV

**Implementado:** manifest com `LEANBACK_LAUNCHER`, `leanback` feature não
obrigatória (instala também em celular), `touchscreen` não obrigatório, banner
de TV, navegação por D-pad via `FocusableActionDetector`, estados de foco
destacados, margens de overscan.

**Pendente de validação em hardware real:** teste do foco em todos os fluxos
com controle remoto físico, comportamento do botão Voltar em diálogos,
desempenho em boxes com hardware limitado. Estes itens estão no checklist e
devem ser validados em dispositivo real.

## 4. Persistência e segurança

- Configurações, playlists cadastradas e favoritos em `SharedPreferences`.
- **Senhas não são criptografadas** (limitação conhecida do SharedPreferences).
  Para produção, recomenda-se `flutter_secure_storage`.
- URLs com credenciais **nunca são logadas** (`AppLogger.safeUrl` remove
  usuário/senha/token).
- O conteúdo da playlist **não é cacheado em disco** (apenas a referência da
  fonte); é recarregado sob demanda. Isto evita dados obsoletos mas requer
  rede ao abrir o app.

## 5. Performance

- Listas virtualizadas (`ListView`/`GridView`), imagens com cache
  (`cached_network_image`, `memCacheWidth` limitado).
- Parser roda na thread principal; para playlists muito grandes (>50k itens)
  recomenda-se mover o parse para `compute()` (isolado).
- Nenhuma instância duplicada de player: o engine é `dispose` ao sair da tela.

## 6. Riscos técnicos principais (resolvidos ou mitigados)

| Risco | Mitigação |
|---|---|
| Player instável | Abstração `PlayerEngine` + validação prévia; retry limitado (1 tentativa automática + manual) |
| Playlist quebra app | Parser robusto, nunca encerra em linha malformada |
| Build quebra no CI | Workflow com Java 17, Flutter stable, `flutter create` regenera wrapper Gradle |
| Foco perdido na TV | `FocusableActionDetector` em todos os itens navegáveis; autofocus no primeiro item |
| Vazamento de recursos | `dispose` do player em `PopScope`/`deactivate` |
| Credenciais expostas | `safeUrl` em logs; sem credenciais no código-fonte |
