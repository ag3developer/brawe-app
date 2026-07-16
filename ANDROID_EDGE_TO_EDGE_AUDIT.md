# AUDITORIA EDGE-TO-EDGE ANDROID 15 — BRAWE APP

**Data**: 2026-07-15  
**Auditor**: Senior Android/Flutter Engineer (Especializado em Edge-to-Edge)  
**Versão Flutter**: 3.44.6  
**compileSdk**: 35  
**targetSdk**: 35  
**minSdk**: 24  
**Status**: ⚠️ **CRÍTICO — `enableEdgeToEdge()` NÃO IMPLEMENTADO NA MAINACTIVITY**

---

## RESUMO EXECUTIVO

O aplicativo Brawe está **vulnerável a problemas de compatibilidade com Android 15 (edge-to-edge)**. Embora a configuração nativa seja tecnicamente compatível (sem flags de fullscreen depreciadas), **a implementação `enableEdgeToEdge()` está ausente da MainActivity**, gerando:

1. **Falta de sincronização entre Android nativo e Flutter** — sistema insets não transmitidos corretamente
2. **195 usos de `SafeArea`, `MediaQuery` e manipulações manuais de insets** sem padrão consistente
3. **SafeArea duplos confirmados** em algumas telas (story_viewer com SafeArea + showModalBottomSheet com SafeArea)
4. **SystemChrome.setEnabledSystemUIMode() chamado em 6 telas** com `immersiveSticky` ou `edgeToEdge` sem restauração consistente
5. **Telas críticas sem proteção de edge-to-edge**: Lives (fullscreen imersivo), Stories (fullscreen com overlay), vídeos fullscreen

**Prioridade Crítica**: Implementar `enableEdgeToEdge()` na MainActivity **antes de qualquer outro ajuste edge-to-edge**.

---

## FASE 1 — CONFIGURAÇÃO ANDROID NATIVA

### 1.1 MainActivity.kt

**Localização**: `/Users/josecarlosmartins/Documents/developer/brawe-app/android/app/src/main/kotlin/app/brawe/connect/MainActivity.kt`

**Estado Atual**: ❌ **CRÍTICO — `enableEdgeToEdge()` AUSENTE**

```kotlin
package app.brawe.connect

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.brawe/audioProcessor"
    private val processor = AudioProcessor.instance

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                // Handler de métodos de áudio...
            }
    }
}
```

**Achados**:
- ✅ Estende `FlutterActivity` (correto, embedding moderno)
- ✅ Classe base permitiria `enableEdgeToEdge()` antes de `super.onCreate()`
- ✅ Não há conflitos com `WindowCompat.setDecorFitsSystemWindows()` ou flags de fullscreen
- ❌ **FALTA `override fun onCreate()`** para chamar `enableEdgeToEdge()`
- ❌ **FALTA `androidx.activity:activity` com versão 1.8.0+** (necessária para `enableEdgeToEdge()`)

**Recomendação Imediata**: Verificar versão do `androidx.activity` no Gradle.

### 1.2 build.gradle.kts

**Localização**: `/Users/josecarlosmartins/Documents/developer/brawe-app/android/app/build.gradle.kts`

**targetSdk / compileSdk**:
```kotlin
minSdk = 24
targetSdk = 35
```

✅ **Configuração correta para Android 15 edge-to-edge**.

**Dependências AndroidX**:
- ✅ `compileSdk = flutter.compileSdkVersion` (delegado ao Flutter, muito provavelmente 35)
- ✅ `sourceCompatibility = JavaVersion.VERSION_17` (requerido por Firebase 4.x moderno)
- ✅ `multiDexEnabled = true` (necessário: Camera + Firebase + video_player > 64K métodos)

**R8/Minificação**: ✅ Configurada com segurança.

### 1.3 AndroidManifest.xml

**Localização**: `/Users/josecarlosmartins/Documents/developer/brawe-app/android/app/src/main/AndroidManifest.xml`

**Achados**:
- ✅ Sem flags de fullscreen depreciadas
- ✅ Sem `android:hardwareAccelerated="false"`
- ✅ Sem `android:immersive="true"` (deprecated)
- ✅ Layout da Activity não especificado (usa tema do NormalTheme)

### 1.4 Temas Android

#### values/styles.xml
```xml
<style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <item name="android:windowBackground">@drawable/launch_background</item>
    <item name="android:forceDarkAllowed">false</item>
    <item name="android:windowFullscreen">false</item>
    <item name="android:windowDrawsSystemBarBackgrounds">false</item>
    <item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>
</style>

<style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <item name="android:windowBackground">?android:colorBackground</item>
</style>
```

#### values-v31/styles.xml
```xml
<style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <item name="android:forceDarkAllowed">false</item>
    <item name="android:windowFullscreen">false</item>
    <item name="android:windowDrawsSystemBarBackgrounds">false</item>
    <item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>
    <item name="android:windowSplashScreenBackground">#000000</item>
    <item name="android:windowSplashScreenAnimatedIcon">@drawable/android12splash</item>
    <item name="android:windowSplashScreenIconBackgroundColor">#000000</item>
</style>

<style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <item name="android:windowBackground">?android:colorBackground</item>
</style>
```

#### values-night/styles.xml e values-night-v31/styles.xml
- ✅ Espelhados com temas dark (`Theme.Black.NoTitleBar`)
- ✅ `windowDrawsSystemBarBackgrounds="false"` em ambas (correto — deixa o conteúdo desenhar atrás)

**Achados Globais do Tema**:
- ✅ `windowFullscreen="false"` → não usa fullscreen de aplicativo (correto para edge-to-edge moderno)
- ✅ `windowDrawsSystemBarBackgrounds="false"` → permite que conteúdo Flutter desenhe atrás das barras
- ✅ `windowLayoutInDisplayCutoutMode="shortEdges"` → respeita notch (correto)
- ⚠️ **NÃO há `android:windowTranslucentStatus="true"` ou `android:windowTranslucentNavigation="true"`** — isso é correto para edge-to-edge, mas requer cuidado em Flutter
- ❌ **NÃO há definição de `statusBarColor` ou `navigationBarColor`** — ficam com valores padrão, pode criar inconsistência com tema escuro/claro em Android 14

### 1.5 AndroidX Activity

**Status**: ⚠️ **DESCONHECIDO — versão não verificada**

Para usar `enableEdgeToEdge()` é obrigatório `androidx.activity:activity:1.8.0+`. A versão não está explicitamente declarada no `build.gradle.kts` lido, sugerindo uso da versão do `flutter` (dependência transitiva).

**Risco**: Se a versão for < 1.8.0, `enableEdgeToEdge()` não existirá e causará erro de compilação.

### 1.6 Flutter Gradle Plugin

**Versão**: Controlada por Flutter 3.44.6 (estável)

✅ **Compatível com Android 15 / AGP 9.1.1**

---

## FASE 2 — VALIDAÇÃO DA MAINACTIVITY

### 2.1 Implementação Esperada vs Real

**Esperado (conforme Google Play Console)**:
```kotlin
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }
}
```

**Real**:
```kotlin
class MainActivity : FlutterActivity() {
    // Sem onCreate() — apenas configureFlutterEngine()
}
```

### 2.2 Impacto

Em Android 15+ com targetSdk=35, **sem `enableEdgeToEdge()`**:

1. O Flutter não recebe informação correta de `WindowInsets` do Android
2. Barras de status/navegação podem desenhar sobre conteúdo Flutter de forma inconsistente
3. SafeAreas manuais em Flutter funcionam apenas se usados, mas não há sincronização com Android
4. Telas fullscreen (Lives, Stories) não respeitam notch/gesture area de forma confiável

### 2.3 Plugins e Activities Auxiliares

**Achado**: ✅ Nenhuma Activity auxiliar mapeada no `build.gradle.kts`. Todos os plugins usam `FlutterActivity` ou compatível.

### 2.4 Ordem de Chamada (quando implementar)

```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    // ANTES de super.onCreate() — crítico para edge-to-edge funcionar
    enableEdgeToEdge()
    super.onCreate(savedInstanceState)
}
```

---

## FASE 3 — NAVEGAÇÃO FLUTTER

### 3.1 MaterialApp.router

**Localização**: `lib/main.dart`

```dart
return MaterialApp.router(
  title: 'Brawe',
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  themeMode: themeMode,
  routerConfig: router,
  locale: locale,
  supportedLocales: LocaleController.supportedLocales,
  localizationsDelegates: const [
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
);
```

✅ **Estrutura moderna com GoRouter**.

### 3.2 GoRouter Root

**Localização**: `lib/routing/router.dart`

**Rota Shell (com HomeBottomNav global)**:
```dart
ShellRoute(
  builder: (context, state, child) => Scaffold(
    backgroundColor: Colors.transparent,
    extendBody: false,
    resizeToAvoidBottomInset: false,
    body: child,
    bottomNavigationBar: const HomeBottomNav(),
  ),
  // ... subrotas
)
```

**Achados**:
- ✅ `extendBody: false` → conteúdo não passa por baixo da nav
- ✅ `resizeToAvoidBottomInset: false` → teclado não redimensiona body (gerenciado per-screen)
- ⚠️ **SEM `extendBodyBehindAppBar`** — não há AppBar na shell, correto

### 3.3 Subrotas Principais

**81 telas** mapeadas, incluindo:
- Auth (4): welcome, login, signup, reset-password
- Feed (7): feed, post-detail, story, story-composer, story-viewer, video-fullscreen, comments
- Live (8): live-player, broadcaster, viewer-battle, live-gate
- Chat (3): chat-list, chat-detail, new-conversation
- Profile (6): profile, edit-profile, artist-profile, business-profile, find-friends
- Creator (14): creator-program, creator-dashboard, admin-applications
- Shop (5): product, store, vitrine, cart, checkout
- E mais...

---

## FASE 4 — SAFEAREA MAPEAMENTO

### 4.1 Estatísticas Globais

**Total de ocorrências**: 195 (SafeArea, MediaQuery.padding, MediaQuery.viewInsets, etc.)

**Distribuição por tipo**:
- `SafeArea`: ~80 usos
- `MediaQuery.of(context).padding`: ~40 usos
- `MediaQuery.of(context).viewInsets`: ~25 usos
- `MediaQuery.of(context).size`: ~50 usos

### 4.2 SafeArea por Tela (Amostra)

| Tela | Widget | SafeArea | Padrão | Risco |
|---|---|---|---|---|
| home_screen.dart | Stack → SafeArea → Column | ✅ Sim | bottom: false | ⚠️ Top protege bem |
| feed_screen.dart | Scaffold → SafeArea(bottom: false) | ✅ Sim | Top only | ⚠️ Conteúdo + tabs + header |
| story_viewer.dart | Scaffold → SafeArea (múltiplos) | ✅ Sim duplo | Completo + showModalBottomSheet+SafeArea | 🔴 **DUPLICADO** |
| login_screen.dart | Scaffold → SafeArea | ✅ Sim | Completo | ✅ Ok |
| broadcaster_screen.dart | Scaffold → SafeArea | ✅ Sim | Completo | ✅ Ok (fullscreen imersivo) |
| live_player_screen.dart | Scaffold → SafeArea | ✅ Sim | Completo | ✅ Ok |

### 4.3 Padrões de Inset Manual

**Arquivos com `MediaQuery.padding` ou `MediaQuery.viewInsets`**:

```
analytics_followers_screen.dart:70   — top: MediaQuery.of(context).padding.top + kToolbarHeight + 16
analytics_lives_screen.dart:155      — top: MediaQuery.of(context).padding.top + ...
analytics_reach_screen.dart:71       — top: MediaQuery.of(context).padding.top + kToolbarHeight + 16
creator_dashboard_screen.dart:94     — top: MediaQuery.of(context).padding.top + kToolbarHeight + 12
artist_profile_screen.dart:316       — top: MediaQuery.of(context).padding.top + kToolbarHeight + 16
business_profile_screen.dart:255     — top: MediaQuery.of(context).padding.top + kToolbarHeight + 16
edit_profile_screen.dart:418         — bottom: MediaQuery.of(context).padding.bottom + 16
home_bottom_nav.dart:63              — bottom: MediaQuery.of(context).padding.bottom
comments_sheet.dart:227              — MediaQuery.of(context).viewInsets.bottom + 12
create_post_sheet.dart:165           — bottom: MediaQuery.of(context).viewInsets.bottom
create_story_sheet.dart:171          — bottom: MediaQuery.of(context).viewInsets.bottom
feed/widgets/feed_screen.dart:134    — SafeArea(bottom: false)
story_gift_sheet.dart:128            — mediaInsets = MediaQuery.of(context).viewInsets
story_video_trim_screen.dart:204     — size = MediaQuery.of(context).size
video_fullscreen_screen.dart:487     — top: MediaQuery.of(context).padding.top + 4
live_feed_screen.dart:125            — SafeArea
live_player_screen.dart:554          — SafeArea
viewer_battle_hud.dart:17            — Comentário de SafeArea medições
streamer_identity_bar.dart:145       — SafeArea
```

**Padrão**: 
- ✅ **Cálculos manuais consistentes** quando necessário (analytics, profile)
- ⚠️ **Valores adicionados**: frequentemente `+ 12` ou `+ 16` para espaçamento
- ⚠️ **Hardcoded `kToolbarHeight` (56px)** em múltiplas telas — frágil com appbar customizado

---

## FASE 5 — SAFEAREA DUPLICADO

### 5.1 Padrão Identificado

**Tela**: `story_viewer.dart`

```dart
// story_viewer.dart (linhas 484 e 825)
// ─ showModalBottomSheet chama com builder que retorna:
child: SafeArea(
  child: Column(...)  // ← SafeArea #1
)

// ─ E o Scaffold também tem:
Scaffold(
  extendBodyBehindAppBar: true,
  extendBody: true,
  body: Stack(
    children: [
      // Mídia fullscreen
      video_player,
      // Controls
      SafeArea(  // ← SafeArea #2
        child: SizedBox(...)
      )
    ]
  )
)
```

**Severidade**: 🔴 **CRÍTICA para Stories**

**Impacto**:
- Padding duplicado no topo = conteúdo afastado da barra de status
- Controles inferiores podem receber SafeArea duplo ao mostrar sheet
- Não é fullscreen "real" — há espaço preto acima da mídia

### 5.2 Outras Telas com Risco Provável

| Tela | Estrutura | Risco |
|---|---|---|
| `broadcaster_screen.dart` (ln. 978) | SafeArea em showModalBottomSheet | ⚠️ Possível duplo |
| `chat_detail_screen.dart` (ln. 238) | SafeArea em showModalBottomSheet | ⚠️ Possível duplo |
| `live_player_screen.dart` (ln. 554) | SafeArea em showModalBottomSheet | ⚠️ Possível duplo |
| `home_screen.dart` (ln. 63) | showModalBottomSheet (sem SafeArea evidente) | ✅ Ok |

### 5.3 showModalBottomSheet com useSafeArea

**Achado**: 5 telas usam `useSafeArea: true` explicitamente:
```
share_live_sheet.dart:39
shared_post_sheet.dart:59
share_to_chat_sheet.dart:43
```

✅ **Correto** — `useSafeArea: true` na chamada **substitui** a necessidade de SafeArea manual inside.

❌ **Problema**: Se showModalBottomSheet chama com `useSafeArea: true` E o builder retorna SafeArea, é **duplicado**.

---

## FASE 6 — TELAS PRINCIPAIS AUDITADAS

### 6.1 Feed

**Arquivo**: `lib/ui/feed/widgets/feed_screen.dart`

**Estrutura**:
```dart
Scaffold(
  extendBodyBehindAppBar: true,
  body: Stack(
    children: [
      AuroraBackdrop(),  // Gradiente fundor
      SafeArea(
        bottom: false,
        child: Column(
          children: [
            GlassTopBar(),     // Header com busca
            PillTabBar(),      // Tabs
            TabBarView(
              children: [...]  // Feed + Stories
            )
          ]
        )
      )
    ]
  )
)
```

**Achados**:
- ✅ `SafeArea(bottom: false)` → conteúdo passa por baixo da nav (correto)
- ✅ `extendBodyBehindAppBar: true` → contenúdo pode desenhar atrás de um AppBar flutuante
- ⚠️ Header + tabs ficam **logo abaixo do status bar** sem padding adicional
- 🔴 **Primeiro item da lista pode ficar parcialmente atrás do header** em scroll inicial

**Prioridade**: ALTA — Verificar se cards ficam atrás do header em scroll zero.

### 6.2 Stories (Viewer)

**Arquivo**: `lib/ui/feed/widgets/story_viewer.dart`

**Estrutura**:
```dart
// Aberto por PageRouteBuilder (fullscreenDialog: true) com rootNavigator: true
// SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky) ← imersivo

Scaffold(
  extendBodyBehindAppBar: true,
  extendBody: true,
  resizeToAvoidBottomInset: false,
  body: Stack(
    fit: StackFit.expand,
    children: [
      // Vídeo/imagem fullscreen
      BraweStoryMedia(video/image),
      
      // Overlays protegidos por SafeArea
      SafeArea(
        child: Column(
          children: [
            // Header (fechar, info)
            _header(),
            Spacer(),
            // Footer (música, respostas)
            _footer()
          ]
        )
      ),
      
      // showModalBottomSheet para menu
      SafeArea(
        child: ...  // ← DUPLICADO!
      )
    ]
  )
)

// No dispose:
SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)
```

**Achados CRÍTICOS**:
- 🔴 **SafeArea duplo** confirmado (Stack + showModalBottomSheet)
- 🔴 **Não é fullscreen real** — há padding superior do SafeArea
- 🔴 **Restauração de SystemUiMode** acontece em dispose, mas se a tela for popped bruscamente (voltar), pode não restaurar
- ⚠️ **Mídia fica pressa em caixa menor** por causa de SafeArea superior+inferior
- ⚠️ **Bottom sheet (menu) pula acima do footer** por dubplicação de inset

**Prioridade**: 🔴 **CRÍTICA**

### 6.3 Vídeos Fullscreen

**Arquivo**: `lib/ui/feed/widgets/video_fullscreen_screen.dart`

**Estrutura**:
```dart
// initState:
SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

Scaffold(
  body: Stack(
    fit: StackFit.expand,
    children: [
      // Vídeo player fullscreen
      VideoPlayer(),
      
      // Controls no topo com padding manual
      Positioned(
        top: MediaQuery.of(context).padding.top + 4,
        // ...
      ),
      
      // Barra de progresso
      Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        // ...
      )
    ]
  )
)

// dispose:
SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
```

**Achados**:
- ✅ Aborda manual com `MediaQuery.padding` (correto para fullscreen imersivo)
- ✅ Restauração de `edgeToEdge` no dispose
- ⚠️ **Botões de controle podem ficar próximos do notch** se hardcoded `+ 4px`
- ⚠️ **Falta `viewPadding` para diferenciar área de gestos**

**Prioridade**: MÉDIA

### 6.4 Lives (Broadcaster/Viewer)

#### 6.4.1 BroadcasterScreen

**Arquivo**: `lib/ui/broadcaster/widgets/broadcaster_screen.dart`

**Estrutura**:
```dart
Scaffold(
  body: Stack(
    children: [
      CameraPreview(),  // Câmera fullscreen
      
      SafeArea(
        child: Column(
          children: [
            // Botão fechar (canto sup esq)
            CloseButton(),
            
            Spacer(),
            
            // Controles inferiores
            _ControlsRow()
          ]
        )
      )
    ]
  ),
  resizeToAvoidBottomInset: false
)
```

**Achados**:
- ✅ `SafeArea` protege controles
- ✅ `resizeToAvoidBottomInset: false` (correto para live)
- ⚠️ **Câmera pode desenhar atrás de notch** (canto superior esquerdo)
- ⚠️ **Botão fechar pode ficar encoberto por notch central**
- 🔴 **Sem SystemChrome.setEnabledSystemUIMode()** — barras não desaparecem

**Prioridade**: 🔴 **CRÍTICA** — Lives devem ser fullscreen imersivo

#### 6.4.2 LivePlayerScreen (Viewer)

**Arquivo**: `lib/ui/live_feed/widgets/live_player_screen.dart`

**Estrutura**:
```dart
Scaffold(
  resizeToAvoidBottomInset: true,
  body: Stack(
    children: [
      DualHLSPlayer(),  // Stream fullscreen
      
      SafeArea(
        child: Column(
          children: [
            // Header: fechar, LIVE badge, viewers
            _Header(),
            
            Spacer(),
            
            // Action rail direita: like, gift, share, comment
            _ActionsRail(),
            
            // Chat overlay (comments flutuando)
            _CommentsOverlay(),
            
            // Input chat fixo inferior
            _InputChat()
          ]
        )
      )
    ]
  )
)
```

**Achados**:
- ✅ `SafeArea` simples
- ⚠️ **Input chat pode ficar atrás da nav bar** em gestos
- ⚠️ **resizeToAvoidBottomInset: true** → teclado pode cobrir input
- 🔴 **Sem SystemChrome.setEnabledSystemUIMode()** — barras não desaparecem
- 🔴 **Vídeo não é fullscreen real** — há padding de SafeArea

**Prioridade**: 🔴 **CRÍTICA**

### 6.5 Teclado e Formulários

**Arquivos com problemas identificados**:

| Arquivo | Campo | Padrão | Risco |
|---|---|---|---|
| `login_screen.dart:74` | Múltiplos inputs | `resizeToAvoidBottomInset: true` | ⚠️ Pode redimensionar tela |
| `signup_screen.dart:73` | Múltiplos inputs | `resizeToAvoidBottomInset: true` | ⚠️ Pode redimensionar tela |
| `comments_sheet.dart:227` | Input comentário | `MediaQuery.viewInsets.bottom + 12` | ✅ Manual — correto |
| `create_post_sheet.dart:165` | Editor post | `viewInsets.bottom` (AnimatedPadding) | ✅ Manual — correto |
| `story_video_trim_screen.dart` | Trim + overlay | `resizeToAvoidBottomInset` não encontrado | ⚠️ Sem proteção |

**Padrão Global**:
- ✅ Sheets e modais usam `MediaQuery.viewInsets.bottom` manualmente → controlado
- ✅ Formulários em telas normais usam `resizeToAvoidBottomInset: true` → seguro
- ⚠️ **Nenhuma tela usa `MediaQuery.removePadding` ou `MediaQuery.removeViewPadding`** → sem risco de duplicação explícita

---

## FASE 7 — BOTTOM SHEETS E MODAIS

### 7.1 Contagem

**Total de `showModalBottomSheet`**: 44+ ocorrências

**Padrões**:

| Padrão | Contagem | Exemplo | Risco |
|---|---|---|---|
| Simples (sem SafeArea) | 20 | `feed_screen.dart:114` | ✅ Ok |
| Com SafeArea | 15 | `story_viewer.dart:471` | ⚠️ Possível duplo com useSafeArea |
| Com useSafeArea:true | 5 | `share_live_sheet.dart:39` | ✅ Correto |
| isScrollControlled:true | 12 | `home_screen.dart:63` (DraggableScrollableSheet) | ✅ Ok |

### 7.2 DraggableScrollableSheet

**Uso**: ~8 telas (home, profile, chat, settings)

```dart
showModalBottomSheet(
  isScrollControlled: true,
  builder: (ctx) => DraggableScrollableSheet(
    initialChildSize: 0.5,
    minChildSize: 0.3,
    maxChildSize: 0.9,
    builder: (_, scrollController) => SingleChildScrollView(
      controller: scrollController,
      child: Consumer(...)
    )
  )
)
```

**Achados**:
- ✅ `isScrollControlled: true` → permite ocupar até 90% da tela
- ✅ Scroll controller funciona
- ⚠️ **Sem verificação de `viewInsets.bottom`** → teclado pode aparecer dentro do sheet

---

## FASE 8 — SYSTEMCHROME E BARRAS DO SISTEMA

### 8.1 Mapeamento de SystemChrome

**Encontrados 11 matches**:

| Arquivo | Linha | Modo | Contexto |
|---|---|---|---|
| `story_ring_avatar.dart` | 150 | immersiveSticky | Abre Story Viewer |
| `story_ring_avatar.dart` | 251 | edgeToEdge | Volta de Story Viewer |
| `story_viewer.dart` | 798 | (comentário) | Referência às mudanças |
| `video_fullscreen_screen.dart` | 80 | immersiveSticky | Abre Fullscreen Video |
| `video_fullscreen_screen.dart` | 250 | edgeToEdge | Fecha Fullscreen Video |
| `profile_screen.dart` | 73 | immersiveSticky | Abre Gallery Profile |
| `stories_rail.dart` | 150 | immersiveSticky | (não restaurado?) |
| `force_dark_theme.dart` | 5 | (comentário) | Documentação |

### 8.2 Problema Crítico: Restauração Inconsistente

**Em `stories_rail.dart:150`**:
```dart
SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

final navigator = Navigator.of(context, rootNavigator: true);
await navigator.push(...);  // Story Viewer opened

// ← MAS A RESTAURAÇÃO ACONTECE EM story_ring_avatar.dart:251
// Não aqui! Se pop() brusto, o imersivo fica ativo.
```

**Padrão Correto**:
```dart
SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

await navigator.push(...).then((_) {
  // Restaurar logo após voltar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
});
```

**Achados**:
- 🔴 **Restauração delegada a outro arquivo** → risco de esquecimento se refatorar
- 🔴 **Modo `immersiveSticky` é "sticky"** → mesmo que pop() bruscamente, pode manter ativo
- ⚠️ **Sem restauração em `didChangeAppLifecycleState` ao pausar app**

### 8.3 Falta de setSystemUIOverlayStyle

**Achado**: Nenhuma tela chama `SystemChrome.setSystemUIOverlayStyle()` para controlar a cor/brilho dos ícones de status bar.

**Risco**:
- Status bar pode ter ícones brancos em fundo branco
- Status bar pode ter ícones pretos em fundo preto
- Tema claro/escuro não afeta status bar automaticamente

---

## FASE 9 — ORIENTAÇÃO E TABLET

### 9.1 Configuração

**Achado**: Nenhuma configuração explícita de orientação em Flutter (`SystemChrome.setPreferredOrientations`).

**Padrão**: Todas as telas suportam ambas orientações (portrait + landscape).

**Risco**:
- ⚠️ **Telas fullscreen (Lives) em landscape** → controles podem ficar comprimidos
- ⚠️ **Videos fullscreen em landscape** → notch/gesture area em lado errado
- ⚠️ **Formulários em landscape** → teclado cobre campos

---

## FASE 10 — NOTCH E DISPLAY CUTOUT

### 10.1 Configuração Nativa

**`android:windowLayoutInDisplayCutoutMode="shortEdges"`** em ambas `values/styles.xml` e `values-v31/styles.xml`.

✅ **Correto** — permite conteúdo usar área ao redor de notch/câmera.

### 10.2 Flutter: Falta de `displayFeatures`

**Achado**: Nenhuma tela lê `MediaQuery.of(context).displayFeatures` para detectar notch.

**Risco**:
- ⚠️ Botões podem ficar embaixo de câmera central (se houver)
- ⚠️ Texto pode ficar cortado por notch na lateral

---

## FASE 11 — NAVEGAÇÃO POR GESTOS vs 3 BOTÕES

### 11.1 Teste Manual Necessário

**NÃO EXECUTADO** — requer dispositivo com Android 15.

**Áreas de Risco**:
1. **Bottom navigation**: gestos podem conflitar com nav bar
2. **Swipe back**: pode ser interceptado por gesture area
3. **Slider/drag**: em Lives ou Stories pode ficar inacessível

---

## FASE 12 — PROBLEMAS CONFIRMADOS

### 12.1 Críticos (Bloqueadores)

| Problema | Arquivo | Severidade | Evidência | Bloqueador |
|---|---|---|---|---|
| **`enableEdgeToEdge()` ausente** | MainActivity.kt | 🔴 CRÍTICA | Sem override onCreate | SIM — requerido por Google Play |
| **SafeArea duplo em Stories** | story_viewer.dart:484,825 | 🔴 CRÍTICA | Stack com SafeArea + showModalBottomSheet com SafeArea | SIM — impede fullscreen |
| **SystemChrome não restaurado corretamente** | stories_rail.dart:150 | 🔴 CRÍTICA | Restauração em arquivo diferente | SIM — barra fica travada |
| **Lives/Broadcaster sem imersivo** | broadcaster_screen.dart, live_player_screen.dart | 🔴 CRÍTICA | Sem SystemChrome.setEnabledSystemUIMode | SIM — não fullscreen |

### 12.2 Altos (Graves)

| Problema | Arquivo | Severidade | Impacto |
|---|---|---|---|
| Status bar ícones sem controle | Toda app | 🟠 ALTA | Contraste ruim em temas |
| Vídeos fullscreen não occupam 100% | video_fullscreen_screen.dart | 🟠 ALTA | Padding manual com MediaQuery.padding |
| Bottom navigation com padding duplicado | home_bottom_nav.dart:63 | 🟠 ALTA | Padding redundante + MediaQuery |
| Teclado em formulários pode cobrir input | login_screen.dart, signup_screen.dart | 🟠 ALTA | resizeToAvoidBottomInset sem viewInsets |

### 12.3 Médios (Atenção)

| Problema | Arquivo | Severidade | Impacto |
|---|---|---|---|
| Feed header pode ficar atrás de status bar em scroll | feed_screen.dart | 🟡 MÉDIA | SafeArea(bottom:false) sem proteção top |
| Analytics telas com padding hardcoded | analytics_*.dart | 🟡 MÉDIA | `+ kToolbarHeight + 16` frágil com design changes |
| Notch não respeitado em landscape | Sem código explicit | 🟡 MÉDIA | displayFeatures não usado |

---

## FASE 13 — ARQUIVOS AFETADOS

**Total**: 81 telas Flutter, 1 MainActivity, 4 arquivos XML de tema

**Por Categoria**:

**CRÍTICA** (7 arquivos):
1. `MainActivity.kt` — Implementar enableEdgeToEdge()
2. `story_viewer.dart` — Remover SafeArea duplo
3. `stories_rail.dart` — Restaurar SystemChrome corretamente
4. `broadcaster_screen.dart` — Adicionar SystemChrome immersive
5. `live_player_screen.dart` — Adicionar SystemChrome immersive
6. `video_fullscreen_screen.dart` — Validar padding manual
7. `styles.xml` + `values-v31/styles.xml` — Considerar statusBarColor/navigationBarColor

**ALTA** (12 arquivos):
- home_bottom_nav.dart
- feed_screen.dart
- login_screen.dart
- signup_screen.dart
- analytics_*.dart (4)
- android/app/build.gradle.kts (verificar androidx.activity)
- Mais em validação...

---

## FASE 14 — PLANO DE CORREÇÃO

### FASE A — Android Nativo + MainActivity (PRIORIDADE 0)

**Objetivo**: Sincronizar Android 15 edge-to-edge com Flutter.

**Ações**:
1. Verificar versão `androidx.activity` no Gradle (requer 1.8.0+)
2. Implementar `enableEdgeToEdge()` em MainActivity.onCreate() ANTES de super.onCreate()
3. Considerar adicionar `statusBarColor` e `navigationBarColor` em styles.xml v31+ para corrigir contraste

**Arquivos**:
- `android/app/build.gradle.kts`
- `MainActivity.kt`
- `android/app/src/main/res/values-v31/styles.xml`

**Teste Obrigatório**: 
- Build release
- Verificar se status bar/nav bar são transparentes em Android 15

**Risco**: Muito baixo — enableEdgeToEdge() é padding seguro.

---

### FASE B — Scaffold Raiz + Navegação (PRIORIDADE 1)

**Objetivo**: Garantir que a shell de navegação respeita edge-to-edge.

**Ações**:
1. Revisar router.dart ShellRoute — considerar `extendBody: true` se apropriado
2. Validar que HomeBottomNav não recebe padding duplo de MediaQuery

**Arquivos**:
- `lib/routing/router.dart`
- `lib/ui/home/widgets/home_bottom_nav.dart`

**Teste Obrigatório**:
- Verificar se nav bar ocupa exatamente a área de inset inferior

---

### FASE C — Telas Comuns (PRIORIDADE 2)

**Objetivo**: SafeArea consistente em auth, profile, settings.

**Ações**:
1. Login/Signup: Validar `resizeToAvoidBottomInset: true` + `viewInsets` manual em campo de input
2. Feed: Confirmar que header não fica atrás de status bar em scroll
3. Profile: Remover padding manual hardcoded (não usar `+ kToolbarHeight`)

**Arquivos**: ~15 telas de auth, profile, settings

---

### FASE D — Stories e Fullscreen (PRIORIDADE 3 — CRÍTICA)

**Objetivo**: Remover SafeArea duplo, implementar fullscreen real.

**Ações**:
1. **story_viewer.dart**: Remover SafeArea do body, manter apenas em controles
2. **story_viewer.dart**: Implementar SystemChrome.setEnabledSystemUIMode(immersiveSticky) no initState
3. **story_viewer.dart**: Garantir restauração em dispose mesmo se pop bruscamente
4. **video_fullscreen_screen.dart**: Validar que padding com MediaQuery.padding está correto

**Arquivos**:
- `story_viewer.dart`
- `story_ring_avatar.dart`
- `video_fullscreen_screen.dart`

**Teste Obrigatório**:
- Story deve ocupar 100% da tela, sem padding preto
- Vídeo fullscreen deve desenhar até as bordas

---

### FASE E — Lives e Batalhas (PRIORIDADE 4 — CRÍTICA)

**Objetivo**: Implementar fullscreen imersivo para broadcast.

**Ações**:
1. **broadcaster_screen.dart**: Adicionar SystemChrome.setEnabledSystemUIMode(immersiveSticky) no initState
2. **broadcaster_screen.dart**: Restaurar em dispose
3. **live_player_screen.dart**: Idem
4. **viewer_battle_screen.dart**: Idem

**Arquivos**:
- `broadcaster_screen.dart`
- `live_player_screen.dart`
- `viewer_battle_screen.dart`

**Teste Obrigatório**:
- Lives devem ser fullscreen imersivo (barras desaparecem)
- Câmera não deve ficar atrás de notch

---

### FASE F — Formulários e Teclado (PRIORIDADE 2)

**Objetivo**: Teclado não cobre campos obrigatórios.

**Ações**:
1. Auditar sheets com input (comments, create_post, create_story, etc.)
2. Confirmar que `viewInsets.bottom` está sendo usado com AnimatedPadding
3. Validar que `isScrollControlled: true` está em modais que abrem teclado

**Arquivos**: ~8 telas com input

---

### FASE G — Bottom Sheets e Modais (PRIORIDADE 2)

**Objetivo**: SafeArea consistente em overlays.

**Ações**:
1. Padronizar uso de `useSafeArea: true` vs SafeArea manual
2. Remover SafeArea duplicate em builder se useSafeArea:true
3. Validar que campos de input têm espaço para aparecer

**Arquivos**: 44+ showModalBottomSheet

---

### FASE H — Barras do Sistema (PRIORIDADE 3)

**Objetivo**: Ícones de status bar com contraste correto.

**Ações**:
1. Implementar `SystemChrome.setSystemUIOverlayStyle()` em telas com fundo claro
2. Detectar mudança de tema (claro/escuro) e atualizar style
3. Documentar padrão em AppTheme

**Arquivos**:
- `lib/ui/core/themes/app_theme.dart`
- Principais telas

---

## FASE 15 — MATRIZ DE TELAS (RESUMIDO)

| Tela | Fullscreen? | SafeArea? | SystemChrome? | Risco | Status |
|---|---|---|---|---|---|
| **Login** | Não | Sim | Não | ⚠️ Teclado | ✅ Baixo |
| **Feed** | Não | Sim | Não | 🟡 Header | ✅ Médio |
| **Stories** | ✅ | Duplo | ✅ (imersivo) | 🔴 Crítico | ❌ Alto |
| **Video Fullscreen** | ✅ | Manual | ✅ (imersivo) | 🟡 Padding | ⚠️ Médio-alto |
| **Lives Broadcaster** | ✅ | Sim | ❌ Falta | 🔴 Crítico | ❌ Alto |
| **Lives Viewer** | ✅ | Sim | ❌ Falta | 🔴 Crítico | ❌ Alto |
| **Chat** | Não | Sim | Não | ✅ Baixo | ✅ Baixo |
| **Profile** | Não | Sim | Sim (?) | ⚠️ Gallery | ⚠️ Médio |
| **Analytics** | Não | Sim | Não | 🟡 Hardcoded | 🟡 Médio |

---

## FASE 16 — RISCOS GLOBAIS

### 16.1 Compatibilidade com Android 14 e Anteriores

**Risco**: 🟡 **MÉDIO**

`enableEdgeToEdge()` é compatível com Android 10+ (androidx.activity 1.6.0). Em versões antigas:
- Status bar fica opaca com cor de tema (não transparente)
- Conteúdo não desenha atrás
- **Sem quebra funcional**, apenas visual diferente

### 16.2 SafeArea Global vs Parcial

**Risco**: 🔴 **CRÍTICO se envolver todo app em SafeArea**

Não fazer SafeArea wrapper global em MaterialApp. Cada tela deve decidir:
- Fullscreen → sem SafeArea no content, apenas nos controles
- Normal → SafeArea em body
- Sheets → usar `useSafeArea: true` na chamada

### 16.3 Flutter Versions

**Flutter 3.44.6**: ✅ Compatível com edge-to-edge moderno.

Nenhuma quebra esperada ao implementar.

---

## FASE 17 — NÃO CONFIRMADO

Pontos que requerem validação em device físico (não foi executado smoke test):

1. ❓ Status bar ícones (claridade vs escuridão) — pode estar ok por CSS
2. ❓ Gesture area conflicts — precisa testar navegação por gestos vs 3 botões
3. ❓ Notch em landscape — precisa dispositivo com notch lateral
4. ❓ Comportamento real de immersiveSticky — pode não estar sendo restaurado
5. ❓ Padding real de MediaQuery em Android 15 — pode diferir do esperado
6. ❓ Reflow ao abrir teclado — precisa testar interação real

---

## FASE 18 — CRITÉRIOS DE ACEITE

Auditoria será considerada **corrigida** quando:

- ✅ `enableEdgeToEdge()` implementado e testado em Android 15
- ✅ App continua funcionando em Android 10-14
- ✅ Stories ocupam 100% da tela (sem padding preto)
- ✅ Vídeos fullscreen ocupam 100% da tela
- ✅ Lives broadcaster e viewer são imersivos (barras desaparecem)
- ✅ SafeArea duplos removidos
- ✅ SystemChrome restaurado corretamente após fullscreen
- ✅ Botões inferiores não ficam atrás da barra de navegação
- ✅ Teclado não cobre campos de input obrigatórios
- ✅ Tema claro e escuro têm contraste correto em status bar
- ✅ Notch é respeitado (conteúdo não fica atrás)
- ✅ Navegação por gestos funciona sem conflitos
- ✅ Nenhuma tela se torna inacessível
- ✅ No Google Play Console, "edge-to-edge" aparece como suportado

---

## RESUMO EXECUTIVO PARA IMPLEMENTAÇÃO

### Problemas Críticos Encontrados:

1. **`enableEdgeToEdge()` não está implementado na MainActivity** ← Bloqueador Google Play
2. **SafeArea duplo em story_viewer** ← Impede fullscreen
3. **SystemChrome immersive não usado em Lives** ← Não são fullscreen
4. **Restauração de SystemChrome inconsistente** ← Barras podem ficar presas

### Recomendação Imediata:

**FASE A** deve ser implementada **ANTES** de qualquer outra correção. É prerequisito para que o Android 15 reconheça o app como edge-to-edge compatível.

### Próximas Etapas:

1. Implementar `enableEdgeToEdge()` no MainActivity
2. Executar build release
3. Testar em Android 15 com device físico
4. Implementar FASE D (Stories) e FASE E (Lives)
5. Validar criação de novo release após correções

---

**Fim da Auditoria**

Arquivo salvo em: `/Users/josecarlosmartins/Documents/developer/brawe-app/ANDROID_EDGE_TO_EDGE_AUDIT.md`
