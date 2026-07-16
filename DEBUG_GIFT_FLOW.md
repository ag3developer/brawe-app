# 🐛 DEBUG: Fluxo do Presente

## 🔍 Checklist de Debug

### 1️⃣ Verificar se o evento está sendo recebido

Abra o DevTools do Flutter e procure por este log:

```
LiveRepository: Received event gift_received: {...}
```

Se NÃO aparecer quando você envia um presente, o problema é **no WebSocket** ou **no backend**.

### 2️⃣ Adicionar logs mais verbosos

Abra `lib/data/repositories/live_repository.dart` e procure pela linha ~761:

```dart
_onNewGift = (data) {
  debugPrint(
    'LiveRepository: Received event ${AppConstants.eventNewGift}: $data',
  );
  // ...
};
```

Mude para:

```dart
_onNewGift = (data) {
  debugPrint('🎁 [GIFT_RECEIVED] Recebido: $data');
  final gift = _parseLiveGift(data);
  debugPrint('🎁 [GIFT_PARSED] Gift: $gift');
  if (gift == null) {
    debugPrint('🎁 [GIFT_ERROR] Falha ao parsear o gift!');
    return;
  }

  final payload = _asMap(data);
  final msgRoomId = payload?['room_id']?.toString();
  debugPrint('🎁 [GIFT_DISPATCH] Dispatching para room: $msgRoomId');

  _dispatchToGiftControllers(gift, roomId: msgRoomId);
};
```

### 3️⃣ Verificar se o presente chega no ViewModel

Abra `lib/ui/live_feed/view_models/live_room_gifts_view_model.dart` (~linha 48):

```dart
void _handleIncoming(LiveGift gift) {
  debugPrint('🎁 [VIEWMODEL] Gift recebido: ${gift.giftName} x${gift.quantity}');
  debugPrint('🎁 [VIEWMODEL] Value: ${gift.value}, Premium: ${gift.value >= 100}');
  
  final key = _comboKey(gift);
  // ... resto do código
}
```

### 4️⃣ Verificar se aparece no overlay

Abra `lib/ui/live_feed/widgets/gift_animation_overlay.dart` (~linha 92):

```dart
ref.listen<List<LiveGift>>(liveRoomGiftsViewModelProvider(widget.roomId), (
  prev,
  next,
) {
  debugPrint('🎁 [OVERLAY_LISTEN] Gifts atualizadas: ${next.length} itens');
  for (final g in next) {
    debugPrint('  - ${g.giftName} x${g.quantity} (value: ${g.value})');
  }
  
  // Detecta novos combos premium...
  for (final g in next) {
    if (g.quantity * (g.value > 0 ? g.value : 1) >= _kPremiumThreshold ||
        g.value >= _kPremiumThreshold) {
      debugPrint('🎁 [PREMIUM] Disparando animation premium!');
      // ...
    }
  }
});
```

---

## 📋 Checklist do Fluxo Completo

```
[1] Backend envia gift_received via WebSocket?
    └─ Verificar: DevTools → "Received event gift_received"
    └─ Se NÃO: Problema é backend/WebSocket

[2] Flutter parseia o gift?
    └─ Verificar: DevTools → "[GIFT_PARSED] Gift: ..."
    └─ Se NULL: Problema é _parseLiveGift() → modelo não bate

[3] ViewModel recebe o gift?
    └─ Verificar: DevTools → "[VIEWMODEL] Gift recebido: ..."
    └─ Se NÃO: Problema é StreamController

[4] Overlay mostra o gift?
    └─ Verificar: DevTools → "[OVERLAY_LISTEN] Gifts atualizadas"
    └─ Se lista vazia: Problema é ref.listen

[5] Presente é premium (value >= 100)?
    └─ Verificar: DevTools → "[PREMIUM] Disparando animation premium!"
    └─ Se SIM: Deve aparecer fullscreen
    └─ Se NÃO: Deve aparecer no chat ticker
```

---

## 🎯 Testes Específicos

### Teste 1: Presente Pequeno (value < 100)
- Enviar presente com **value: 10**
- ✅ Deve aparecer no **chat ticker** (linha pequena)
- ✅ Não deve ser fullscreen

### Teste 2: Presente Premium (value >= 100)
- Enviar presente com **value: 100** ou mais
- ✅ Deve aparecer **fullscreen** por ~2.5s
- ✅ Com animação de luz/blur

### Teste 3: Combo (múltiplos presentes iguais em 4s)
- Enviar 3x o mesmo presente em menos de 4 segundos
- ✅ Deve virar 1 item com **quantity: 3**
- ✅ "Jose enviou 🎁 x3"

---

## 🔧 Possivelmente o Problema

### Problema 1: Backend não retorna `room_id`

Se o backend envia:
```json
{
  "gift_id": "123",
  "sender_id": "user1",
  "gift_name": "Rose"
  // ❌ Falta room_id!
}
```

O `_dispatchToGiftControllers()` não sabe para qual sala enviar.

**Solução:** Backend deve enviar:
```json
{
  "room_id": "room123",  // ← Essencial!
  "gift_id": "123",
  "sender_id": "user1",
  "gift_name": "Rose"
}
```

### Problema 2: Evento é `gift_sent` em vez de `gift_received`

Se backend envia como `gift_sent`, o Flutter não escuta.

**Solução:** Backend deve enviar como **`gift_received`**.

### Problema 3: Presente nunca chega (latência WebSocket)

O socket pode não estar conectado quando você envia.

**Solução:** Verificar se `connectToRoom()` foi chamado com sucesso.

---

## 📍 Arquivos Relevantes

- `lib/data/repositories/live_repository.dart` (linhas ~760-770) — Listener do evento
- `lib/ui/live_feed/view_models/live_room_gifts_view_model.dart` (linhas ~48-80) — ViewModel
- `lib/ui/live_feed/widgets/gift_animation_overlay.dart` (linhas ~92-100) — Overlay
- `lib/ui/live/shared/widgets/chat/gift_chat_line.dart` — Chat ticker

---

## 🚀 Próximos Passos

1. **Adicione os logs** acima
2. **Envie um presente** pelo app
3. **Procure pelos logs** `[GIFT_RECEIVED]`, `[GIFT_PARSED]`, etc.
4. **Diga-me quais logs aparecem** e quais faltam
5. Vamos debugar passo a passo!

---

**Data:** 2026-07-16  
**Status:** Pronto para debug
