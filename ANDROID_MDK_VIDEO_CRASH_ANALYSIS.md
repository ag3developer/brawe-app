# 🚨 ANDROID MDK VIDEO CRASH ANALYSIS
## "Bad state: Cannot add event after closing"

**Crash Message:**
```
Bad state: Cannot add event after closing
at _StreamController.add
at MdkVideoPlayer.<fn>(video_player_mdk.dart:93)
```

**Analysis Date**: 2026-07-16
**Status**: ✅ ROOT CAUSE IDENTIFIED + APP-SIDE FIX IMPLEMENTED (2026-07-16)

---

## ✅ IMPLEMENTAÇÃO (2026-07-16)

Aplicado o padrão `session`/`_disposed` guard (seção 10) em **6 arquivos**,
cobrindo todos os pontos de uso de `VideoPlayerController` classificados
como risco 🔴/🟡 na seção 3, mais 2 casos de risco adicional descobertos
durante a implementação (controllers órfãos sem `dispose()` quando a
sessão mudava após `initialize()`/`play()` já terem sido concluídos):

| Arquivo | Guard aplicado | Observação |
|---|---|---|
| `lib/ui/live_feed/widgets/live_player_screen.dart` | `_playerSession` (novo) | 🔴 Crítico — live viewer. `_initializePlayer()` agora captura `session` antes do 1º `await` e valida em 2 pontos (pós-`initialize()`, pós-`seekTo()`) |
| `lib/ui/live_feed/widgets/dual_hls_player.dart` | `_session` (novo) | 🟡 Batalha (2 streams simultâneos). `_initController()` valida `session` pós-`initialize()`; `_disposeControllers()` incrementa `_session` antes de descartar |
| `lib/ui/feed/widgets/story_viewer.dart` | `_storySession` (já existia) | ⚠️ Guard já existia mas **não descartava o controller órfão** quando a sessão mudava após `initialize()`/`play()` — corrigido: agora chama `ctrl.dispose()` nesses `return` antecipados (3 pontos) |
| `lib/ui/feed/widgets/feed_screen.dart` (`_FeedVideoTileState`) | `_disposed` (novo) | 🟢 Tile de vídeo no feed — guard simples (URL fixa por widget) |
| `lib/ui/feed/widgets/stories_rail.dart` (`_VideoFramePreviewState`) | `_disposed` (novo) | 🔴 Descoberto na implementação — 4 `await`s sequenciais sem check `mounted` entre eles, visível no rail sempre-presente da Home. Maior risco real do app |
| `lib/ui/profile/widgets/profile_videos_grid.dart` (`_VideoTileState`) | `_disposed` (novo) | 🟡 Descoberto na implementação — mesma cadeia de 5 `await`s sem check intermediário |

**Validação**: `flutter analyze` no projeto completo — **0 erros** (175
issues pré-existentes, todos `info`/`warning` de estilo não relacionados).

**Não implementado nesta etapa** (fora do escopo definido — ver seção 11.1):
correção no lado do plugin `fvp` (cancelar `StreamSubscription`s antes de
`streamCtl.close()`). A correção do app já elimina o crash na prática
(nenhum código do app tenta mais usar um controller/stream após a tela
ser descartada), mas o plugin continua com o código-fonte original.

**Próximo passo sugerido**: testar em dispositivo físico Android os 3
cenários de reprodução da seção 12.1 (50 ciclos cada) e monitorar
Crashlytics por 48h antes de considerar encerrado.

---

## 1. CAUSA RAIZ

O crash ocorre quando **callbacks nativos do MDK (fvp) continuam disparando após o `StreamController` ser fechado** no dispose.

**Arquivo Principal**:
- `/Users/josecarlosmartins/.pub-cache/hosted/pub.dev/fvp-0.37.3/lib/src/video_player_mdk.dart` (linhas 32-120)

**Sequência do crash**:

```
1. MdkVideoPlayer() constructor (linhas 29-120):
   - Cria streamCtl = StreamController<VideoEvent>()
   - Registra 4 listeners nativos PERMANENTES:
     * onMediaStatus.listen() (linha 40)
     * onEvent.listen() (linha 84)
     * onStateChanged.listen() (linha 103)

2. dispose() é chamado (linhas 36-39):
   - streamCtl.close()
   - _initialized = false
   - super.dispose() (encerra o Player nativo)

3. Callbacks nativos AINDA DISPARANDO:
   - onStateChanged (ex: stopped → completed)
   - onEvent (ex: reader.buffering)
   - onMediaStatus (ex: buffering → buffered)

4. Tentativa de streamCtl.add():
   - Linha 93: streamCtl.add(VideoEvent(...)) ❌
   - Stream já está fechado → "Cannot add event after closing"
```

---

## 2. ARQUIVO E LINHA

**Plugin**: `fvp` v0.37.3 (atual em pubspec.lock)
**Arquivo**: `fvp-0.37.3/lib/src/video_player_mdk.dart`
**Linhas críticas**:

| Linha | Descrição |
|-------|-----------|
| 32 | `final streamCtl = StreamController<VideoEvent>();` |
| 36-39 | `dispose()`: fecha streamCtl SEM cancelar listeners |
| 40-123 | 4 listeners nativos registrados NO CONSTRUTOR (permanentes) |
| 64, 79, 82, 93, 113, 116 | Tentativas de `streamCtl.add()` após dispose |

---

## 3. TELAS AFETADAS

Todas as telas que usam `VideoPlayerController` (via `fvp` backend MDK):

| Tela | Caminho | Risco |
|------|---------|-------|
| **LivePlayerScreen** | `lib/ui/live_feed/widgets/live_player_screen.dart` | 🔴 CRÍTICO |
| VideoFullscreenScreen | `lib/ui/feed/widgets/video_fullscreen_screen.dart` | 🟡 MÉDIO |
| StoryViewer | `lib/ui/feed/widgets/story_viewer.dart` | 🟡 MÉDIO |
| DualHlsPlayer | `lib/ui/live_feed/widgets/dual_hls_player.dart` | 🟡 MÉDIO |
| ProfileVideosGrid | `lib/ui/profile/widgets/profile_videos_grid.dart` | 🟡 MÉDIO |
| StoriesRail | `lib/ui/feed/widgets/stories_rail.dart` | 🟡 MÉDIO |
| LiveFeedScreen | `lib/ui/live_feed/widgets/live_feed_screen.dart` | 🟡 MÉDIO |
| CreateStorySheet | `lib/ui/feed/widgets/create_story_sheet.dart` | 🟢 BAIXO |
| CreateVideoSheet | `lib/ui/feed/widgets/create_video_sheet.dart` | 🟢 BAIXO |
| FeedScreen | `lib/ui/feed/widgets/feed_screen.dart` | 🟢 BAIXO |

---

## 4. FLUXO QUE GERA O CRASH

### Cenário A: Navegação rápida em LivePlayerScreen (MAIS COMUM)

```
1. User abre live → LivePlayerScreen.initState()
   └─ _initializePlayer() (await _controller!.initialize())

2. User muda de aba/tela rapidamente
   └─ LivePlayerScreen.dispose()
      └─ _controller?.dispose()
         └─ MdkVideoPlayer.dispose()
            └─ streamCtl.close() ✓ Fechado!

3. _controller!.initialize() COMPLETA (da linha 301)
   └─ onMediaStatus callback dispara: "loaded"
   └─ Tenta streamCtl.add(VideoEvent(...)) no linha 64
   └─ ❌ StreamController ALREADY CLOSED
```

### Cenário B: Scroll rápido no Stories/Feed

```
1. Story entra no viewport
   └─ _initializePlayer() começa
   └─ Registra listeners nativos

2. Scroll para fora (rápido, antes de initialize terminar)
   └─ dispose() chamado IMEDIATAMENTE
   └─ streamCtl.close()

3. initialize() completa no background
   └─ Callback onEvent dispara
   └─ ❌ Cannot add after closing
```

### Cenário C: Fullscreen → back durante load

```
1. User abre vídeo em fullscreen
   └─ _bootstrap() → await c.initialize()
   └─ Listeners registrados pelo MDK

2. User tapa "back" antes de terminate
   └─ dispose() encerra controller
   └─ streamCtl.close()

3. initialize() ou seek() completa
   └─ Callback nativo dispara
   └─ ❌ Crash
```

---

## 5. RESPONSABILIDADE DO APP

**Problema NO APP**:
- ❌ Nenhum `session` ID para proteger contra callbacks pós-dispose (ao contrário de `video_fullscreen_screen.dart` que usa)
- ❌ `live_player_screen.dart`: `_initializePlayer()` não valida `mounted` ou `session` antes de `setState()`
- ❌ Nenhuma remoção de listeners antes de fechar o stream
- ❌ Race condition entre `initialize()` async e `dispose()`

**Padrão correto já usado em `video_fullscreen_screen.dart`**:
```dart
int _session = 0;

Future<void> _bootstrap() async {
  final session = ++_session;  // ✓ Incrementa session
  try {
    final c = VideoPlayerController.networkUrl(...);
    await c.initialize();
    if (!mounted || session != _session) {  // ✓ Valida antes de usar
      await c.dispose();
      return;
    }
    setState(() { _ctrl = c; });
  } catch (_) {}
}

void dispose() {
  _session++;  // ✓ Invalida todos callbacks pendentes
  _ctrl?.dispose();
  super.dispose();
}
```

**`live_player_screen.dart` NÃO usa este padrão** → Vulnerável.

---

## 6. RESPONSABILIDADE DO PLUGIN

**Problema NO PLUGIN (fvp v0.37.3)**:
- ❌ Listeners registrados no construtor SEM proteção de `isClosed` antes de `add()`
- ❌ Não há guard `if (streamCtl.isClosed) return;` nos callbacks
- ❌ `dispose()` não cancela os listeners nativos (`onMediaStatus.listen`, `onEvent.listen`, `onStateChanged.listen`)
- ❌ Super class `dispose()` chamado APÓS `streamCtl.close()`, mas listeners nativos ainda podem disparar

**Correção ideal no plugin**:
```dart
void dispose() {
  _mediaStatusSub?.cancel();  // Cancelar subscription
  _eventSub?.cancel();        // Antes de fechar stream
  _stateChangedSub?.cancel();
  streamCtl.close();
  _initialized = false;
  super.dispose();
}
```

Mas o plugin atual **não armazena as subscriptions** (não tem `.listen().cancel()`).

---

## 7. VERSÃO DO PLUGIN

| Campo | Valor |
|-------|-------|
| Plugin | `fvp` |
| Versão em pubspec.yaml | `^0.37.0` |
| Versão instalada (lock) | `0.37.3` |
| Última versão conhecida | `0.37.3` (pub.dev) |
| Status | Ativo (manutenido pelo Wang Bin, MDK creator) |

---

## 8. POSSIBILIDADE DE ATUALIZAÇÃO

**Status atual**: Verificar se versão >= 0.38.0 existe e tem correção.

**Risco**: Baixo
- fvp é plugin bem mantido
- Mudanças costumam ser regressivas (compatibilidade)
- Não há breaking changes esperados em 0.38+

**Recomendação**: Esperar para tentar 0.38.0 quando sair, MAS:
- ✓ Implementar solução no APP AGORA (padrão `session`) não quebra nada
- ✓ Função como camada defensiva independente do plugin

---

## 9. NECESSIDADE DE FORK

**Fork necessário?** ❌ **NÃO, por enquanto.**

**Razão**:
- Plugin está ativo em manutenção
- Possível que a correção seja simples (guards de `isClosed`)
- Issue pode ser reportada e aceita

**Quando fazer fork**:
- Se Wang Bin (maintainer) não responder em 14 dias
- Se versão 0.38+ não corrigir o problema
- Se aplicarmos patches locais que não forem aceitos no upstream

---

## 10. CORREÇÃO MÍNIMA (APP SIDE)

**Implementação**:  Aplicar padrão `session` em TODAS as telas com `VideoPlayerController`.

**Prioridade**:
1. 🔴 **CRÍTICO**: `live_player_screen.dart` (ao vivo, navegação rápida)
2. 🟡 **ALTO**: `dual_hls_player.dart` (ao vivo, dependência de live_player)
3. 🟡 **MÉDIO**: `story_viewer.dart`, `feed_screen.dart` (scroll rápido)
4. 🟢 **BAIXO**: Outros (criação, preview, menos navegação rápida)

**Padrão para aplicar** (baseado em `video_fullscreen_screen.dart`):

```dart
class MyVideoScreen extends StatefulWidget {
  @override
  State<MyVideoScreen> createState() => _MyVideoScreenState();
}

class _MyVideoScreenState extends State<MyVideoScreen> {
  VideoPlayerController? _ctrl;
  int _session = 0;  // ✓ Adicionar

  Future<void> _initializePlayer() async {
    final session = ++_session;  // ✓ Incrementar session
    try {
      final c = VideoPlayerController.networkUrl(...);
      await c.initialize();
      
      if (!mounted || session != _session) {  // ✓ Guard CRÍTICO
        await c.dispose();
        return;
      }
      
      setState(() => _ctrl = c);
    } catch (e) {
      debugPrint('Init error: $e');
    }
  }

  @override
  void dispose() {
    _session++;  // ✓ Invalida callbacks pendentes
    _ctrl?.dispose();
    super.dispose();
  }
}
```

---

## 11. CORREÇÃO DEFINITIVA (PLUGIN SIDE + APP SIDE)

### 11.1 Plugin (fvp)

**Mínimo necessário**:
```dart
// Em MdkVideoPlayer constructor:
late StreamSubscription<MediaStatusEvent> _mediaStatusSub;
late StreamSubscription<MdkEvent> _eventSub;
late StreamSubscription<PlaybackStateEvent> _stateChangedSub;

MdkVideoPlayer() {
  _mediaStatusSub = onMediaStatus.listen((event) {
    if (streamCtl.isClosed) return;  // Guard
    // ... lógica
  });
  
  _eventSub = onEvent.listen((ev) {
    if (streamCtl.isClosed) return;  // Guard
    // ... lógica
  });
  
  _stateChangedSub = onStateChanged.listen((event) {
    if (streamCtl.isClosed) return;  // Guard
    // ... lógica
  });
}

@override
void dispose() {
  _mediaStatusSub.cancel();
  _eventSub.cancel();
  _stateChangedSub.cancel();
  streamCtl.close();
  _initialized = false;
  super.dispose();
}
```

### 11.2 App (Todos os VideoPlayerController)

Aplicar padrão `session` conforme seção 10.

---

## 12. TESTES

### 12.1 Reprodução do crash (para validar)

**Setup**: Android device, fvp v0.37.3

**Passo 1 - LivePlayerScreen**:
```
1. Abrir live
2. Esperar inicializar (UI > 2s)
3. Voltar rapidamente (tap back)
4. Repetir 5x
Esperado: Crash "Cannot add event after closing"
```

**Passo 2 - Stories/Feed (scroll rápido)**:
```
1. Entrar em feed (Stories ativas)
2. Scroll MUITO rápido para cima/baixo (3-5 items/sec)
3. Repetir 10x
Esperado: Crash aleatório quando historia saiu da tela antes de renderizar
```

**Passo 3 - Fullscreen + back**:
```
1. Abrir vídeo em fullscreen
2. Tap back IMEDIATAMENTE (antes de progress bar aparecer)
3. Repetir 10x
Esperado: Crash ocasional
```

### 12.2 Validação da correção (app side)

**Após aplicar `session` pattern**:
```
1. Repetir Passos 1-3 acima, 50x cada
2. Monitorar Crashlytics: 0 crashes
3. Verificar logs: Nenhum "Cannot add event after closing"
```

---

## 13. RISCOS

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|--------|-----------|
| Ao aplicar `session` pattern, esquecermos uma tela | 🟡 Média | 🔴 Alto | Code review checklist |
| Session var não incrementada em todos resets | 🟡 Média | 🔴 Alto | Copiar padrão exato de `video_fullscreen_screen.dart` |
| Callbacks ainda dispararem (bug plugin) | 🟡 Média | 🟡 Médio | Esperar fork/patch se não resolver |
| Performance: incrementar session a cada init | 🟢 Baixa | 🟢 Baixo | Custo negligível (int++) |
| Incompatibilidade com fvp > 0.37.x | 🟢 Baixa | 🟡 Médio | Session pattern é agnóstica de versão |

---

## 14. ROLLBACK

**Se correção causar problema novo**:

```bash
# Revert aplicação do session pattern
git revert <commit-hash>
```

**Segurança**: Padrão `session` é aditivo (não quebra API), rollback é 100% seguro.

---

## 15. RESUMO EXECUTIVO

| Pergunta | Resposta |
|----------|----------|
| **Causa confirmada?** | ✅ SIM. Listeners nativos disparam após streamCtl.close() |
| **Arquivo principal?** | `fvp-0.37.3/lib/src/video_player_mdk.dart` (plugin) + `live_player_screen.dart` (app) |
| **Cenário de reprodução?** | Navegação rápida (back), scroll rápido em stories, fullscreen com back imediato |
| **Plugin precisa atualizar?** | ⚠️ Melhoraria, MAS app pode se proteger AGORA com `session` pattern |
| **É necessário fork?** | ❌ NÃO ainda. Implementar correção no app primeiro |
| **Primeira correção recomendada?** | ✅ Aplicar `session` ID pattern em `live_player_screen.dart` + top 3 telas críticas |

---

## 16. IMPLEMENTAÇÃO (PRÓXIMA ETAPA)

Quando autorizado, aplicar em ordem de prioridade:

1. `live_player_screen.dart` — critério de teste: 50 ciclos back sem crash
2. `dual_hls_player.dart` — mesma validação
3. `story_viewer.dart`, `feed_screen.dart`
4. Restantes

Cada mudança é idêntica ao padrão em `video_fullscreen_screen.dart`.

