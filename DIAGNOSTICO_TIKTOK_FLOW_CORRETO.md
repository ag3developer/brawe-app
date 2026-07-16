# 🔍 Diagnóstico: Fluxo de Presente vs TikTok

## ❌ Como está ERRADO no Brawe

```
Timeline:
T0: Usuário envia Rosa (value=50)
    ↓
T0: Backend emite gift_received
    ↓
T0+10ms: Flutter recebe no stream
    ↓
T0+20ms: ViewModel adiciona à state
    ↓
T0+30ms: SIMULTANEAMENTE renderiza 2 lugares:
         1. GiftAnimationOverlay (topo, animação)
         2. ChatTicker (embaixo, notificação)
    ↓
T0+5s: Expira do ViewModel e desaparece
       (Ambas desaparecem juntas!)

PROBLEMA: Chat mostra presente ENQUANTO ainda está animando
```

---

## ✅ Como funciona NO TIKTOK (CORRETO)

```
Timeline:
T0: Usuário envia Rosa
    ↓
T0: Backend emite gift_received + animation_url
    ↓
T0+10ms: Flutter recebe
    ↓
T0+20ms: ViewModel adiciona à state (mas MARCA como "AINDA ANIMANDO")
    ↓
T0+30ms: Renderiza APENAS:
         → GiftAnimationOverlay (fullscreen animation)
         ← ChatTicker IGNORA (ainda no período de animação!)
    ↓
T0+3.5s: Animação Lottie TERMINA
         ViewModel marca como "ANIMACAO_TERMINADA"
    ↓
T0+3.6s: ChatTicker AGORA RENDERIZA a notificação
         "Jose Carlos Martins enviou Rosa 🌹"
    ↓
T0+3.6s+5s: Notificação no chat desaparece

RESULTADO: 
- Animação aparece (3.5s)
- Depois mensagem no chat (5s)
- Total: usuario vê presente 2x (forma diferente)
```

---

## 🏗️ Arquitetura Atual (ERRADA)

```
Backend emite "gift_received"
    ↓
LiveRepository._onNewGift()
    ↓
watchGifts() stream
    ↓
LiveRoomGiftsViewModel._handleIncoming()
    ├─ Adiciona à state
    └─ Inicia Timer(5s) para expirar
    ↓
state = [gift1, gift2, ...]
    ↓
DOIS LISTENERS SIMULTÂNEOS:
├─ GiftAnimationOverlay.ref.listen() 
│  └─ Se premium → mostra overlay
└─ ChatTicker widget
   └─ Acessa gifts da ViewModel
   └─ Renderiza TUDO (não-premium)
   
PROBLEMA: Ambos vêem o MESMO gift ao mesmo tempo!
```

---

## 🔧 Solução Correta

### 1️⃣ Adicionar campo `isAnimating` ao LiveGift

```dart
// domain/models/live_gift.dart

class LiveGift {
  final String id;
  final String senderId;
  final String giftId;
  final String giftName;
  final double value;
  final int quantity;
  final DateTime timestamp;
  
  // ✅ NOVO: Marca se ainda está em período de animação
  final bool isAnimating;  // true por 3-4s, depois false
  
  // ... resto
}
```

### 2️⃣ ViewModel controla o ciclo de animação

```dart
// live_room_gifts_view_model.dart

void _handleIncoming(LiveGift gift) {
  final key = _comboKey(gift);
  final now = DateTime.now();

  // ✅ NOVO: Gift começa com isAnimating=true
  final entry = gift.copyWith(
    timestamp: now,
    isAnimating: true,  // ← ANIMANDO AGORA
  );
  
  state = [...state, entry];

  // ✅ NOVO: Timer para desabilitar animação (3-4s)
  // Nota: Este é DIFERENTE do Timer de expiração (5s)
  Timer(const Duration(seconds: 3), () {
    // Remove isAnimating, mas MANTÉM no state
    if (!ref.mounted) return;
    state = state.map((g) {
      if (_comboKey(g) == key && g.isAnimating) {
        return g.copyWith(isAnimating: false);
      }
      return g;
    }).toList();
  });

  // ✅ Timer original: expiração (5s para sair do state)
  _expiryTimers[key] = Timer(_displayTtl, () {
    if (!ref.mounted) return;
    state = state.where((g) => _comboKey(g) != key).toList();
    _expiryTimers.remove(key);
  });
}
```

### 3️⃣ ChatTicker filtra por `isAnimating`

```dart
// chat_ticker.dart

final items = <TickerItem>[
  for (final c in widget.comments)
    TickerItem(timestamp: c.timestamp, comment: c),
  // ✅ NOVO: Apenas presentes que JÁ TERMINARAM de animar
  for (final g in widget.gifts.where((g) => 
      g.value < 100 &&  // Não-premium
      !g.isAnimating))  // ← JÁ TERMINOU ANIMAÇÃO!
    TickerItem(timestamp: g.timestamp, gift: g),
]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
```

### 4️⃣ GiftAnimationOverlay renderiza enquanto `isAnimating`

```dart
// gift_animation_overlay.dart

for (final g in next) {
  // ✅ Renderiza APENAS se ainda está animando
  if (g.isAnimating && (
      g.quantity * (g.value > 0 ? g.value : 1) >= _kPremiumThreshold ||
      g.value >= _kPremiumThreshold)) {
    // ... mostra overlay
  }
}
```

---

## 📊 Timeline com Correção

```
T0: Usuário envia Rosa
T0+20ms: ViewModel adiciona com isAnimating=true
T0+30ms: 
  ✅ GiftAnimationOverlay renderiza (isAnimating=true)
  ✅ ChatTicker ignora (isAnimating=true)
T0+3s: ViewModel marca isAnimating=false
T0+3.1s:
  ✅ GiftAnimationOverlay para de renderizar
  ✅ ChatTicker AGORA renderiza a notificação!
T0+3.1s+5s:
  ✅ ChatTicker expira e remove
```

---

## 🎯 Resumo das Mudanças Necessárias

| Arquivo | Mudança |
|---------|---------|
| `domain/models/live_gift.dart` | Adicionar `bool isAnimating` |
| `live_room_gifts_view_model.dart` | 2 timers: animação (3s) + expiração (5s) |
| `gift_animation_overlay.dart` | Renderizar APENAS se `g.isAnimating` |
| `chat_ticker.dart` | Filtrar `!g.isAnimating` (além de `value < 100`) |

---

## 💡 Por que era implementado errado?

O código atual usa **UM ÚNICO estado** ("present exists or not") quando deveria ser **DOIS ESTADOS**:
1. **ANIMATING** (0-3s) → mostra overlay
2. **NOTIFIED** (3-8s) → mostra no chat

Você descobriu perfeitamente! 🎯
