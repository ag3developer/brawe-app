# 🌍 Brawe App — Implementação Multidioma (i18n)

> **Idiomas alvo:** Português Brasil (`pt_BR`) · Espanhol (`es`) · Inglês (`en`)
> **Estratégia:** Flutter Gen L10n (oficial do SDK) + Riverpod para controle de locale
> **Estimativa total:** ~10–12h de trabalho

---

## 📊 Diagnóstico Atual (maio 2026)

| Item | Status |
|------|--------|
| `flutter_localizations` no pubspec | ❌ Ausente |
| `intl` no pubspec | ❌ Ausente |
| `l10n.yaml` na raiz | ❌ Ausente |
| `MaterialApp` com `localizationsDelegates` | ❌ Ausente |
| Strings hardcoded nas telas | ~195 ocorrências de `Text(...)` |
| Telas/módulos afetados | 29 telas · 15 módulos |
| LocaleNotifier (Riverpod) | ❌ Ausente |
| Tela de seleção de idioma | ❌ Ausente |

---

## 🏗️ Arquitetura Escolhida

```
flutter gen-l10n (SDK oficial)
       │
       ├── lib/l10n/app_pt.arb   ← template (pt_BR)
       ├── lib/l10n/app_es.arb   ← Espanhol
       └── lib/l10n/app_en.arb   ← Inglês
       │
       ▼ (gerado automaticamente)
lib/.dart_tool/flutter_gen/gen_l10n/app_localizations.dart
       │
       ▼
S.of(context).chaveDeTexto   ← uso nas telas
       │
       ▼
LocaleNotifier (Riverpod) → persiste em SharedPreferences
```

**Por que Gen L10n e não `easy_localization`?**
- É oficial do Flutter SDK, zero dependências extras
- Integra nativamente com `MaterialApp`
- Geração de código em tempo de build (type-safe, sem erros em runtime)
- Compatível com Riverpod sem adapters

---

## 📋 ETAPAS DE IMPLEMENTAÇÃO

---

### ETAPA 1 — Dependências e Configuração (⏱ ~30 min)

#### 1.1 · `pubspec.yaml`

Adicionar em `dependencies:`:
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
```

Adicionar em `flutter:`:
```yaml
flutter:
  generate: true   # ← OBRIGATÓRIO para flutter gen-l10n
```

> **Nota:** `shared_preferences` provavelmente já está no projeto para outras funcionalidades.
> Se não estiver, adicionar também: `shared_preferences: ^2.3.2`

#### 1.2 · Criar `l10n.yaml` na raiz do projeto

```yaml
# l10n.yaml  (criar em: brawe-app/l10n.yaml)
arb-dir: lib/l10n
template-arb-file: app_pt.arb
output-localization-file: app_localizations.dart
output-class: S
output-dir: lib/gen/l10n
nullable-getter: false
```

> O `output-class: S` permite usar `S.of(context).chave` — mais curto que `AppLocalizations.of(context).chave`.

#### 1.3 · Criar pasta `lib/l10n/`

```bash
mkdir -p lib/l10n
mkdir -p lib/gen/l10n
```

#### 1.4 · Adicionar `lib/gen/l10n` ao `.gitignore` (opcional)

Arquivos gerados não precisam estar no git:
```gitignore
# i18n generated
lib/gen/l10n/
```

---

### ETAPA 2 — Arquivos ARB (⏱ ~2–3h)

ARB = Application Resource Bundle. É JSON com metadados.

#### 2.1 · `lib/l10n/app_pt.arb` (template — Português Brasil)

```json
{
  "@@locale": "pt",

  "appName": "Brawe",

  "navHome": "Início",
  "navFeed": "Feed",
  "navChat": "Chat",
  "navProfile": "Perfil",

  "tabFollowing": "Seguindo",
  "tabForYou": "Para Você",

  "actionFollow": "Seguir",
  "actionUnfollow": "Seguindo",
  "actionLike": "Curtir",
  "actionComment": "Comentar",
  "actionShare": "Compartilhar",
  "actionSave": "Salvar",
  "actionRepost": "Repostar",
  "actionSend": "Enviar",
  "actionCancel": "Cancelar",
  "actionConfirm": "Confirmar",
  "actionRetry": "Tentar novamente",
  "actionRefresh": "Atualizar",
  "actionDelete": "Excluir",
  "actionEdit": "Editar",
  "actionClose": "Fechar",
  "actionBack": "Voltar",

  "feedEmptyTitle": "Nenhum vídeo por aqui ainda.",
  "feedEmptySubtitle": "Siga creators ou volte mais tarde.",
  "feedFollowingEmptyTitle": "Siga pessoas para ver os posts delas aqui.",
  "feedLoadError": "Não foi possível carregar o feed.",
  "feedNoMore": "Você está em dia! 🎉",

  "profileEditButton": "Editar perfil",
  "profileFollowers": "seguidores",
  "profileFollowing": "seguindo",
  "profileLives": "lives",
  "profileViews": "views",
  "profileJoinedAt": "entrou em {date}",
  "@profileJoinedAt": {
    "placeholders": {
      "date": { "type": "String" }
    }
  },

  "profileTabPosts": "Posts",
  "profileTabVideos": "Vídeos",
  "profileTabSaved": "Salvos",

  "authLogin": "Entrar",
  "authRegister": "Cadastrar",
  "authLogout": "Sair",
  "authEmail": "E-mail",
  "authPassword": "Senha",
  "authForgotPassword": "Esqueceu a senha?",
  "authWelcomeBack": "Bem-vindo de volta!",
  "authCreateAccount": "Criar conta",

  "chatNewMessage": "Nova mensagem",
  "chatPlaceholder": "Mensagem...",
  "chatNoConversations": "Nenhuma conversa ainda.",

  "commentsTitle": "Comentários",
  "commentsPlaceholder": "Adicione um comentário...",
  "commentsEmpty": "Seja o primeiro a comentar.",

  "notificationsTitle": "Notificações",
  "notificationsEmpty": "Nenhuma notificação ainda.",
  "notificationLiked": "{user} curtiu seu post.",
  "@notificationLiked": {
    "placeholders": {
      "user": { "type": "String" }
    }
  },
  "notificationFollowed": "{user} começou a te seguir.",
  "@notificationFollowed": {
    "placeholders": {
      "user": { "type": "String" }
    }
  },
  "notificationCommented": "{user} comentou no seu post.",
  "@notificationCommented": {
    "placeholders": {
      "user": { "type": "String" }
    }
  },

  "settingsTitle": "Configurações",
  "settingsLanguage": "Idioma",
  "settingsTheme": "Tema",
  "settingsThemeDark": "Escuro",
  "settingsThemeLight": "Claro",
  "settingsThemeSystem": "Sistema",
  "settingsAccount": "Conta",
  "settingsPrivacy": "Privacidade",
  "settingsLogout": "Sair da conta",

  "languagePickerTitle": "Escolha o idioma",
  "languagePt": "Português (Brasil)",
  "languageEs": "Español",
  "languageEn": "English",

  "errorNetwork": "Sem conexão. Verifique sua internet.",
  "errorGeneric": "Algo deu errado. Tente novamente.",
  "errorNotFound": "Conteúdo não encontrado.",
  "errorUnauthorized": "Sessão expirada. Faça login novamente.",

  "giftComingSoon": "🎁 Em breve!",
  "liveBadge": "AO VIVO",
  "viewerCount": "{count} assistindo",
  "@viewerCount": {
    "placeholders": {
      "count": { "type": "int" }
    }
  }
}
```

#### 2.2 · `lib/l10n/app_en.arb` (Inglês)

```json
{
  "@@locale": "en",

  "appName": "Brawe",

  "navHome": "Home",
  "navFeed": "Feed",
  "navChat": "Chat",
  "navProfile": "Profile",

  "tabFollowing": "Following",
  "tabForYou": "For You",

  "actionFollow": "Follow",
  "actionUnfollow": "Following",
  "actionLike": "Like",
  "actionComment": "Comment",
  "actionShare": "Share",
  "actionSave": "Save",
  "actionRepost": "Repost",
  "actionSend": "Send",
  "actionCancel": "Cancel",
  "actionConfirm": "Confirm",
  "actionRetry": "Try again",
  "actionRefresh": "Refresh",
  "actionDelete": "Delete",
  "actionEdit": "Edit",
  "actionClose": "Close",
  "actionBack": "Back",

  "feedEmptyTitle": "No videos here yet.",
  "feedEmptySubtitle": "Follow creators or come back later.",
  "feedFollowingEmptyTitle": "Follow people to see their posts here.",
  "feedLoadError": "Could not load the feed.",
  "feedNoMore": "You're all caught up! 🎉",

  "profileEditButton": "Edit profile",
  "profileFollowers": "followers",
  "profileFollowing": "following",
  "profileLives": "lives",
  "profileViews": "views",
  "profileJoinedAt": "joined {date}",
  "@profileJoinedAt": {
    "placeholders": {
      "date": { "type": "String" }
    }
  },

  "profileTabPosts": "Posts",
  "profileTabVideos": "Videos",
  "profileTabSaved": "Saved",

  "authLogin": "Log in",
  "authRegister": "Sign up",
  "authLogout": "Log out",
  "authEmail": "Email",
  "authPassword": "Password",
  "authForgotPassword": "Forgot password?",
  "authWelcomeBack": "Welcome back!",
  "authCreateAccount": "Create account",

  "chatNewMessage": "New message",
  "chatPlaceholder": "Message...",
  "chatNoConversations": "No conversations yet.",

  "commentsTitle": "Comments",
  "commentsPlaceholder": "Add a comment...",
  "commentsEmpty": "Be the first to comment.",

  "notificationsTitle": "Notifications",
  "notificationsEmpty": "No notifications yet.",
  "notificationLiked": "{user} liked your post.",
  "@notificationLiked": {
    "placeholders": {
      "user": { "type": "String" }
    }
  },
  "notificationFollowed": "{user} started following you.",
  "@notificationFollowed": {
    "placeholders": {
      "user": { "type": "String" }
    }
  },
  "notificationCommented": "{user} commented on your post.",
  "@notificationCommented": {
    "placeholders": {
      "user": { "type": "String" }
    }
  },

  "settingsTitle": "Settings",
  "settingsLanguage": "Language",
  "settingsTheme": "Theme",
  "settingsThemeDark": "Dark",
  "settingsThemeLight": "Light",
  "settingsThemeSystem": "System",
  "settingsAccount": "Account",
  "settingsPrivacy": "Privacy",
  "settingsLogout": "Sign out",

  "languagePickerTitle": "Choose language",
  "languagePt": "Português (Brasil)",
  "languageEs": "Español",
  "languageEn": "English",

  "errorNetwork": "No connection. Check your internet.",
  "errorGeneric": "Something went wrong. Please try again.",
  "errorNotFound": "Content not found.",
  "errorUnauthorized": "Session expired. Please log in again.",

  "giftComingSoon": "🎁 Coming soon!",
  "liveBadge": "LIVE",
  "viewerCount": "{count} watching",
  "@viewerCount": {
    "placeholders": {
      "count": { "type": "int" }
    }
  }
}
```

#### 2.3 · `lib/l10n/app_es.arb` (Espanhol)

```json
{
  "@@locale": "es",

  "appName": "Brawe",

  "navHome": "Inicio",
  "navFeed": "Feed",
  "navChat": "Chat",
  "navProfile": "Perfil",

  "tabFollowing": "Siguiendo",
  "tabForYou": "Para Ti",

  "actionFollow": "Seguir",
  "actionUnfollow": "Siguiendo",
  "actionLike": "Me gusta",
  "actionComment": "Comentar",
  "actionShare": "Compartir",
  "actionSave": "Guardar",
  "actionRepost": "Repostear",
  "actionSend": "Enviar",
  "actionCancel": "Cancelar",
  "actionConfirm": "Confirmar",
  "actionRetry": "Intentar de nuevo",
  "actionRefresh": "Actualizar",
  "actionDelete": "Eliminar",
  "actionEdit": "Editar",
  "actionClose": "Cerrar",
  "actionBack": "Volver",

  "feedEmptyTitle": "Aún no hay videos aquí.",
  "feedEmptySubtitle": "Sigue a creadores o vuelve más tarde.",
  "feedFollowingEmptyTitle": "Sigue personas para ver sus posts aquí.",
  "feedLoadError": "No se pudo cargar el feed.",
  "feedNoMore": "¡Estás al día! 🎉",

  "profileEditButton": "Editar perfil",
  "profileFollowers": "seguidores",
  "profileFollowing": "siguiendo",
  "profileLives": "directos",
  "profileViews": "vistas",
  "profileJoinedAt": "se unió en {date}",
  "@profileJoinedAt": {
    "placeholders": {
      "date": { "type": "String" }
    }
  },

  "profileTabPosts": "Posts",
  "profileTabVideos": "Videos",
  "profileTabSaved": "Guardados",

  "authLogin": "Iniciar sesión",
  "authRegister": "Registrarse",
  "authLogout": "Cerrar sesión",
  "authEmail": "Correo electrónico",
  "authPassword": "Contraseña",
  "authForgotPassword": "¿Olvidaste tu contraseña?",
  "authWelcomeBack": "¡Bienvenido de nuevo!",
  "authCreateAccount": "Crear cuenta",

  "chatNewMessage": "Nuevo mensaje",
  "chatPlaceholder": "Mensaje...",
  "chatNoConversations": "Sin conversaciones aún.",

  "commentsTitle": "Comentarios",
  "commentsPlaceholder": "Agrega un comentario...",
  "commentsEmpty": "Sé el primero en comentar.",

  "notificationsTitle": "Notificaciones",
  "notificationsEmpty": "Sin notificaciones aún.",
  "notificationLiked": "{user} le dio me gusta a tu post.",
  "@notificationLiked": {
    "placeholders": {
      "user": { "type": "String" }
    }
  },
  "notificationFollowed": "{user} empezó a seguirte.",
  "@notificationFollowed": {
    "placeholders": {
      "user": { "type": "String" }
    }
  },
  "notificationCommented": "{user} comentó en tu post.",
  "@notificationCommented": {
    "placeholders": {
      "user": { "type": "String" }
    }
  },

  "settingsTitle": "Configuración",
  "settingsLanguage": "Idioma",
  "settingsTheme": "Tema",
  "settingsThemeDark": "Oscuro",
  "settingsThemeLight": "Claro",
  "settingsThemeSystem": "Sistema",
  "settingsAccount": "Cuenta",
  "settingsPrivacy": "Privacidad",
  "settingsLogout": "Cerrar sesión",

  "languagePickerTitle": "Elige el idioma",
  "languagePt": "Português (Brasil)",
  "languageEs": "Español",
  "languageEn": "English",

  "errorNetwork": "Sin conexión. Verifica tu internet.",
  "errorGeneric": "Algo salió mal. Intenta de nuevo.",
  "errorNotFound": "Contenido no encontrado.",
  "errorUnauthorized": "Sesión expirada. Inicia sesión de nuevo.",

  "giftComingSoon": "🎁 ¡Próximamente!",
  "liveBadge": "EN VIVO",
  "viewerCount": "{count} viendo",
  "@viewerCount": {
    "placeholders": {
      "count": { "type": "int" }
    }
  }
}
```

---

### ETAPA 3 — LocaleNotifier + MaterialApp (⏱ ~1h)

#### 3.1 · Criar `lib/config/locale_provider.dart`

```dart
import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_provider.g.dart';

const _kLocaleKey = 'app_locale';

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    // Lê locale salvo, default pt_BR
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(_kLocaleKey);
    return _fromTag(saved) ?? const Locale('pt', 'BR');
  }

  void setLocale(Locale locale) {
    state = locale;
    ref.read(sharedPreferencesProvider)
        .setString(_kLocaleKey, locale.toLanguageTag());
  }

  static Locale? _fromTag(String? tag) {
    if (tag == null) return null;
    final parts = tag.split('-');
    return parts.length >= 2
        ? Locale(parts[0], parts[1])
        : Locale(parts[0]);
  }
}
```

> **Nota:** `sharedPreferencesProvider` já deve existir no projeto. Se não existir, criar:
> ```dart
> @riverpod
> SharedPreferences sharedPreferences(Ref ref) {
>   throw UnimplementedError(); // override em main via ProviderScope
> }
> ```
> E no `main.dart` inicializar com:
> ```dart
> final prefs = await SharedPreferences.getInstance();
> runApp(ProviderScope(
>   overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
>   child: const BraweApp(),
> ));
> ```

#### 3.2 · Atualizar `lib/main.dart`

Adicionar imports:
```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'gen/l10n/app_localizations.dart';
import 'config/locale_provider.dart';
```

Atualizar `MaterialApp.router`:
```dart
return MaterialApp.router(
  title: 'Brawe',
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  themeMode: themeMode,
  routerConfig: router,

  // ── i18n ──────────────────────────────────────────
  locale: ref.watch(localeNotifierProvider),
  supportedLocales: const [
    Locale('pt', 'BR'),
    Locale('es'),
    Locale('en'),
  ],
  localizationsDelegates: const [
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
);
```

---

### ETAPA 4 — Substituição de Strings nas Telas (⏱ ~4–6h)

#### Padrão de uso

```dart
// ANTES
Text('Seguindo')

// DEPOIS
Text(S.of(context).tabFollowing)

// Em widgets sem context direto (usar Builder ou passar context)
Builder(
  builder: (context) => Text(S.of(context).tabFollowing),
)
```

#### Módulos por ordem de prioridade

| Módulo | Pasta | Prioridade |
|--------|-------|-----------|
| Home / ForYou | `ui/home/` | 🔴 Alta |
| Feed | `ui/feed/` | 🔴 Alta |
| Auth | `ui/auth/` | 🔴 Alta |
| Profile | `ui/profile/` | 🟡 Média |
| Chat | `ui/chat/` | 🟡 Média |
| Notifications | `ui/notifications/` | 🟡 Média |
| Settings | `ui/settings/` | 🟢 Baixa |
| Explore | `ui/explore/` | 🟢 Baixa |
| Broadcaster | `ui/broadcaster/` | 🟢 Baixa |
| Quests / Wallet | `ui/quests/`, `ui/wallet/` | 🟢 Baixa |

#### Comando para encontrar strings a migrar

```bash
# Lista todos os Text() com string hardcoded em português
grep -rn "Text('" lib/ui --include="*.dart" | grep -v ".g.dart" | grep -v ".freezed.dart"
```

---

### ETAPA 5 — Tela de Seleção de Idioma (⏱ ~1h)

Adicionar em `lib/ui/settings/` um widget:

```dart
class LanguagePickerSheet extends ConsumerWidget {
  const LanguagePickerSheet({super.key});

  static const _locales = [
    (locale: Locale('pt', 'BR'), label: '🇧🇷  Português (Brasil)'),
    (locale: Locale('es'),       label: '🇪🇸  Español'),
    (locale: Locale('en'),       label: '🇺🇸  English'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeNotifierProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            S.of(context).languagePickerTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ..._locales.map((item) => ListTile(
          leading: Text(item.label, style: const TextStyle(fontSize: 16)),
          trailing: current == item.locale
              ? const Icon(Icons.check, color: Colors.purple)
              : null,
          onTap: () {
            ref.read(localeNotifierProvider.notifier).setLocale(item.locale);
            Navigator.pop(context);
          },
        )),
        const SizedBox(height: 16),
      ],
    );
  }
}
```

---

## 🚀 Comandos de Build

```bash
# 1. Após editar pubspec.yaml
flutter pub get

# 2. Gerar os arquivos de localização
flutter gen-l10n

# 3. Regenerar code generation (Riverpod + Freezed)
dart run build_runner build --delete-conflicting-outputs

# 4. Verificar se compilou sem erros
flutter build apk --debug
```

---

## ⚠️ Pontos de Atenção

1. **`S.of(context)` pode ser null** se o widget for renderizado fora do `MaterialApp`. Usar `S.of(context)?` com null-safety ou `S.of(context)!` apenas em widgets dentro do tree do app.

2. **Strings com parâmetros** usam interpolação no ARB:
   ```dart
   // ARB: "profileJoinedAt": "entrou em {date}"
   S.of(context).profileJoinedAt(date: 'nov. 2025')
   ```

3. **SnackBars e Dialogs** precisam de `context` — garantir que o context seja o correto (não de um estado descartado).

4. **Datas e números** — o `intl` já formata automaticamente com o locale correto:
   ```dart
   // Formato de data automático pelo locale
   DateFormat.yMMMM(Localizations.localeOf(context).toString()).format(date)
   ```

5. **Teste em cada idioma** antes de publicar — rodar com:
   ```bash
   flutter run --dart-define=FLUTTER_APP_LOCALE=es
   ```

---

## 📁 Estrutura Final de Arquivos

```
brawe-app/
├── l10n.yaml                          ← NOVO
├── lib/
│   ├── l10n/
│   │   ├── app_pt.arb                 ← NOVO (template)
│   │   ├── app_en.arb                 ← NOVO
│   │   └── app_es.arb                 ← NOVO
│   ├── gen/
│   │   └── l10n/
│   │       └── app_localizations.dart ← GERADO automaticamente
│   ├── config/
│   │   ├── feature_flags.dart         ← existente
│   │   └── locale_provider.dart       ← NOVO
│   └── main.dart                      ← ATUALIZAR (localizationsDelegates)
```

---

## ✅ Checklist de Execução

- [ ] **ETAPA 1** — `pubspec.yaml` atualizado (`flutter_localizations`, `intl`, `generate: true`)
- [ ] **ETAPA 1** — `l10n.yaml` criado na raiz
- [ ] **ETAPA 2** — `lib/l10n/app_pt.arb` criado
- [ ] **ETAPA 2** — `lib/l10n/app_en.arb` criado
- [ ] **ETAPA 2** — `lib/l10n/app_es.arb` criado
- [ ] **ETAPA 2** — `flutter gen-l10n` executado sem erros
- [ ] **ETAPA 3** — `locale_provider.dart` criado
- [ ] **ETAPA 3** — `dart run build_runner build` executado
- [ ] **ETAPA 3** — `main.dart` atualizado com `localizationsDelegates` e `locale`
- [ ] **ETAPA 4** — Módulo `home/` migrado
- [ ] **ETAPA 4** — Módulo `feed/` migrado
- [ ] **ETAPA 4** — Módulo `auth/` migrado
- [ ] **ETAPA 4** — Módulo `profile/` migrado
- [ ] **ETAPA 4** — Módulo `chat/` migrado
- [ ] **ETAPA 4** — Demais módulos migrados
- [ ] **ETAPA 5** — `LanguagePickerSheet` criado em `settings/`
- [ ] **ETAPA 5** — Opção de idioma adicionada na tela de configurações
- [ ] **Testes** — App testado em pt_BR, en, es
- [ ] **Build** — `flutter build apk --release` sem warnings de localização
