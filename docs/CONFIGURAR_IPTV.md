# Configurando fontes IPTV

## Formatos suportados

- **M3U / M3U Plus** por URL (ex.: `https://servico.com/get.php?username=X&password=Y&type=m3u_plus&output=ts`)
- **Arquivo local** `.m3u` / `.m3u8` / `.txt` (importado e salvo no armazenamento do app)

## Como adicionar

1. App → **Configurações** → **Adicionar por URL** (ou **Importar arquivo**).
2. Para URL: cole o endereço completo (com credenciais, se houver). Dê um nome.
3. Toque em **Adicionar URL**. O app baixa e parseia a lista.
4. A playlist adicionada é selecionada automaticamente. Volte ao Início.

## Diferença importante: URL de playlist vs URL de canal

O endereço `get.php?...&output=ts` é uma **playlist** (lista de canais). O app
baixa esse texto, extrai cada entrada e obtém a **URL individual de cada canal**.
Nunca tenta reproduzir o endereço da playlist diretamente.

O parâmetro `output=ts` indica apenas a preferência de formato do serviço;
não significa que a URL seja um vídeo direto.

## Atributos M3U Plus reconhecidos

- `tvg-id`, `tvg-name`, `tvg-logo`, `group-title` (em qualquer ordem)
- `#EXTGRP` (grupo alternativo)
- Outros atributos são armazenados em `attributes` mas ignorados com segurança.

## Resolução de problemas

- **"Nenhum item válido"**: verifique se a URL retorna texto M3U (abra no
  navegador). Alguns serviços exigem User-Agent específico — o app envia
  `IPTVStreamer/1.0`.
- **Canal não reproduz**: pode ser codec não suportado (ex.: HEVC em hardware
  antigo) ou stream TS não padronizado. Tente outro canal; se muitos falharem,
  avalie migrar o motor para `media_kit` (ver LIMITACOES_E_DECISOES.md).
- **Playlists grandes**: o app processa tudo; a primeira carga pode demorar
  alguns segundos. Use busca para encontrar conteúdo rapidamente.

## Aviso legal

Utilize apenas conteúdo e serviços para os quais você possui direitos de acesso
legítimos. O desenvolvedor do app não fornece conteúdo.
