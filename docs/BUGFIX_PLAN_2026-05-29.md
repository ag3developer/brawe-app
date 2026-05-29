# 🛠️ Laudo Técnico — Plano de Correção (9h)

**Data:** 2026-05-29
**Escopo:** Bugs reportados na build `1.0.10+10` (Brawe Creator Network release)
**SLA estimado:** 4–6h de trabalho efetivo + 1h de teste/build
**Responsável:** próxima sessão

---

## 📋 Resumo executivo

Três bugs identificados, todos com **causa raiz mapeada** e **fix de baixo risco**:

| # | Bug | Severidade | Causa raiz | Esforço |
|---|---|---|---|---|
| 1 | Telas do Creator Network não traduzem (hardcoded PT) | 🔴 Alta | Strings inline em vez de `AppLocalizations` | ~3h |
| 2 | Tela preta ao abrir post compartilhado (comment / view post) | 🔴 Alta | `Navigator.pop` + `context.push` com `BuildContext` desmontado após sheet fechar | ~30min |
| 3 | Pequenas strings hardcoded em telas auxiliares | 🟡 Média | Mesmo problema do #1, mas em escopo menor | ~1h |

**Total: ~5h código + 1h regression test + 1h build/upload = ~7h** → cabe nas 9h.

---

## 🐛 Bug #1 — Creator Network sem tradução (CRÍTICO)

### Sintoma
Usuário com idioma `en` ou `es` selecionado em **Settings → Language** vê várias telas do Creator Network ainda em português:
- `creator_application_status_screen.dart` — "Linha do tempo", "Inscrição enviada", "Decisão final", "Resultado", "Username", "Nicho", "Tier solicitado", "Seguidores"
- `creator_application_form_screen.dart` — labels "Instagram", "TikTok", "YouTube" (ok, são marcas) mas validação/placeholder podem estar PT
- `creator_profile_settings_screen.dart` — mesmo padrão
- `creator_dashboard_screen.dart` — "Atalhos rápidos"
- `creator_badge_screen.dart` — "ATIVO"
- `creator_state_views.dart` — "Tentar novamente"
- `admin_creator_application_detail_screen.dart` — "Cidade", "Idioma", "Telefone", "Score do classificador", "Nicho", "Tier solicitado", "Tier sugerido"
- `creator_hero_card.dart` — "BRAWE CREATOR NETWORK" (marca, OK manter)

### Causa raiz
Quando o módulo Creator Network foi construído, várias strings foram colocadas **inline** (`Text('Linha do tempo')`) em vez de via `AppLocalizations.of(context)!.creatorTimelineTitle`. O arquivo `app_pt.arb` tem **37 chaves a mais** que `app_en.arb` e `app_es.arb` — confirma que o problema é **falta de chaves traduzidas**, não bug no provider de locale.

```
app_pt.arb: 1311 keys
app_en.arb: 1274 keys  ← faltam ~37 chaves
app_es.arb: 1274 keys  ← faltam ~37 chaves
```

### Plano de fix

**Fase 1 — Auditoria (30min)**
```bash
# Extrair todas as strings hardcoded das telas creator
cd lib/ui/creator/widgets
grep -nE "(Text|label|hintText|title|content)\s*:\s*['\"][A-ZÀ-Ü]" *.dart > /tmp/creator_hardcoded.txt
```

Resultado esperado: lista de ~40-60 strings.

**Fase 2 — Criar chaves nos 3 ARBs (1h30)**

Adicionar em `app_pt.arb`, `app_en.arb`, `app_es.arb` (manter **mesma chave** nos três):

```json
// Application Status
"creatorTimelineTitle": "Linha do tempo" | "Timeline" | "Cronología",
"creatorApplicationSubmitted": "Inscrição enviada" | "Application submitted" | "Solicitud enviada",
"creatorFinalDecision": "Decisão final" | "Final decision" | "Decisión final",
"creatorResultLabel": "Resultado" | "Result" | "Resultado",
"creatorUsernameLabel": "Username" | "Username" | "Usuario",
"creatorNicheLabel": "Nicho" | "Niche" | "Nicho",
"creatorRequestedTierLabel": "Tier solicitado" | "Requested tier" | "Tier solicitado",
"creatorSuggestedTierLabel": "Tier sugerido" | "Suggested tier" | "Tier sugerido",
"creatorFollowersLabel": "Seguidores" | "Followers" | "Seguidores",

// Dashboard
"creatorQuickShortcuts": "Atalhos rápidos" | "Quick shortcuts" | "Accesos rápidos",

// Badge
"creatorBadgeActive": "ATIVO" | "ACTIVE" | "ACTIVO",

// State views
"commonRetry": "Tentar novamente" | "Try again" | "Reintentar",  // ← já pode existir, conferir

// Admin
"adminCreatorCity": "Cidade" | "City" | "Ciudad",
"adminCreatorLanguage": "Idioma" | "Language" | "Idioma",
"adminCreatorPhone": "Telefone" | "Phone" | "Teléfono",
"adminCreatorClassifierScore": "Score do classificador" | "Classifier score" | "Puntuación del clasificador",
```

> ⚠️ Antes de criar `commonRetry` etc, **rodar `grep` na ARB existente** para reaproveitar chaves já traduzidas (`tryAgain`, `retry`, etc).

**Fase 3 — Substituir strings inline pelas chaves (1h)**

Padrão de refactor:

```dart
// ❌ Antes
Text('Linha do tempo')

// ✅ Depois
import '../../../l10n/app_localizations.dart';
// ...
final s = AppLocalizations.of(context)!;
Text(s.creatorTimelineTitle)
```

**Fase 4 — Regenerar e validar (15min)**
```bash
flutter gen-l10n
flutter analyze lib/ui/creator/
```

---

## 🐛 Bug #2 — Tela preta ao abrir post do chat (CRÍTICO)

### Sintoma
1. Usuário recebe um post compartilhado no chat (`messageType == 'shared_post'`)
2. Toca no preview → abre `SharedPostSheet` (bottom sheet) ✅
3. Toca em **"View post"** ou **"Comment"** → **tela fica preta** ❌

### Causa raiz
Em `lib/ui/chat/widgets/shared_post_sheet.dart` linhas 183-198:

```dart
void _openFullPost(Post post) {
  Navigator.of(context).pop();      // ← fecha o sheet
  context.push('/post/${post.id}'); // ← context já desmontado!
}

void _openComments(Post post) {
  Navigator.of(context).pop();
  context.push('/post/${post.id}');
}
```

**Problema técnico**:
- `Navigator.pop()` desmonta o widget do bottom sheet imediatamente.
- A linha seguinte chama `context.push(...)` em um `BuildContext` que pertence ao widget **já desmontado** — sem `Overlay`, sem `Router`, sem rota válida.
- Em alguns dispositivos isso lança exception silenciosa; em outros empurra rota órfã que renderiza tela preta.

### Fix (5 linhas)

```dart
void _openFullPost(Post post) {
  final router = GoRouter.of(context); // captura ANTES do pop
  Navigator.of(context).pop();
  router.push('/post/${post.id}');
}

void _openComments(Post post) {
  final router = GoRouter.of(context);
  Navigator.of(context).pop();
  router.push('/post/${post.id}');
}

void _openAuthor(Post post) {
  final router = GoRouter.of(context);
  Navigator.of(context).pop();
  router.push('/profile/${post.author.id}');
}
```

**Alternativa (mais segura, scheduling no próximo frame):**

```dart
void _openFullPost(Post post) {
  Navigator.of(context).pop();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // usar rootNavigator para garantir Router global
    final rootContext = WidgetsBinding.instance.rootElement!;
    GoRouter.of(rootContext as BuildContext).push('/post/${post.id}');
  });
}
```

→ **Recomendo a primeira opção** (mais simples, captura o router antes do pop).

### Validar
Cobrir os 3 callbacks (`_openFullPost`, `_openComments`, `_openAuthor`) — todos têm o mesmo padrão bugado.

---

## 🐛 Bug #3 — Auditoria geral de hardcoded strings (BAIXA prioridade, mas crítico para revisão Apple/Google em outras regiões)

### Sintoma
Outras telas além do Creator Network podem ter strings inline. Lista parcial já identificada acima.

### Plano de auditoria

```bash
# Script de detecção (rodar do root do app):
cd lib

# 1. Encontra Text() com string em PT (acentos como pista)
grep -rnE "Text\(\s*['\"][^'\"]*[áéíóúâêôãõç][^'\"]*['\"]" --include="*.dart" \
  | grep -v "// " \
  | grep -v "_test.dart" \
  > /tmp/hardcoded_pt_strings.txt

# 2. Encontra hint/label/title hardcoded
grep -rnE "(hintText|labelText|title)\s*:\s*['\"][A-ZÀ-Ü]" --include="*.dart" \
  | grep -v "AppLocalizations" \
  > /tmp/hardcoded_labels.txt

wc -l /tmp/hardcoded_*.txt
```

### Prioridade de telas (por uso)

| Tela | Hardcoded count estimado | Prioridade |
|---|---|---|
| `lib/ui/creator/**/*.dart` | ~40-60 | 🔴 P0 |
| `lib/ui/chat/widgets/shared_post_sheet.dart` | poucos | 🟡 P1 |
| `lib/ui/wallet/widgets/gifters_section.dart` | já usa `s.` mas conferir | 🟢 P2 |
| Admin (`admin_*`) | médio | 🟢 P2 (não vai pro user comum) |

---

## 🗓️ Cronograma sugerido (9h totais)

| Hora | Tarefa | Output |
|---|---|---|
| **0:00 – 0:30** | Setup: pull main, branch nova `fix/i18n-and-chat-blackscreen`, rodar app no simulador iOS em PT/EN/ES | Branch criada |
| **0:30 – 1:00** | Bug #2: aplicar fix no `shared_post_sheet.dart` (3 métodos), testar manualmente abrindo post via chat em ambos os fluxos | ✅ Bug #2 resolvido |
| **1:00 – 1:30** | Bug #1 Fase 1: auditoria com `grep` em `lib/ui/creator/` → lista definitiva de strings | `/tmp/creator_hardcoded.txt` |
| **1:30 – 3:00** | Bug #1 Fase 2: criar chaves em `app_pt.arb`, `app_en.arb`, `app_es.arb` | 3 ARBs sincronizados |
| **3:00 – 4:00** | Bug #1 Fase 3: refactor `Text('...')` → `Text(s.chave)` nos arquivos creator | Telas i18n-ready |
| **4:00 – 4:30** | `flutter gen-l10n` + `flutter analyze` → corrigir warnings | 0 errors |
| **4:30 – 5:30** | Bug #3: auditoria geral (script grep) + fix das top-10 strings mais críticas | Cobertura ampliada |
| **5:30 – 6:30** | Regression test manual em 3 idiomas: Welcome → Login → Home → Creator (intro/levels/apply/status/dashboard) → Chat (abrir post compartilhado → view/comment) | Checklist OK |
| **6:30 – 7:00** | Bump versão: `1.0.11+11` no `pubspec.yaml` | Versão pronta |
| **7:00 – 8:00** | Build Android AAB: `flutter clean && flutter pub get && flutter build appbundle --release` | `app-release.aab` |
| **8:00 – 9:00** | Build iOS IPA: `cd ios && pod install && cd .. && flutter build ipa --release` → upload via Transporter | Subido na Apple |

---

## 🧪 Checklist de regression (idiomas)

Repetir para **PT-BR, EN-US, ES-ES**:

### Creator Network
- [ ] `/creator/intro` — título, descrição, benefícios, CTAs traduzidos
- [ ] `/creator/levels` — todos os tiers e descrições
- [ ] `/creator/apply` — labels do form, validação, botão submit
- [ ] `/creator/submitted` — mensagem de confirmação
- [ ] `/creator/status` — "Timeline", "Submitted", "Final decision", "Niche", "Username", "Followers", "Requested tier"
- [ ] `/creator/onboarding` — passos do onboarding
- [ ] `/creator/profile-settings` — labels do form
- [ ] `/creator/badge` — "ACTIVE" badge
- [ ] `/creator/dashboard` — "Quick shortcuts" e cards

### Chat
- [ ] Abrir conversa com post compartilhado
- [ ] Tocar no preview → abre sheet
- [ ] Tocar "View post" → vai pra `/post/:id` ✅ (sem tela preta)
- [ ] Tocar "Comment" → vai pra `/post/:id` ✅
- [ ] Tocar no avatar do autor → vai pra `/profile/:id` ✅
- [ ] Botão back funciona normal

### Empty states & errors
- [ ] "Try again" / "Tentar novamente" / "Reintentar"
- [ ] "No connection" mensagem
- [ ] Loading states

---

## 🔧 Comandos de referência

```bash
# Workdir
cd /Users/josecarlosmartins/Documents/developer/brawe-app

# Branch
git checkout -b fix/i18n-and-chat-blackscreen

# Audit script (Bug #3)
grep -rnE "Text\(\s*['\"][^'\"]*[áéíóúâêôãõç]" lib/ --include="*.dart" \
  | grep -v "_test.dart" > /tmp/hardcoded_pt.txt && wc -l /tmp/hardcoded_pt.txt

# Diff de chaves entre ARBs (deve ser 0 quando terminar)
diff <(jq -r 'keys[]' lib/l10n/app_pt.arb | sort) \
     <(jq -r 'keys[]' lib/l10n/app_en.arb | sort) | head -50

# Gen-l10n
flutter gen-l10n

# Analyze
flutter analyze

# Hot restart (testar UI)
# Pressione R maiúsculo no terminal do flutter run

# Build prod
flutter clean && flutter pub get
flutter build appbundle --release
cd ios && pod install && cd ..
flutter build ipa --release
```

---

## 📊 Critério de aceite

- ✅ `flutter analyze`: **0 errors** (warnings cosméticos OK)
- ✅ `diff` das chaves dos 3 ARBs: **0 diferenças**
- ✅ Manual test em 3 idiomas: todas as telas Creator + chat OK
- ✅ Bug #2: post compartilhado abre sem tela preta nos 3 fluxos
- ✅ AAB + IPA gerados e enviados pra Play Console (internal testing) e TestFlight

---

## 🚨 Riscos & mitigação

| Risco | Probabilidade | Mitigação |
|---|---|---|
| Strings novas quebram layout (texto longo em EN/ES) | Média | Testar em iPhone SE (tela pequena) — strings ES costumam ser 30% mais longas |
| `GoRouter.of(context)` antes do pop ainda falhar | Baixa | Plano B: usar `WidgetsBinding.addPostFrameCallback` |
| Mais bugs hardcoded em telas não auditadas | Alta | Limitar escopo a Creator + Chat agora; #3 vira backlog |
| Build IPA falhar por Pods/signing | Média | Já corrigido na sessão anterior (pod install rodado); manter checklist em `docs/IOS_BUILD_CHECKLIST.md` se útil |

---

## 📌 Pós-correção — não esquecer

1. **Backend `git push`** (`brawe-connect`) — endpoint `/v1/live/eligibility` ainda não está em produção
2. **Release notes** para Play/Apple — usar texto curto definido na sessão anterior
3. **Bump versão**: `1.0.10+10` → `1.0.11+11`
4. **TestFlight invite list** — adicionar emails dos beta testers se ainda não foi feito

---

**Boa noite e bons sonhos! 🌙**
Quando acordar, basta abrir este doc e seguir o cronograma da hora **0:00**.
