# 🎙️ DIAGNÓSTICO COMPLETO - TELA DE CO-HOST

**Data**: 2026-07-15  
**Objetivo**: Análise completa (Frontend + Backend + API) para implementação do co-host  
**Status**: ✅ Análise Concluída | ⏳ Implementação Pendente  

---

## 📋 SUMÁRIO EXECUTIVO

### Situação Atual
- ✅ **Backend**: 90% pronto (endpoints criados, lógica implementada)
- ✅ **APIs**: Estrutura definida (4 rotas funcionais)
- ⚠️ **Frontend**: 100% mock (não chama backend)
- ❌ **Socket.IO**: Listeners não implementados
- ❌ **Emojis**: Aparecem apenas na seção "Como funciona" (explicativo, não problema)

### O que Falta
1. **Endpoint backend** de followers online (GET `/followers/online`)
2. **Repository Flutter** para chamar APIs de co-host
3. **Socket listeners** para eventos de co-host em tempo real
4. **Integração Riverpod** para estado reativo
5. **UI refatorada** para dados reais

---

## 🎯 ARQUIVOS IDENTIFICADOS

### Frontend Flutter (brawe-app)

#### Arquivo Principal: `broadcaster_screen.dart`
**Localização**: `/lib/ui/broadcaster/widgets/broadcaster_screen.dart`

**Co-host Sheet** (linhas 977-1175):
```dart
_showCoHostSheet() {
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      // 📲 Header com "Convide um co-host"
      // 📝 Mock list de 5 followers
      // ℹ️ "Como funciona" com 4 emojis
      // 🔘 Botão "Enviar Convite de Co-host"
    ),
  );
}
```

**Mock Followers List** (linhas 1099-1120):
```dart
ListView.builder(
  itemCount: 5,  // ❌ HARDCODED
  itemBuilder: (_, i) => _buildFollowerItem(),  // Icons.person_outline + nome '• • •'
)
```

**Emojis** (linhas 1065-1068):
```dart
'📲 O co-host recebe uma notificação'
'🎥 A tela divide automaticamente'
'💬 Vocês compartilham o chat ao vivo'
'⏱ Sem limite de tempo'
```

#### Botão na Barra de Ações: `live_action_bar.dart`
**Localização**: `/lib/ui/live/streamer/widgets/actions/live_action_bar.dart`

**Co-host Button** (linhas 74-76):
```dart
ActionBtn(
  icon: Icons.people_alt_rounded,
  label: 'Co-host',
  color: const Color(0xFF0EA5E9),
  onTap: onCoHost,  // ← Chama _showCoHostSheet()
),
```

#### Repository (NÃO IMPLEMENTADO): `live_repository.dart`
**Localização**: `/lib/providers/repositories/live_repository.dart`

**Métodos Faltantes**:
- `checkCoHostEligibility()` — Verifica se o streamer pode convidar co-host
- `inviteCoHost(roomId, guestUserId)` — Envia convite para backend
- `acceptCoHostInvite(inviteId)` — Accept do guest
- `leaveCoHost()` — Guest sai

#### Socket Service (NÃO IMPLEMENTADO): `socket_service.dart`
**Localização**: `/lib/core/services/socket_service.dart`

**Listeners Faltantes**:
```dart
socket.on('cohost_invite', (data) { ... })
socket.on('cohost_accepted', (data) { ... })
socket.on('cohost_left', (data) { ... })
socket.on('screen_split_ready', (data) { ... })
```

---

## 🔌 BACKEND & APIs (Brawe)

### Endpoints Implementados ✅

#### 1. **Verificar Elegibilidade**
```
GET /api/rooms/{room_id}/cohost/eligibility
Headers: { Authorization: Bearer <token> }

Response (200):
{
  "success": true,
  "data": {
    "can_invite_cohost": true,
    "reason": "eligible",
    "streamer_tier": "CREATOR",
    "followers_count": 1200,
    "lives_count": 15
  }
}
```

**Arquivo**: `brawe-connect/app/routers/live.py:1876`

---

#### 2. **Enviar Convite**
```
POST /api/rooms/{room_id}/cohost/invite
Headers: { Authorization: Bearer <token> }
Body: {
  "guest_user_id": "uuid-guest-123"
}

Response (201):
{
  "success": true,
  "data": {
    "room_id": "room-123",
    "guest_user_id": "user-456",
    "status": "invite_sent",
    "expires_at": "2026-07-15T20:00:00Z"
  }
}
```

**Arquivo**: `brawe-connect/app/routers/live.py:1904`

---

#### 3. **Guest Aceita Convite**
```
POST /api/rooms/{room_id}/cohost/accept
Headers: { Authorization: Bearer <token> }

Response (200):
{
  "success": true,
  "data": {
    "cohost_user_id": "user-456",
    "status": "cohost_active",
    "broadcast_url": "rtmps://...",
    "screen_layout": "side_by_side"
  }
}
```

**Arquivo**: `brawe-connect/app/routers/live.py:1984`

---

#### 4. **Deixar Co-host**
```
POST /api/rooms/{room_id}/cohost/leave
Headers: { Authorization: Bearer <token> }

Response (200):
{
  "success": true,
  "data": {
    "status": "cohost_ended",
    "message": "Co-host session encerrada"
  }
}
```

**Arquivo**: `brawe-connect/app/routers/live.py:2021`

---

#### 5. **❌ FALTANDO: Listar Followers Online**
```
GET /api/users/followers/online
Headers: { Authorization: Bearer <token> }

Expected Response (200):
{
  "success": true,
  "data": [
    {
      "user_id": "user-123",
      "name": "João Silva",
      "avatar_url": "https://...",
      "followers_count": 2500,
      "is_live": false,
      "can_be_cohost": true,
      "tier": "CREATOR"
    },
    ...
  ]
}
```

**Status**: 🔴 NÃO IMPLEMENTADO  
**Prioridade**: 🔴 CRÍTICA (bloqueia UI do co-host)

---

### Regras de Elegibilidade (streamer_eligibility.py)

```python
CO_HOST_REQUIREMENTS = {
    "tier": "CREATOR",           # Gerou $50+
    "followers": 500,            # Mínimo 500 followers
    "lives": 10,                 # Mínimo 10 lives
    "account_age_days": 30,      # Conta com 30+ dias
}

GUEST_COHOST_REQUIREMENTS = {
    "tier": "ARTIST",            # Mínimo ARTIST
    "followers": 100,
    "lives": 3,
}
```

**Arquivo**: `brawe-connect/app/services/streamer_eligibility.py`

---

### Socket.IO Events (Real-time)

```python
# Servidor emite para guest
socket.emit('cohost_invite', {
    'room_id': '...',
    'streamer': {...},
    'expires_at': '...'
})

# Guest aceita
socket.emit('cohost_accepted', {
    'room_id': '...',
    'cohost_user_id': '...',
})

# Novo layout na tela
socket.emit('screen_split_ready', {
    'layout': 'side_by_side',
    'primary': 'streamer',
    'secondary': 'cohost'
})

# Guest sai
socket.emit('cohost_left', {
    'room_id': '...'
})
```

---

## 📊 MODELOS DE DADOS

### Backend Models

**CoHostInvite** (Python):
```python
class CoHostInvite(Base):
    id: UUID
    room_id: UUID
    streamer_id: UUID
    guest_id: UUID
    status: str  # invite_sent, accepted, rejected, expired, ended
    created_at: datetime
    expires_at: datetime
    accepted_at: datetime | None
```

### Frontend Models (Flutter - NÃO EXISTEM)

**Criar**:
```dart
class CoHostInvite {
  final String id;
  final String roomId;
  final User streamer;
  final User guest;
  final String status;  // invite_sent, accepted, etc
  final DateTime expiresAt;
  final DateTime? acceptedAt;
}

class CoHostEligibility {
  final bool canInviteCoHost;
  final String reason;  // "eligible", "insufficient_followers", etc
  final String streamerTier;
  final int followersCount;
  final int livesCount;
}

class FollowerOnline {
  final String userId;
  final String name;
  final String avatarUrl;
  final int followersCount;
  final bool isLive;
  final bool canBeCohost;
  final String tier;
}
```

---

## 🎨 LOCALIZAÇÃO DOS EMOJIS

### Situação Atual ✅
Os emojis **NÃO SÃO PROBLEMA**. Aparecem apenas na seção informativa "Como funciona":

```dart
// broadcaster_screen.dart, linhas 1065-1068
Container(
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      Text('📲 O co-host recebe uma notificação'),
      Text('🎥 A tela divide automaticamente'),
      Text('💬 Vocês compartilham o chat ao vivo'),
      Text('⏱ Sem limite de tempo'),
    ],
  ),
),
```

### Por Que Emojis?
- ✅ **Clareza visual**: Fácil entender a experiência
- ✅ **Multilíngue**: Funcionam em qualquer idioma
- ✅ **UX positiva**: Torna a feature amigável
- ✅ **TikTok/YouTube**: Padrão da indústria

### Alternativa (se quiser remover)
Substituir por ícones Lucide (já usado no app):
```dart
LucideIcons.messageCircle, // em vez de 💬
LucideIcons.bell,          // em vez de 📲
LucideIcons.video,         // em vez de 🎥
LucideIcons.clock,         // em vez de ⏱
```

---

## 🔄 FLUXO ATUAL (Mock)

```
┌─────────────────────────────────────┐
│   User taps "Co-host" button        │
│   (live_action_bar.dart:74)         │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│   _showCoHostSheet() opens          │
│   BottomSheet (broadcaster_screen)  │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│   Renders 5 mock followers          │
│   • Icons.person_outline (gray)     │
│   • Name: '• • •'                   │
│   • Selectable: FALSE               │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│   "Como funciona" with 4 emojis     │
│   (informativo, não interativo)     │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│   User taps "Enviar Convite"        │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│   SnackBar: "Co-host em breve!"     │
│   (hardcoded message, no action)    │
└─────────────────────────────────────┘
             │
             ▼
         FIM (nada acontece no backend)
```

---

## 🚀 FLUXO ESPERADO (Integrado)

```
┌────────────────────────────────┐
│  User taps "Co-host" button    │
└────────────┬───────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  GET /cohost/eligibility                │
│  (check if streamer can invite)         │
└────────────┬────────────────────────────┘
             │
      ┌──────┴──────┐
      │             │
      ▼             ▼
  NOT ELIGIBLE  ELIGIBLE
      │             │
      │             ▼
      │    ┌─────────────────────────────────┐
      │    │ GET /followers/online           │
      │    │ (fetch real followers list)     │
      │    └────────────┬────────────────────┘
      │                 │
      │                 ▼
      │    ┌─────────────────────────────────┐
      │    │ Load real data into ListView:   │
      │    │ • Avatar image (not placeholder)│
      │    │ • Real name                     │
      │    │ • Followers count               │
      │    │ • Selectable: TRUE              │
      │    └────────────┬────────────────────┘
      │                 │
      │                 ▼
      │    ┌─────────────────────────────────┐
      │    │ User selects co-host from list  │
      │    └────────────┬────────────────────┘
      │                 │
      │                 ▼
      │    ┌─────────────────────────────────┐
      │    │ POST /cohost/invite             │
      │    │ { guest_user_id: "..." }        │
      │    └────────────┬────────────────────┘
      │                 │
      │                 ▼
      │    ┌─────────────────────────────────┐
      │    │ Backend validates & emits       │
      │    │ Socket: 'cohost_invite'         │
      │    └────────────┬────────────────────┘
      │                 │
      │                 ▼
      │    ┌─────────────────────────────────┐
      │    │ Guest receives notification     │
      │    │ Shows "Co-host invitation"      │
      │    │ Accept / Reject buttons         │
      │    └────────────┬────────────────────┘
      │                 │
      │         ┌───────┴───────┐
      │         │               │
      │         ▼               ▼
      │      REJECT          ACCEPT
      │         │               │
      │         └───┐       ┌───┘
      │             │       │
      │             ▼       ▼
      │    ┌─────────────────────────────────┐
      │    │ POST /cohost/accept             │
      │    │ Backend emits 'cohost_accepted' │
      │    └────────────┬────────────────────┘
      │                 │
      │                 ▼
      │    ┌─────────────────────────────────┐
      │    │ Both screens update to split    │
      │    │ Stream shows side-by-side       │
      │    │ Chat shared                     │
      │    │ Co-host controls appear         │
      │    └─────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────┐
│  Show "Not Eligible" dialog:    │
│  "Você precisa de:"             │
│  • 500+ followers               │
│  • 10+ lives                    │
│  • Tier CREATOR                 │
└─────────────────────────────────┘
```

---

## 🏗️ ARQUITETURA

### Camadas

```
┌──────────────────────────────────────┐
│         Flutter UI Layer             │
│  ┌─────────────────────────────────┐ │
│  │ broadcaster_screen.dart         │ │
│  │ _showCoHostSheet()              │ │
│  │ Live followers list (REAL DATA) │ │
│  └─────────────────────────────────┘ │
└──────────────┬───────────────────────┘
               │ (API calls)
┌──────────────┴───────────────────────┐
│    Repository/Provider Layer        │
│  ┌─────────────────────────────────┐ │
│  │ live_repository.dart            │ │
│  │ • checkCoHostEligibility()      │ │
│  │ • inviteCoHost()                │ │
│  │ • acceptCoHostInvite()          │ │
│  │ • leaveCoHost()                 │ │
│  └─────────────────────────────────┘ │
└──────────────┬───────────────────────┘
               │ (HTTP + WebSocket)
┌──────────────┴───────────────────────┐
│        Backend API Layer             │
│  ┌─────────────────────────────────┐ │
│  │ live.py (brawe-connect)         │ │
│  │ • GET  /cohost/eligibility      │ │
│  │ • GET  /followers/online        │ │
│  │ • POST /cohost/invite           │ │
│  │ • POST /cohost/accept           │ │
│  │ • POST /cohost/leave            │ │
│  └─────────────────────────────────┘ │
└──────────────┬───────────────────────┘
               │ (Database queries)
┌──────────────┴───────────────────────┐
│       Database / Cache Layer        │
│  ┌─────────────────────────────────┐ │
│  │ PostgreSQL + Redis              │ │
│  │ • cohost_invites table          │ │
│  │ • user_follows table            │ │
│  │ • user_stats table              │ │
│  └─────────────────────────────────┘ │
└──────────────────────────────────────┘
```

---

## 🧩 STACK TÉCNICO

### Frontend (Flutter)
- **State Management**: Riverpod (providers)
- **API Client**: Dio (HTTP requests)
- **Real-time**: Socket.IO (WebSocket events)
- **Models**: Freezed (data classes)
- **Validation**: Custom (elegibilidade)

### Backend (Python)
- **Framework**: FastAPI (brawe-connect)
- **Database**: PostgreSQL
- **Caching**: Redis
- **Real-time**: Socket.IO
- **Auth**: JWT Bearer tokens

### Communication
- **REST APIs**: JSON over HTTP
- **WebSocket**: Socket.IO events
- **Protocols**: HTTPS + WSS

---

## 📋 CHECKLIST DE IMPLEMENTAÇÃO

### Backend (Prioridade 🔴 CRÍTICA)

- [ ] **Endpoint: GET /followers/online**
  - Retornar lista de followers online do usuário
  - Incluir: id, name, avatar, followers_count, is_live, can_be_cohost, tier
  - Filtrar por elegibilidade (ARTIST tier mínimo)
  - Localização sugerida: `brawe-connect/app/routers/live.py` após linha 2021

- [ ] **Validar endpoints existentes**
  - [ ] GET /cohost/eligibility — retorna corretamente
  - [ ] POST /cohost/invite — cria invite + emite Socket.IO
  - [ ] POST /cohost/accept — atualiza status + emite Socket.IO
  - [ ] POST /cohost/leave — encerra sessão

- [ ] **Socket.IO Events**
  - [ ] `cohost_invite` — enviado para guest
  - [ ] `cohost_accepted` — enviado para streamer
  - [ ] `screen_split_ready` — enviado para ambos
  - [ ] `cohost_left` — enviado para ambos

### Frontend (Prioridade 🟠 ALTA)

- [ ] **Models (Criar)**
  - [ ] `CoHostInvite` model (Freezed)
  - [ ] `CoHostEligibility` model (Freezed)
  - [ ] `FollowerOnline` model (Freezed)

- [ ] **Repository Methods (Implementar)**
  - [ ] `checkCoHostEligibility(roomId)`
  - [ ] `fetchFollowersOnline()`
  - [ ] `inviteCoHost(roomId, guestUserId)`
  - [ ] `acceptCoHostInvite(inviteId)`
  - [ ] `leaveCoHost(roomId)`
  - Localização: `lib/providers/repositories/live_repository.dart`

- [ ] **Riverpod Providers (Criar)**
  - [ ] `coHostEligibilityProvider`
  - [ ] `followersOnlineProvider`
  - [ ] `coHostInviteProvider` (notifier)
  - Localização: `lib/providers/` (novo arquivo ou existente)

- [ ] **Socket Listeners (Implementar)**
  - [ ] `socket.on('cohost_invite', ...)`
  - [ ] `socket.on('cohost_accepted', ...)`
  - [ ] `socket.on('screen_split_ready', ...)`
  - [ ] `socket.on('cohost_left', ...)`
  - Localização: `lib/core/services/socket_service.dart`

- [ ] **UI Updates (Refatorar)**
  - [ ] `broadcaster_screen.dart` — Remover mock
  - [ ] Substituir ListView hardcoded por dados da API
  - [ ] Adicionar carregamento (LoadingState)
  - [ ] Adicionar tratamento de erros
  - [ ] Remover "• • •" placeholders
  - [ ] Mostrar informações reais: nome, followers, avatar

- [ ] **Fluxo de Convite**
  - [ ] User selects follower → Call inviteCoHost()
  - [ ] Show loading dialog
  - [ ] On success → Dismiss + show toast "Convite enviado"
  - [ ] On error → Show error dialog with reason

- [ ] **Emojis (Opcional)**
  - [ ] Manter como está (está bom)
  - OU [ ] Substituir por Lucide Icons (LucideIcons.bell, etc)

### Testing (Prioridade 🟡 MÉDIA)

- [ ] **Unit Tests**
  - [ ] Test `checkCoHostEligibility()` logic
  - [ ] Test models serialization
  - [ ] Test error handling

- [ ] **Integration Tests**
  - [ ] Test full co-host flow (end-to-end)
  - [ ] Test Socket.IO events
  - [ ] Test error scenarios

- [ ] **Manual Testing**
  - [ ] Test on Android device
  - [ ] Test on iOS device
  - [ ] Test notification for guest
  - [ ] Test split-screen UI

---

## 🔍 DETALHES TÉCNICOS

### Por Que Mock Existe?

1. **Prototipagem rápida**: UI pronta antes do backend
2. **Desenvolvimento paralelo**: Frontend e backend foram feitos separadamente
3. **Placeholders**: "• • •" é padrão de UX para dados carregando
4. **Emojis explicativos**: "Como funciona" é informativo (não UI real)

### Por Que Mock DEVE Sair?

1. ❌ **Dados fake**: Usuário toca em follower inexistente
2. ❌ **Sem ação real**: Nenhum convite é enviado
3. ❌ **Não escalável**: 5 usuários hardcoded
4. ❌ **Pobre UX**: Sem feedback real

### Esforço de Implementação

| Tarefa | Horas | Prioridade |
|--------|-------|------------|
| Endpoint `/followers/online` | 1.5h | 🔴 CRÍTICA |
| Models Flutter (Freezed) | 1h | 🟠 ALTA |
| Repository methods | 2h | 🟠 ALTA |
| Riverpod providers | 1.5h | 🟠 ALTA |
| Socket listeners | 1.5h | 🟠 ALTA |
| UI refactor (broadcaster_screen) | 2h | 🟠 ALTA |
| Testing (unit + integration) | 3h | 🟡 MÉDIA |
| Split-screen UI preview | 2h | 🟡 MÉDIA |
| **TOTAL** | **~14.5h** | - |

---

## 🎯 PRÓXIMOS PASSOS PARA O CLAUDE 5

1. **Comece pelo backend**:
   - Implementar `GET /followers/online` endpoint
   - Testar com curl/Postman
   - Validar que retorna dados corretos

2. **Depois, frontend**:
   - Criar models com Freezed
   - Implementar live_repository methods
   - Adicionar riverpod providers

3. **Integre Socket.IO**:
   - Adicionar listeners em socket_service.dart
   - Testar eventos em tempo real

4. **Refatore UI**:
   - Remover mock de broadcaster_screen.dart
   - Usar dados reais da API
   - Adicionar loading/error states

5. **Teste end-to-end**:
   - Criar 2 contas de teste (streamer + follower)
   - Fazer todo fluxo (elegibilidade → convite → accept → split-screen)

---

## 📎 ANEXOS

### Arquivo de Configuração Backend
- **Path**: `brawe-connect/app/routers/live.py`
- **Endpoints**: linhas 1876-2021 (já implementados)
- **Falta**: `GET /followers/online` endpoint

### Arquivo de Configuração Frontend
- **Path**: `lib/ui/broadcaster/widgets/broadcaster_screen.dart`
- **Mock Sheet**: linhas 977-1175
- **Mock List**: linhas 1099-1120
- **Emojis**: linhas 1065-1068

### Arquivo de Modelos
- **Path**: `lib/models/` (criar models aqui)
- **Atual**: user.dart, live_room.dart, etc

### Arquivo de Repositório
- **Path**: `lib/providers/repositories/live_repository.dart`
- **Métodos existentes**: `createBroadcast()`, `endBroadcast()`, etc

---

## 🎬 CONCLUSÃO

### Status
✅ **Análise concluída com sucesso**

### Bloqueadores
🔴 **Endpoint `/followers/online` falta no backend**

### Recomendação
👉 **Começar por implementar o endpoint missing, depois integrar frontend**

### Facilidades
✅ Backend 90% pronto (apenas 1 endpoint faltando)  
✅ APIs bem estruturadas (respostas JSON corretas)  
✅ Socket.IO infrastructure pronta  
✅ Modelos de dados claros  

### Desafios
⚠️ Frontend 100% mock (precisa substituição completa)  
⚠️ UI precisa refator (de placeholder para dados reais)  
⚠️ Integração Socket.IO não feita  
⚠️ Riverpod providers não criados  

---

**Documento preparado para: Claude 5**  
**Data**: 2026-07-15  
**Versão**: 1.0  
**Status**: 🟢 Pronto para implementação
