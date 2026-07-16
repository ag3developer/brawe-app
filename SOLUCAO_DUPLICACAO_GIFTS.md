# 🎁 Solução: Duplicação de Presentes

## 🔍 Problema Identificado

Você está vendo **2 notificações** do mesmo presente:

```
1️⃣ Jose Carlos Martins enviou Estrela
2️⃣ Jose Carlos Martins enviou Estrela 🎁
```

## ❓ Causa Provável

### Hipótese 1: Backend envia 2 eventos `gift_received` (MAIS PROVÁVEL)

O backend pode estar disparando:
```json
// Evento 1
{
  "event": "gift_received",
  "gift_id": "star123",
  "sender_id": "user1",
  "receiver_id": "user2",
  "quantity": 1,
  "gift_name": "Estrela"
}

// Evento 2 (duplicado!)
{
  "event": "gift_received",
  "gift_id": "star123",
  "sender_id": "user1",
  "receiver_id": "user2",
  "quantity": 1,
  "gift_name": "Estrela"
}
```

Resultado: 2 entradas no `state` do ViewModel → 2 renderizações.

### Hipótese 2: Subscribe dupla no listener (MENOS PROVÁVEL)

O `_onNewGift` está registrado 2x no socket:
```dart
_socketService.on(AppConstants.eventNewGift, _onNewGift!);  // 1ª vez
_socketService.on(AppConstants.eventNewGift, _onNewGift!);  // 2ª vez (duplicada?)
```

---

## ✅ Como Verificar

### Passo 1: Adicionar log no backend

```python
# backend/app/socketio_handlers/gifts.py (pseudocódigo)

@sio.on('send_gift')
def handle_send_gift(sid, data):
    print(f"🎁 [LOG] Emitindo gift_received")
    
    # Emitir para a sala
    sio.emit('gift_received', {...}, room=room_id)
    # ← Verificar se essa linha está sendo chamada 2x
```

### Passo 2: Verificar logs Flutter

Abra o VS Code Debug Console e procure por:
```
🎁 [GIFT_RECEIVED] Recebido: {...}
```

Se aparecer **2x com o mesmo presente**, o backend está emitindo 2x.

---

## 🔧 Solução (Opções)

### Opção A: Deduplicação no ViewModel (RECOMENDADO)

Adicionar verificação de duplicata no `live_room_gifts_view_model.dart`:

```dart
void _handleIncoming(LiveGift gift) {
  final key = _comboKey(gift);
  final now = DateTime.now();

  // ✅ NOVO: Verificar se já existe gift idêntico MUITO recente
  final existingExact = state.indexWhere(
    (g) => _comboKey(g) == key && 
           now.difference(g.timestamp) < Duration(milliseconds: 100),
  );
  
  if (existingExact >= 0) {
    debugPrint('🎁 [DEDUP] Ignorando gift duplicado!');
    return; // ← Pular duplicata
  }

  // ... resto do código
}
```

### Opção B: Verificar Backend

Se o backend está emitindo 2 eventos, procurar por:
- Duplicate webhook handlers
- 2 listeners para o mesmo evento
- Loop que emite 2x

---

## 📊 Análise da Sua Screenshot

```
Timeline:
┌─────────────────────────┐
│ Timestamp: 14:32:15     │
├─────────────────────────┤
│ Evento 1: gift_received │ ← Primeiro presente
│ Evento 2: gift_received │ ← Duplicado
└─────────────────────────┘
     ↓
  ViewModel recebe 2
     ↓
  State = [gift1, gift2]
     ↓
  ChatTicker renderiza 2
```

---

## 🎯 Recomendação Final

### Para TikTok-like correto, deveria ser:

```
Usuario envia presente
     ↓
Backend emite gift_received (1x apenas)
     ↓
Flutter recebe em stream
     ↓
ViewModel agrega em combo (se aplicável)
     ↓
ChatTicker renderiza 1 notificação
```

### Current Brawe:

```
Usuario envia presente
     ↓
Backend emite gift_received (2x - BUG!)
     ↓
Flutter recebe 2 eventos
     ↓
ViewModel adiciona 2 entradas
     ↓
ChatTicker renderiza 2 notificações ← PROBLEMA AQUI
```

---

## 🚀 Ações

1. **Verificar logs do backend** — Backend está emitindo 2x?
2. **Se SIM** — Corrigir backend para emitir 1x
3. **Se NÃO** — Aplicar Opção A (deduplicação no Flutter)
4. **Testar** — Enviar presente novamente, deve aparecer 1x

---

## 📁 Arquivos a Revisar

- `brawe-connect/backend/socketio_handlers/` (ou equivalente no seu backend)
- `lib/ui/live_feed/view_models/live_room_gifts_view_model.dart`
- `lib/data/repositories/live_repository.dart` (linha ~760)

---

**Próximo:** Confirme se backend emite 2x ou 1x!
