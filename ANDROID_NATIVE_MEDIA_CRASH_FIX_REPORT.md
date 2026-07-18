# 🔧 ANDROID NATIVE MEDIA CRASH — FIX REPORT (Lifecycle-Only)

**Data:** 17 de julho de 2026
**Escopo:** Correções de **lifecycle** no `BroadcasterScreen` (RootEncoder/EGL,
Crash B). **Nenhuma dependência foi atualizada.** Nenhuma alteração foi feita
no MDK/FVP/legenda (Crash A) — as afirmações do relatório anterior sobre
`subtitle.enabled`/`subtitle.decoders` foram **invalidadas por evidência** e
retiradas (ver seção 1).
**Build:** `flutter build apk --release` executado com sucesso.
**Publicação:** Não realizada (fora de escopo).

---

## 1. Validação das afirmações do relatório anterior

O documento `ANDROID_NATIVE_MEDIA_CRASH_AUDIT.md` (auditoria original) continha
duas afirmações que foram verificadas contra o **código-fonte real
decompilado** (não a documentação/README do pacote, não o branch master do
GitHub) antes de qualquer implementação, conforme exigido.

### 1.1. `subtitle.enabled` / `subtitle.decoders` no FVP — **REFUTADO**

Decompilei `fvp-0.37.3` (`~/.pub-cache/hosted/pub.dev/fvp-0.37.3/lib/fvp.dart`,
`controller.dart`, `player.dart`):

- A docstring completa de `registerWith({dynamic options})` lista **todas** as
  chaves suportadas: `platforms`, `fastSeek`, `video.decoders`, `maxWidth`,
  `maxHeight`, `lowLatency`, `player`, `global`, `tunnel`,
  `subtitleFontFile`. **Não existe `subtitle.enabled` nem
  `subtitle.decoders`.**
- A única API real para influenciar a legenda é
  `VideoPlayerController.setSubtitleTracks(List<int>)` (extensão
  `FVPControllerExtensions` em `controller.dart`), que delega para
  `Player.activeSubtitleTracks` (`player.dart`, linha ~340). Isso define
  *quais tracks* ficam ativas — não é um "desabilitar decoder" global e nunca
  foi testado/confirmado como mitigação do SIGSEGV (não há evidência do
  Crashlytics — URL, codec, presença real de legenda — disponível).
- **Conclusão:** a causa do Crash A (SIGSEGV em
  `mdk::abi::SubtitleDecoder::decoded()`) permanece **NÃO CONFIRMADA**. Não
  implementei nenhuma opção inexistente. Isso está registrado em
  `/memories/repo/native-media-crash-investigation.md` para não repetir o erro.

### 1.2. `controller.value.isInitialized` como prova de Surface EGL pronta — **REFUTADO**

Decompilei o AAR **realmente resolvido pelo Gradle** (não o código do GitHub
`pedroSG94/RootEncoder`, que é uma API diferente/mais nova):

```
~/.gradle/caches/modules-2/files-2.1/com.github.pedroSG94.rtmp-rtsp-stream-client-java/
  ├── rtplibrary/1.9.6/.../rtplibrary-1.9.6.aar
  └── encoder/1.9.6/.../encoder-1.9.6.aar
```

Achado central (via `javap -c -p` no bytecode real, cruzado com o código Kotlin
do plugin `rtmp_broadcaster` em
`~/.pub-cache/hosted/pub.dev/rtmp_broadcaster-2.3.4/android/`):

1. O handler de método channel realmente ativo é `MethodCallHandlerImplNew.kt`
   (registrado em `RtmppublisherPlugin.kt`) — **não** o `Camera.kt`/
   `MethodCallHandlerImpl.kt` legado (código morto, nunca instanciado).
2. `"initialize"` no method channel chama `instantiateCamera()`, que
   apenas: calcula `previewSize`, popula um `Map` de retorno, e chama
   `getCameraView()?.startPreview(cameraName)` — **isso não cria a Surface**.
   A Surface só é criada quando o Flutter monta o `AndroidView` Dart
   (`CameraPreview` widget, `viewType: 'hybrid-view-type'`), o que só
   acontece **depois** que `setState(() => _isInitialized = true)` provoca
   um rebuild e o `CameraPreview` entra na árvore.
3. Só então o Android chama `CameraNativeView.surfaceCreated(holder)`
   (`CameraNativeView.kt`), que finalmente chama `startPreview()` de novo —
   e é o **thread de GL interno do `RtmpCamera2`/`LightOpenGlView`**
   (`OpenGlViewBase.run()`, decompilado) que instancia
   `new SurfaceManager(holder.getSurface())` → `eglSetup(...)` (privado, uma
   única assinatura `eglSetup(int,int,Surface,EGLContext)` na versão real
   1.9.6 — diferente das múltiplas sobrecargas públicas do RootEncoder
   master atual no GitHub).
4. **Não existe nenhum evento exposto ao Dart** que confirme "Surface
   pronta"/"EGL pronto". O `EventChannel` `cameraEvents$id` só emite:
   `error`, `camera_closing`, `rtmp_connected`, `rtmp_retry`, `rtmp_stopped`,
   `rotation_update` (`DartMessenger.kt` + `_listener()` em `camera.dart`).

**Conclusão:** `controller.value.isInitialized == true` prova apenas que a
plataforma aceitou os parâmetros de câmera — **nunca** que a Surface/EGL
nativa está pronta. Por isso a correção implementada:
- **não** trata esse booleano como garantia técnica (documentado
  explicitamente no código, ver `_setupCameraController`);
- usa apenas como *um dos* sinais para liberar a UI (estado `previewReady`),
  combinado com **guards de estado explícito + serialização + try/catch
  defensivo em toda chamada nativa** — que é o que realmente elimina as
  classes de bug identificadas (chamada duplicada, chamada após dispose,
  chamada durante teardown de background), independentemente de quando a
  Surface real fica pronta;
- **não** usa `Future.delayed` fixo como prova de nada — o único delay que já
  existia no plugin nativo (`Handler().postDelayed(..., 100)` dentro de
  `instantiateCamera`) é interno ao plugin e fora do nosso controle; no lado
  Dart, nenhum `Future.delayed` foi introduzido como substituto de validação.

---

## 2. O que foi implementado (somente lifecycle)

Arquivo alterado: `lib/ui/broadcaster/widgets/broadcaster_screen.dart`
(+523 / -95 linhas). **Nenhuma dependência atualizada** (`fvp`,
`video_player`, `camera`, `rtmp_broadcaster` permanecem nas mesmas versões do
`pubspec.lock`).

### 2.1. Máquina de estados explícita — `BroadcasterState`

```dart
enum BroadcasterState {
  idle,
  requestingPermissions,
  initializing,
  previewReady,
  startingStream,
  streaming,
  stopping,
  paused,
  disposing,
  disposed,
  error,
}
```

Regra central exigida: **o botão "Iniciar live" só funciona no estado
`previewReady`** — implementado em `_toggleStreaming()`:

```dart
// Caminho de INICIAR — só permitido em `previewReady`.
if (_state != BroadcasterState.previewReady || _controller == null) {
  _logEvent('start_stream_blocked', data: {'reason': 'invalid_state', 'state': _state.name});
  return;
}
```

E replicada em `_goLiveAutomatically()` (chamado ao fim do countdown
automático) e em `_switchCamera()` (só reinicia stream se `previewReady` foi
alcançado após a troca).

### 2.2. Session tokens (`_cameraSession`)

Todo ponto de entrada que (re)configura ou libera a câmera captura
`_cameraSession` **antes do primeiro `await`** e revalida
`session == _cameraSession` após cada `await` subsequente — mesmo padrão já
usado em `live_player_screen.dart`/`video_fullscreen_screen.dart` para o
player MDK (ver `ANDROID_MDK_VIDEO_CRASH_ANALYSIS.md`), agora estendido ao
`CameraController`/RootEncoder:

- `_initializeController()`
- `_setupCameraController(description, {session})`
- `_switchCamera()`
- `didChangeAppLifecycleState()` (incrementa a sessão antes de descartar o
  controller em background)
- `dispose()` (incrementa a sessão antes de qualquer teardown)

Callbacks tardios de uma sessão obsoleta são descartados silenciosamente
(sem tocar `setState`/`_controller`).

### 2.3. Operações serializadas (`_cameraOpInProgress`)

`_setupCameraController` nunca executa duas vezes concorrentemente — um
`bool _cameraOpInProgress` com `try/finally` bloqueia chamadas concorrentes
(ex.: troca de câmera disparada 2x, ou resume manual correndo junto com
teardown de background). `_togglePause` e `_switchCamera` verificam essa
flag antes de agir.

### 2.4. Dispose idempotente

```dart
@override
void dispose() {
  if (_isDisposed) return;
  _isDisposed = true;
  _state = BroadcasterState.disposing;
  _cameraSession++; // invalida qualquer operação em voo
  ...
  _state = BroadcasterState.disposed;
  super.dispose();
}
```

`_isDisposed` também é checado em `_logEvent`/`_setState` para nunca chamar
`setState` depois do `dispose()` real do Flutter ter começado.

### 2.5. Cancelamento de callbacks / proteção de `mounted`

Todo `await` dentro de `_initializeController`, `_setupCameraController`,
`_toggleStreaming`, `_switchCamera` e `_togglePause` é seguido por
`if (!mounted || session != _cameraSession) return;` antes de tocar
`_controller`, `setState` ou fazer chamadas nativas subsequentes.

### 2.6. Proteção de background/foreground

`didChangeAppLifecycleState`:
- Ignora completamente se `_isDisposed` ou `_state == disposing` (nunca
  reconfigura câmera durante teardown do widget).
- Ao entrar em `paused`/`inactive`: incrementa `_cameraSession` **antes** de
  invalidar `_controller` e chamar `dispose()` nativo — qualquer operação em
  voo (start/stop stream, setup) é abortada com segurança no próximo check.
- Ao voltar (`resumed`): só reconfigura a câmera se o estado atual for
  exatamente `paused` (evita reconfiguração duplicada se o usuário já tiver
  disparado um resume manual antes deste callback assíncrono rodar).

### 2.7. Estado explícito da câmera + bloqueio de ações em estado inválido

Todas as ações de UI (`_toggleStreaming`, `_switchCamera`, `_togglePause`,
`_startCountdown`) checam o estado atual antes de agir e emitem um log
`*_blocked` com o motivo quando a ação é rejeitada — nunca falham
silenciosamente sem rastro.

### 2.8. Logs sanitizados

`_logEvent(String event, {Map<String,Object?>? data})` centraliza todo log
técnico:

```dart
void _logEvent(String event, {Map<String, Object?>? data}) {
  final payload = <String, Object?>{
    'roomId': _room.id,
    'cameraSession': _cameraSession,
    'state': _state.name,
    ...?data,
  };
  debugPrint('[Broadcaster] $event $payload');
}
```

Eventos emitidos cobrem exatamente a lista solicitada: `init_start`,
`state_change`, `setup_camera_start/done/failed/blocked`,
`start_stream_start/done/error/blocked`, `stop_stream_done/error/blocked`,
`switch_camera_start/done/error/blocked`, `background_teardown_start`,
`foreground_resume_start`, `background_pause_start/*_error`,
`close_broadcaster_start/*_error`, `dispose_start/*_error`,
`resume_done`, `pause_done`, `toggle_pause_blocked/error`. **Nenhum log
inclui `rtmpUrl`, `streamKey` ou qualquer dado pessoal** — apenas `roomId`
(identificador técnico já público na navegação), `cameraSession` (inteiro) e
`state` (nome do enum).

---

## 3. Diff completo

Arquivo: `lib/ui/broadcaster/widgets/broadcaster_screen.dart`
Resumo: **+523 / -95 linhas** (patch completo salvo em `/tmp/broadcaster_diff.patch`
durante a sessão — abaixo, os pontos centrais do diff por método):

| Método | Natureza da mudança |
|---|---|
| *(novo)* `enum BroadcasterState` | 11 estados explícitos + doc de transições válidas |
| *(novos campos)* `_state`, `_cameraSession`, `_cameraOpInProgress`, `_isDisposed` | Estado da state machine |
| *(novo)* `_setState(BroadcasterState)` | Transição + log + `setState` condicional a `mounted`/`!_isDisposed` |
| *(novo)* `_logEvent(String, {data})` | Log sanitizado centralizado |
| `_initializeController()` | Sessão capturada antes do 1º `await`; valida em 4 pontos; só chama `_startCountdown()` se `state == previewReady` |
| `_setupCameraController()` | Assinatura ganhou `{int? session}`; serialização via `_cameraOpInProgress`; guarda `session` em 6 pontos; nunca conclui com `setState` se sessão obsoleta; documenta explicitamente que `isInitialized` não prova Surface pronta |
| `_startCountdown()` | Só arma o countdown se `state == previewReady` |
| `_goLiveAutomatically()` | Bloqueia se `state != previewReady` antes de chamar `_toggleStreaming()` |
| `didChangeAppLifecycleState()` | Guard `_isDisposed`/`disposing`; incrementa sessão antes do teardown; só resume se `state == paused` |
| `_toggleStreaming()` | Reescrito: caminho START só em `previewReady` (bloqueio explícito), caminho STOP só em `streaming`; states `startingStream`/`streaming`/`stopping`/`previewReady` corretamente aplicados; revalida sessão após cada `await` |
| `_togglePause()` | Resume usa nova sessão isolada para recriar câmera; bloqueia se `_cameraOpInProgress` |
| `_switchCamera()` | Usa uma única sessão para todo o ciclo stop→setup→restart; bloqueia se já em progresso; valida `previewReady` antes de reiniciar stream |
| `_silentPauseOnBackground()` | Logs de erro sanitizados adicionados |
| `_closeBroadcaster()` | Log de início + erro sanitizado no stop stream |
| `dispose()` | Idempotente (`_isDisposed` guard); incrementa sessão; `unawaited` com `catchError` sanitizado em vez de fire-and-forget silencioso |

Diff integral disponível via:
```bash
git diff lib/ui/broadcaster/widgets/broadcaster_screen.dart
```

---

## 4. Validação executada

### 4.1. `flutter analyze`

```
flutter analyze lib/ui/broadcaster/   → 7 issues (todas `info`, pré-existentes)
flutter analyze (projeto completo)    → 175 issues, 0 "error"
flutter analyze | grep broadcaster_screen → 5 `info` use_build_context_synchronously,
                                             todas em código NÃO tocado por este fix
                                             (_showBattleInviteDialog, _showMoreOptions)
```
**Resultado: 0 erros de compilação/análise introduzidos.**

### 4.2. Testes

```
flutter test test/ui/broadcaster/widgets/broadcaster_state_test.dart  → 3/3 passed (novo)
flutter test test/ui/broadcaster/view_models/start_live_view_model_test.dart → 2/2 passed
flutter test test/ui/broadcaster/widgets/start_live_screen_test.dart  → 1 failure (PRÉ-EXISTENTE)
flutter test (suíte completa)                                        → mesmas 10 falhas
                                                                          pré-existentes
                                                                          (confirmado via
                                                                          git stash / stash pop)
```

Falha pré-existente confirmada por comparação `git stash`:
`start_live_screen_test.dart` já falhava **antes** desta mudança (motivo:
`DropdownButtonFormField` não encontrado — problema de fixture do teste, não
relacionado ao `BroadcasterScreen`). Nenhuma regressão introduzida.

### 4.3. Build Android Release

```
flutter build apk --release
✓ Built build/app/outputs/flutter-apk/app-release.apk (160.0MB)
Gradle task 'assembleRelease' — 313.6s
Versão: 1.0.31+31
```

**Build bem-sucedido. APK gerado mas NÃO publicado** (conforme instrução).

---

## 5. Cenários testados manualmente (recomendados)

Não executei testes em dispositivo físico nesta sessão (fora do escopo de
"implementar + validar build"). Os cenários abaixo devem ser executados antes
de considerar o fix validado em produção — todos exercitam diretamente os
guards implementados:

| # | Cenário | Guard exercitado |
|---|---|---|
| 1 | Abrir tela de broadcast e tocar "voltar" repetidamente (10x) antes do countdown terminar | `_cameraSession` em `_initializeController`/`dispose` |
| 2 | Tocar "Go Live" manualmente 2x em sequência rápida (double-tap) | `_isTogglingStream` + guard de estado `previewReady` em `_toggleStreaming` |
| 3 | Trocar de câmera 5x em sequência rápida | `_cameraOpInProgress` + sessão única em `_switchCamera` |
| 4 | Background (home button) durante `_setupCameraController` em voo (logo após abrir a tela) | `_cameraSession++` em `didChangeAppLifecycleState` |
| 5 | Background → foreground rápido (< 1s) repetido 10x | Guard `state == paused` antes de reconfigurar no resume |
| 6 | Retomar live (`_togglePause` resume) imediatamente após voltar do background | Nova sessão isolada + checagem de `previewReady` antes de `startVideoStreaming` |
| 7 | Fechar a tela (`_closeBroadcaster`) enquanto `_switchCamera` está em andamento | `_isDisposed`/`_cameraSession++` em `dispose()` invalidando a troca em voo |
| 8 | Negar permissão de câmera/microfone | Estado `error` + `_closeBroadcaster()` (fluxo já existente, agora com log `init_blocked`) |
| 9 | Rotacionar o dispositivo durante preview (se aplicável na tela) | Nenhuma chamada nativa nova disparada — estado não regride |
| 10 | Monitorar `debugPrint` (logcat) durante os cenários 1–9 e confirmar que nenhum evento `*_blocked` inesperado aparece em uso normal, e que os esperados aparecem nos cenários de estresse | `_logEvent` |

---

## 6. Riscos e rollback

**Risco:** 🟢 Baixo.
- Nenhuma dependência nativa/Dart foi atualizada.
- Nenhuma API pública de terceiros foi chamada de forma diferente — apenas
  *quando* essas chamadas acontecem foi restringido.
- O comportamento funcional observável pelo usuário (fluxo de ir ao vivo,
  pausar, trocar câmera, encerrar) permanece o mesmo em uso normal; a
  diferença só aparece em condições de corrida (cliques rápidos,
  background/foreground rápido) — exatamente os casos que antes crashavam.

**Rollback:** trivial — `git checkout -- lib/ui/broadcaster/widgets/broadcaster_screen.dart`
reverte 100% da mudança sem tocar em nenhum outro arquivo, build.gradle,
pubspec ou dependência.

---

## 7. Pendências / próximos passos (fora desta correção)

1. **Crash A (SIGSEGV MDK/SubtitleDecoder) permanece sem causa raiz
   confirmada.** Requer:
   - Acesso ao Crashlytics breadcrumb (URL do vídeo, presença real de
     subtitle track, codec) do evento que gerou o crash;
   - Se confirmado que há legenda embutida, avaliar `setSubtitleTracks([])`
     no controller específico daquele player (não uma opção global de
     `registerWith`) — só depois de reproduzir o crash em ambiente
     controlado;
   - Aplicar o mesmo padrão de `_cameraSession`/session guard já usado em
     `live_player_screen.dart`/`video_fullscreen_screen.dart` também em
     `video_view.dart` (feed) e `stories_rail.dart`/`profile_videos_grid.dart`
     — identificado na auditoria anterior como ainda vulnerável, não
     coberto por este fix (escopo era exclusivamente `BroadcasterScreen`/EGL).
2. **Atualização de dependências** (`fvp`, `rtmp_broadcaster`) — avaliar
   separadamente, com testes de regressão de 48–72h, fora desta correção de
   lifecycle.
3. Executar os 10 cenários da seção 5 em dispositivo físico Android real e
   monitorar Crashlytics por 48h antes de considerar o Crash B mitigado em
   produção.

---

## 8. Resumo para entrega

- ✅ `flutter analyze`: 0 erros.
- ✅ Testes: sem regressões (10 falhas pré-existentes confirmadas via `git stash`).
- ✅ Build Android release: sucesso (`app-release.apk`, 160.0MB, v1.0.31+31).
- ❌ Publicação: não realizada (fora de escopo).
- ✅ Diff entregue (seção 3).
- ✅ Cenários testados/recomendados entregues (seção 5).
- ✅ Nenhuma dependência atualizada.
- ✅ Nenhuma opção inexistente do FVP foi adicionada — afirmação anterior
  corrigida com evidência de código-fonte decompilado.
- ✅ `isInitialized` não é tratado como prova de Surface EGL pronta — apenas
  como um sinal combinado com guards de estado/sessão/serialização.
- ✅ `Future.delayed` não foi usado como validação técnica em nenhum ponto
  novo do código Dart.
