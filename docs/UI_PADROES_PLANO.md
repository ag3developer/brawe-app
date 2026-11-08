# Brawe App — padronização de UI (plano e andamento)

Este documento é a fonte para continuar o trabalho em qualquer chat novo. Leia-o inteiro antes de mexer.
Atualize a coluna **Situação** ao terminar cada item.

## Padrões (valem para todo o app)

- **Ícones:** só `lucide_icons_flutter` (versão 3.1.15, classe `LucideIcons`).
  - Não use `Icons.*` do Material. Única exceção: ícones que o Lucide não tem; nesse caso deixe um comentário.
  - Ícones de marca (Instagram, TikTok…) não existem nessa versão do pacote. Use os neutros: `camera`, `atSign`, `music2`, `circlePlay`, `globe`.
- **Cores:** sempre `context.colors.*`, em `lib/ui/core/themes/brawe_colors.dart`. Tokens:
  - `background`, `surface`, `surfaceElevated`, `surfaceHighest`
  - `textPrimary`, `textSecondary`, `textTertiary`, `textOnAccent`
  - `border`, `divider`
  - `accentPrimary`, `accentSecondary`, `accentPink`, `accentGold`
  - `success`, `warning`, `danger`, `overlay`
  - Não use `Color(0x…)` nem `Colors.*` fixos em telas. Exceções: telas sobre vídeo ou foto (branco/preto com transparência) e cores de marca de terceiros.
- **Listas de ajustes:** use `lib/ui/core/ui/grouped_list.dart` (`GroupedBody`, `GroupedSection`, `GroupedRow`, `GroupedField`, `groupedInput`).
  - Visual: cartões cinza, legenda pequena em maiúsculas, valor atual à direita, seta.
  - Referências prontas: `settings_screen.dart`, `edit_profile_screen.dart`, `lib/ui/account/*`.
- **Textos:**
  - Sempre `S.of(context)`, em pt, en e es (`lib/l10n/app_pt.arb` é o modelo).
  - Texto livre usa `textCapitalization: TextCapitalization.sentences`. E-mail, senha, @usuário, links e códigos usam `none`.
- **Máscaras:** `lib/ui/core/ui/mask_formatter.dart` (`DigitMask.cpf/cnpj/cep/phoneBr`).
- **Avisos e erros:**
  - Sempre na tela em que a pessoa está (no próprio sheet ou diálogo, ou no `ScaffoldMessenger` capturado antes de navegar). Nunca numa tela que já ficou para trás.
  - A mensagem diz o motivo e o que fazer.
- **Emojis:** só como conteúdo (reações, seletor de emoji, texto de pessoas). Nunca como ícone de interface.
- **Responsivo:** conteúdo com no máximo 640 px de largura em tablet (`ConstrainedBox(maxWidth: 640)`).
- **Navegação:** barra flutuante em `lib/ui/home/widgets/home_bottom_nav.dart`.
  - `navCompactProvider` compacta a barra ao rolar.
  - Só o Feed usa `extendBody`.

## Regras de trabalho (importante)

- **Pasta do app:** `/Volumes/SSD 240GB EXTERNO/Documentos/developer/brawe-app`.
- **Git:**
  - Nunca use `git checkout` nem `git restore` puros. Use `git -c core.hooksPath=/dev/null restore --source=HEAD -- <arquivo>`.
  - Não comite `linux/`, `macos/`, `windows/`, `PLAY_CONSOLE_UPLOAD_GUIDE.md` nem `RELEASE_NOTES_1.0.35.md`.
- **Comandos `flutter`:**
  - Não rode com o Xcode compilando.
  - Depois de `flutter gen-l10n`, confira se `ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift` tem `.iOS("16.6")` ou `.iOS("15.5")`. Nunca 13.0.
- **Agentes em paralelo:** não editam os `.arb`. Cada um grava as chaves novas em JSON separado e o coordenador junta tudo antes do `flutter gen-l10n`.
- **Checagem:** `dart analyze <arquivos>`. Rode `dart format` só nos arquivos que você mudou.
- **Publicar:**
  - Commit, push e deploy só quando o dono pedir.
  - Backend Connect: `cd Brawe/brawe-connect && ./deploy.sh --api`.
  - Site e painel: `git push origin HEAD:main` no repositório Brawe.

## Itens

| # | Item | Arquivos principais | Situação |
|---|------|---------------------|----------|
| 1 | **Emojis viram "?"** em nomes, bios e legendas (fonte sem fallback de emoji) | tema (`lib/ui/core/themes/*`, `main.dart`) | **conferir no iPhone real**: o app não usa fonte própria; provável bug do Simulador do iOS (Impeller). Se aparecer no aparelho, investigar |
| 2 | **Perfil refeito**: abas só com ícones (grade · vídeos · reposts), abre na grade, cabeçalho com números (posts · seguidores · seguindo), esconde "0 views", botões padrão, cores do tema, Lucide | `lib/ui/profile/widgets/profile_screen.dart`, `profile_videos_grid.dart` | **feito** (08/11, sem commit) |
| 3 | **Ícones unificados em Lucide**: chat, criar story, iniciar live, live, story viewer e demais | `lib/ui/chat/**`, `lib/ui/feed/widgets/story_*`, `lib/ui/broadcaster/**`, `lib/ui/live/**` | **feito** (08/11, sem commit) |
| 4 | **Notificações**: grupos "Hoje / Esta semana / Antes", ações na linha (Seguir de volta, miniatura do post), cores do tema | `lib/ui/notifications/**` | **feito** (08/11, sem commit) |
| 5 | **Cores do tema** nas telas restantes: missões, balões especiais do chat, fim de live, painel de áudio | `lib/ui/quests/**`, `chat/widgets/rich/chat_rich_bubbles.dart`, `live_feed/widgets/live_ended_view.dart`, `broadcaster/widgets/audio_processor_panel.dart` | **feito** (08/11, sem commit) |
| 6 | **Loja**: trocar emojis usados como ícone por Lucide (checkout e pagamento) | `lib/ui/shop/pages/shop_checkout_page.dart`, `shop_payment_page.dart` | **feito** (08/11, sem commit) |
| 7 | **Carteira, Segurança e Sacar** no padrão de lista agrupada | `lib/ui/wallet/**`, `lib/ui/settings/widgets/security*`, `creator/widgets/monetization/*withdraw*` | **feito** (08/11, sem commit) |
| 8 | 9 textos fixos sem tradução | `creator/widgets/analytics_lives_tab.dart`, `broadcaster/widgets/share_live_sheet.dart`, `home/widgets/views/shared/_live_peek.dart` | **feito** (08/11, sem commit) |
| 9 | Varredura de avisos mostrados na tela errada (SnackBar depois de `pop`/`go`, ou atrás de sheet) | app todo | a fazer |

## Já feito nesta etapa (para contexto)

Commits recentes no app:
- `15ba019`: cadastro "Sobre você" e gênero no Ads.
- `a0ebede`: vídeo até 500 MB, avisos na tela certa e correção da tela vermelha do onboarding.
- `8a31475`: verificação de conta, Editar perfil e Configurações refeitos.

Ainda sem commit:
- Barra de navegação flutuante (`home_bottom_nav.dart`, `router.dart`, folga do feed).
- Reordenação das ações do post (enviar junto das interações, salvar à direita, "Impulsionar" na linha de visualizações).

## Como os agentes entregam

Cada agente grava as chaves novas em `scratchpad/l10n_<tag>_{pt,en,es}.json`. As tags são `prof`, `chatx`, `livex`, `notifx` e `money`.
Ao terminarem:
1. Juntar os JSONs nos três `.arb`.
2. Rodar `flutter gen-l10n`.
3. Rodar `dart analyze lib`.
4. Conferir o Package.swift.
5. Commit, depois que o dono aprovar.

Se o chat novo não tiver esses JSONs, procure no código os `S.of(context).<chave>` que ainda não existem e crie as chaves.

## Situação em 08/11 (fim do dia)

Itens 2 a 8 estão feitos e integrados:
- Traduções juntas nos `.arb`.
- `flutter gen-l10n` rodado.
- `dart analyze lib` sem erros nem avisos.
- 727 testes passando. Testes ajustados: traduções nos testes da live, simulação da loja/IAP e do KYC.

Também feito:
- Barra flutuante com regra de quando aparece (some nas telas de tarefa) e faixa sem preto.
- Português padronizado de "creator/badge" para "criador/selo". Os nomes do programa (Brawe Creator Network, níveis Rising/Featured/Live/Founding) foram mantidos.

Nada disso foi commitado ainda: falta o dono aprovar no simulador.

**Pendências:**
- Perfil: o número de posts conta só os carregados. Precisa de `posts_count` no `/profile/{id}` do Connect (backend + deploy).
- Chat: "Tentar de novo" dentro da bolha que falhou. Hoje o erro aparece num aviso no topo da conversa. Exige estado de falha no `ChatMessage` e no view model.
- Loja: vitrine, produto e carrinho ainda têm cores fixas. Cadastro da conta de saque ainda fora do padrão de cartões.
- Checkout: decidir os campos opcionais (apelido, complemento, telefone). Live: "mensagem (opcional)" ao compartilhar.
- Textos fixos que restam: `analytics_lives_tab` (alguns), `send_gift_view_model` e `live_room_comments_view_model` (sem contexto de tradução).
- Item 9 (avisos na tela errada): os agentes corrigiram nas telas que mexeram (start live, compartilhar live, checkout, segurança). Falta a varredura no resto do app.
