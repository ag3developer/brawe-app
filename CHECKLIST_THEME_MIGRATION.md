# Checklist — Migração de Tema (Light/Dark 100%)

> Objetivo: zerar cores hardcoded (`Colors.white`, `Colors.black`, `AppColors.dark*`, etc.) em telas que respondem ao tema, substituindo por tokens de `context.colors.*` (BraweColors ThemeExtension).

## Padrão de substituição

| Hardcoded antigo | Substituto correto |
|---|---|
| `Colors.white` (texto principal) | `context.colors.textPrimary` |
| `Colors.white.withValues(alpha: 0.7)` (texto secundário) | `context.colors.textSecondary` |
| `Colors.white.withValues(alpha: 0.5)` (texto desabilitado) | `context.colors.textMuted` |
| `Colors.white.withValues(alpha: 0.06-0.12)` (divider/border) | `context.colors.borderSubtle` |
| `AppColors.darkBackground` / `Colors.black` (scaffold) | `context.colors.background` |
| `AppColors.darkSurface` (card) | `context.colors.surface` |
| `AppColors.darkSurfaceElevated` | `context.colors.surfaceElevated` |
| `AppColors.electricPurple` (accent) | `context.colors.accentPrimary` |
| `AppColors.coolCyan` (accent secundário) | `context.colors.accentSecondary` |
| `AppColors.mutedRed` (erro) | `context.colors.danger` |
| `AppColors.coolGray` (texto cinza) | `context.colors.textSecondary` |
| Ícone "branco" | `context.colors.iconPrimary` |

Import necessário em cada arquivo migrado:
```dart
import '../../core/themes/brawe_colors.dart'; // expõe extension BraweColorsX
```

---

## P0 — Telas já navegáveis em ambos os temas (migrar primeiro)

- [x] `lib/ui/settings/widgets/settings_screen.dart` (já migrado)
- [ ] `lib/ui/settings/widgets/change_password_screen.dart` (2 ocorrências)
- [ ] `lib/ui/settings/widgets/delete_account_screen.dart` (1 ocorrência)
- [ ] `lib/ui/notifications/widgets/notifications_screen.dart` (11)
- [ ] `lib/ui/quests/widgets/quests_screen.dart` (16)
- [ ] `lib/ui/wallet/widgets/wallet_screen.dart` (24)

## P1 — Telas com `ForceDarkTheme` removido recentemente (URGENTE)

- [ ] `lib/ui/home/widgets/home_bottom_nav.dart` (7)
- [ ] `lib/ui/home/widgets/action_rail.dart` (16)
- [ ] `lib/ui/home/widgets/for_you_screen.dart` (16)
- [ ] `lib/ui/feed/widgets/feed_screen.dart` (38)
- [ ] `lib/ui/follows/widgets/follows_screen.dart` (34)
- [ ] `lib/ui/edit_profile/widgets/edit_profile_screen.dart` (28)
- [ ] `lib/ui/profile/widgets/profile_gallery_grid.dart` (35)
- [ ] `lib/ui/explore/widgets/explore_screen.dart` (42)
- [ ] `lib/ui/chat/widgets/chat_list_screen.dart` (58)
- [ ] `lib/ui/home/widgets/home_screen.dart` (64)
- [ ] `lib/ui/profile/widgets/profile_screen.dart` (113)
- [ ] `lib/ui/chat/widgets/chat_detail_screen.dart` (141)

## P2 — Sheets e composers (abertos como modal a partir de telas P1)

- [ ] `lib/ui/feed/widgets/comments_sheet.dart` (28)
- [ ] `lib/ui/feed/widgets/create_post_sheet.dart` (25)
- [ ] `lib/ui/feed/widgets/stories_rail.dart` (33) — manter trilho dark, migrar avatares
- [ ] `lib/ui/feed/widgets/share_to_chat_sheet.dart`
- [ ] `lib/ui/feed/widgets/create_story_sheet.dart`

## P3 — Mídia immersiva (MANTÉM SEMPRE DARK via `ForceDarkTheme`)

> Não migrar. Padrão TikTok/Instagram Live/Stories: overlays de vídeo são sempre dark.

- [ ] `lib/ui/feed/widgets/story_viewer.dart`
- [ ] `lib/ui/feed/widgets/story_composer_screen.dart`
- [ ] `lib/ui/feed/widgets/story_gift_sheet.dart`
- [ ] `lib/ui/feed/widgets/gift_flight_overlay.dart`
- [ ] `lib/ui/broadcaster/widgets/broadcaster_screen.dart`
- [ ] `lib/ui/broadcaster/widgets/share_live_sheet.dart`
- [ ] `lib/ui/broadcaster/widgets/start_live_screen.dart`
- [ ] `lib/ui/broadcaster/widgets/start_live/vibe_check_bar.dart`
- [ ] `lib/ui/broadcaster/widgets/start_live/warmup_overlay.dart`
- [ ] `lib/ui/live_feed/widgets/for_you_live_list_screen.dart`
- [ ] `lib/ui/live_feed/widgets/live_player_screen.dart`
- [ ] `lib/ui/live_feed/widgets/live_feed_screen.dart`
- [ ] `lib/ui/live_feed/widgets/gift_animation_overlay.dart`
- [ ] `lib/ui/live_feed/widgets/gifts_overlay.dart`
- [ ] `lib/ui/live_feed/widgets/live_comments_overlay.dart`
- [ ] `lib/ui/home/widgets/views/*` (todos os live views)

## Componentes compartilhados (revisar caso a caso)

- [ ] `lib/ui/core/ui/follow_button.dart` — provavelmente usa `accentPrimary` direto
- [ ] `lib/ui/core/ui/app_snackbar.dart` — já deve estar OK
- [ ] `lib/ui/core/widgets/brawe_logo.dart` — provavelmente OK (gradient fixo é da marca)
- [ ] `lib/ui/auth/widgets/common/auth_action_button.dart` — auth fica em fundo gradient, manter
- [ ] `lib/ui/auth/widgets/signup_screen.dart` — auth fica em fundo gradient, manter
- [ ] `lib/ui/edit_profile/widgets/image_position_editor.dart` — editor de imagem, manter dark

---

## Como validar cada arquivo

1. Após editar, rodar `flutter analyze <file>` — zero erros.
2. No simulador, alternar tema em `/settings` e abrir a tela migrada.
3. Verificar: nenhum texto branco em fundo branco, nenhum card preto em fundo claro.
