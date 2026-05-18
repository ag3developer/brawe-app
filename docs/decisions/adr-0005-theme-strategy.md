# Estratégia de Tema do Brawe — Decisão Final

> Documento que explica por que algumas telas mudam de tema e outras não.

## TL;DR

| Tipo de tela | Comportamento | Por quê |
|---|---|---|
| **Administrativas** (settings, change-password, delete-account, notifications, wallet, quests, change-password, auth) | Respondem a Light/Dark/Auto | São tipo "Ajustes do iPhone" — texto puro, formulários. Faz sentido seguir o tema do sistema. |
| **Mídia / Social** (feed, home, chat, profile, explore, follows, edit-profile, live, stories) | **Sempre Dark** | Padrão da indústria (TikTok, Instagram, Twitch, Kick, BeReal, YouTube Shorts). Conteúdo de vídeo/foto fica melhor sobre fundo escuro; identidade visual da marca exige consistência. |

## Como funciona o toggle de tema

1. Usuário escolhe Light/Dark/Sistema em `/settings` → `ThemeController` atualiza estado → `MaterialApp.themeMode` muda.
2. Telas **administrativas** usam `Theme.of(context)` e `context.colors.*` → trocam visual automaticamente.
3. Telas de **mídia/social** são embrulhadas em `ForceDarkTheme` no `router.dart` → ignoram `themeMode` e usam sempre `AppTheme.dark()`.

## Mapeamento de rotas

### Respondem ao tema (Light/Dark)
- `/welcome`, `/login`, `/signup`, `/forgot-password`, `/reset-password` (auth — usa gradient próprio mas inputs respeitam)
- `/settings`, `/settings/change-password`, `/settings/delete-account`
- `/quests`, `/wallet`, `/notifications`

### Forçadas em Dark (`ForceDarkTheme`)
- `/feed`, `/home`, `/home/classic`
- `/chat`, `/chat/:id`
- `/profile/:id`, `/edit-profile`, `/follows/:id`
- `/explore`
- `/live`, `/live/start`, `/live/broadcast`, `/live/:id`
- Story viewer / composer (overlays)
- Broadcast tools

## Por que NÃO migramos todas as telas para serem light-aware

1. **~970 ocorrências de cor hardcoded** em 19 arquivos de UI complexa — risco enorme de regressão visual.
2. **Padrão consolidado da indústria**: nenhuma rede social de vídeo tem tema light no feed.
3. **Cores hardcoded são intencionais** em muitos casos: branco sobre vídeo, gradients de marca, overlays semitransparentes calibrados para fundo escuro.
4. **Identidade do produto**: o "Brawe Pulse" (gradient purple→cyan→pink) tem contraste correto apenas sobre dark.

## Se no futuro quisermos light em feed/home/etc.

Caminho seguro (semanas de trabalho):
1. Migrar 1 tela por vez para `context.colors.*`.
2. Redesenhar overlays sobre mídia com versões light específicas (ex.: ícones dark com sombra clara em vez de branco com sombra escura).
3. Validar cada tela em ambos os temas com QA visual.
4. Remover `ForceDarkTheme` da rota correspondente.

Está documentado em `CHECKLIST_THEME_MIGRATION.md`.

## Validação rápida que o usuário pode fazer

- Abrir `/settings` → trocar Light/Dark → ver `/settings`, `/wallet`, `/notifications`, `/quests` mudarem.
- Voltar pro feed/home/chat → continuam dark (correto, igual TikTok/Instagram).
