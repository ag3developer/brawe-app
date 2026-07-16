# 🎙️ CO-HOST - SUMÁRIO EXECUTIVO (QUICK REFERENCE)

**Preparado para**: Claude 5  
**Data**: 2026-07-15  
**Tempo de leitura**: 5 min  

---

## 🚨 PROBLEMA

| Item | Status |
|------|--------|
| **Tela de Co-host** | ✅ Criada |
| **Dados** | ❌ 100% mock (5 usuários fake) |
| **Backend APIs** | ✅ 90% pronto |
| **Emojis** | ⚠️ Aparecem apenas em "Como funciona" (OK, mas pode remover) |
| **Socket.IO** | ❌ Listeners não implementados |
| **Integração** | ❌ 0% (mock não chama API) |

### O que Falta?

1. ❌ **Backend**: 1 endpoint (`GET /followers/online`)
2. ❌ **Frontend**: Repository methods (5 métodos)
3. ❌ **Frontend**: Riverpod providers (4 provedores)
4. ❌ **Frontend**: Socket listeners (4 eventos)
5. ❌ **Frontend**: UI refactor (remover mock)

---

## 📂 ARQUIVOS PRINCIPAIS

### Frontend

```
lib/ui/broadcaster/widgets/
  ├── broadcaster_screen.dart          ← CO-HOST SHEET (linhas 977-1175)
  └── live_action_bar.dart            ← BOTÃO "Co-host" (linhas 74-76)

lib/providers/repositories/
  └── live_repository.dart             ← ADICIONAR 5 MÉTODOS

lib/core/services/
  └── socket_service.dart              ← ADICIONAR 4 LISTENERS

lib/models/ (CRIAR NOVOS)
  ├── cohost_invite.dart
  ├── cohost_eligibility.dart
  └── follower_online.dart
```

### Backend

```
brawe-connect/app/routers/
  └── live.py                          ← ADICIONAR 1 ENDPOINT

brawe-connect/app/services/
  ├── streamer_eligibility.py          ✅ JÁ TEM REGRAS
  ├── cohost_service.py                ✅ JÁ TEM LÓGICA
  └── notification_service.py          ✅ JÁ TEM NOTIFICAÇÃO
```

---

## 🎯 PRIORIDADES

### 🔴 CRÍTICA (Bloqueia tudo)
- [ ] Backend: Implementar `GET /followers/online` endpoint
  - Retornar: id, name, avatar, followers_count, is_live, can_be_cohost, tier
  - Arquivo: `brawe-connect/app/routers/live.py` (após linha 2021)
  - Tempo: ~1.5h

### 🟠 ALTA (Sem isso não funciona)
- [ ] Frontend: Criar models (Freezed)
  - [ ] `FollowerOnline`
  - [ ] `CoHostEligibility`
  - [ ] `CoHostInvite`
  - Tempo: ~1h

- [ ] Frontend: Repository methods (5)
  - [ ] `checkCoHostEligibility()`
  - [ ] `fetchFollowersOnline()`
  - [ ] `inviteCoHost()`
  - [ ] `acceptCoHostInvite()`
  - [ ] `leaveCoHost()`
  - Tempo: ~2h

- [ ] Frontend: Riverpod providers (4)
  - [ ] `coHostEligibilityProvider`
  - [ ] `followersOnlineProvider`
  - [ ] `coHostInviteNotifier`
  - [ ] Socket events listener
  - Tempo: ~1.5h

- [ ] Frontend: Socket.IO listeners (4)
  - [ ] `socket.on('cohost_invite')`
  - [ ] `socket.on('cohost_accepted')`
  - [ ] `socket.on('screen_split_ready')`
  - [ ] `socket.on('cohost_left')`
  - Tempo: ~1.5h

- [ ] Frontend: UI refactor
  - [ ] Remover mock de `broadcaster_screen.dart`
  - [ ] Conectar a dados reais
  - [ ] Adicionar loading/error states
  - Tempo: ~2h

### 🟡 MÉDIA (Polish)
- [ ] Testing (unit + integration)
- [ ] Emojis: Manter OU substituir por Lucide Icons

---

## 🔗 ENDPOINTS

### Existem ✅
```bash
GET    /api/rooms/{room_id}/cohost/eligibility
POST   /api/rooms/{room_id}/cohost/invite
POST   /api/rooms/{room_id}/cohost/accept
POST   /api/rooms/{room_id}/cohost/leave
```

### Falta ❌
```bash
GET    /api/users/followers/online
       # Deve retornar lista de followers que estão online
       # Filtrado por: eligibilidade (ARTIST tier+), status online
```

---

## 📊 ESTRUTURA DE DADOS

### Response: `GET /followers/online`
```json
{
  "success": true,
  "data": [
    {
      "user_id": "uuid-1",
      "name": "João Silva",
      "avatar_url": "https://...",
      "followers_count": 2500,
      "is_live": false,
      "can_be_cohost": true,
      "tier": "CREATOR"
    }
  ]
}
```

### Response: `GET /cohost/eligibility`
```json
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

### Regras de Elegibilidade
- Streamer: Tier ≥ CREATOR (gerou $50+), 500+ followers, 10+ lives
- Guest: Tier ≥ ARTIST (mínimo), 100+ followers, 3+ lives

---

## 🔄 FLUXO (Simplificado)

```
User clicks "Co-host"
    ↓
CHECK ELIGIBILITY (GET /cohost/eligibility)
    ├─ NOT ELIGIBLE → Show error + requirements
    └─ ELIGIBLE → Continue
        ↓
LOAD FOLLOWERS (GET /followers/online)
    ↓
SHOW REAL LIST (not mock)
    ↓
User selects follower
    ↓
SEND INVITE (POST /cohost/invite)
    ↓
Socket event: 'cohost_invite' → Guest notification
    ↓
Guest accepts
    ↓
Socket events: 'cohost_accepted' + 'screen_split_ready'
    ↓
Both screens update to split-screen mode
```

---

## 🧩 CÓDIGO MOCK ATUAL

### Antes (Mock - AGORA)
```dart
// broadcaster_screen.dart, linhas 1099-1120
ListView.builder(
  itemCount: 5,  // ❌ HARDCODED
  itemBuilder: (_, i) => Column(
    children: [
      Container(
        width: 44, height: 44,
        Icon(Icons.person_outline)  // ❌ PLACEHOLDER
      ),
      Text('• • •')  // ❌ FAKE NAME
    ],
  ),
)
```

### Depois (Real - CLAUDE 5)
```dart
// broadcaster_screen.dart
ListView.builder(
  itemCount: followers.length,  // ✅ DINÂMICO
  itemBuilder: (_, i) {
    final follower = followers[i];
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(follower.avatarUrl),  // ✅ REAL AVATAR
        ),
        Text(follower.name),  // ✅ REAL NAME
        Text('${follower.followersCount} followers'),  // ✅ REAL COUNT
      ],
    );
  },
)
```

---

## 🎨 SOBRE OS EMOJIS

### Localização Atual
```dart
// broadcaster_screen.dart, linhas 1065-1068
'📲 O co-host recebe uma notificação'
'🎥 A tela divide automaticamente'
'💬 Vocês compartilham o chat ao vivo'
'⏱ Sem limite de tempo'
```

### Status
✅ **CORRETO** - Aparecem apenas na seção "Como funciona" (informativa)  
✅ **NÃO SÃO PROBLEMA** - Explicam a feature, não prejudicam a UI

### Opção: Remover?
Se quiser, substituir por ícones Lucide:
```dart
LucideIcons.bell,           // em vez de 📲
LucideIcons.video,          // em vez de 🎥
LucideIcons.messageCircle,  // em vez de 💬
LucideIcons.clock,          // em vez de ⏱
```

**Recomendação**: Manter emojis (mais amigável)

---

## ⚡ PRÓXIMOS PASSOS

### Phase 1: Backend (1-2h)
1. Criar endpoint `GET /followers/online`
2. Testar com curl/Postman
3. Validar responses

### Phase 2: Frontend Models (1h)
1. Criar 3 models com Freezed
2. Adicionar serialization (fromJson)

### Phase 3: Frontend Integration (5-7h)
1. Implementar 5 repository methods
2. Implementar 4 riverpod providers
3. Adicionar 4 socket listeners
4. Refatar UI em broadcaster_screen.dart

### Phase 4: Testing (2-3h)
1. Unit tests
2. Integration tests
3. Manual testing Android + iOS

---

## 📋 CHECKLIST RÁPIDO

**Backend**:
- [ ] Endpoint `/followers/online` criado
- [ ] Returns correct JSON
- [ ] Tested with curl

**Frontend**:
- [ ] Models criados (Freezed)
- [ ] Repository methods implementados
- [ ] Riverpod providers criados
- [ ] Socket listeners adicionados
- [ ] Mock removido de broadcaster_screen.dart
- [ ] UI conectada a dados reais
- [ ] Loading/error states funcionando

**Testing**:
- [ ] Android device test
- [ ] iOS device test
- [ ] Full flow tested (elegibilidade → convite → accept → split-screen)

---

## 🎯 RESULTADO ESPERADO

### Antes
❌ 5 usuários fake + "Co-host em breve!" toast + nada acontece

### Depois
✅ Lista real de followers online  
✅ Click para convidar → Backend recebe → Guest notificado  
✅ Guest aceita → Split-screen mode ativado  
✅ Real-time com Socket.IO  
✅ Funcional 100%

---

## 📚 DOCUMENTAÇÃO COMPLETA

Consulte para mais detalhes:

1. **`COHOST_DIAGNOSTICO_COMPLETO.md`**
   - Análise detalhada de todos os arquivos
   - Endpoints documentados
   - Checklist completo

2. **`COHOST_ARQUITETURA_DIAGRAMA.md`**
   - Diagramas de arquitetura
   - Fluxos de dados
   - Sequência de eventos
   - Estrutura de modelos

---

## 💬 RESUMO

### Em 1 minuto
O co-host hoje é 100% mock. Falta integração com backend (1 endpoint missing) e frontend (repository + providers + listeners). Emojis estão certos (apenas informativos). Esforço total: ~14.5 horas.

### Em 30 segundos
Mock → Real. Backend falta 1 endpoint. Frontend falta integração. Pode começar!

---

**Status**: 🟢 Pronto para Claude 5 implementar  
**Bloqueador**: Nenhum (análise completa)  
**Risco**: Baixo (APIs já existem, só falta 1 endpoint)

Bom trabalho, Claude 5! 🚀
