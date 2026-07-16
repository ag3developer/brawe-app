# Análise: Indicador de Online (Chat vs Perfil)

## Descoberta Principal

O **Chat tem sistema REAL de presença**, enquanto o **Perfil usa mock data**.

---

## Chat: ✅ DADOS REAIS

**Arquivo**: `lib/ui/chat/widgets/chat_detail_screen.dart`

### Como funciona:
1. **Provider de Presença**: `presenceCacheProvider`
   - Localização: `lib/ui/chat/view_models/presence_provider.dart`
   - Polling: **A cada 30 segundos** (automático)
   - Batch: Faz polling de múltiplos usuários de uma vez

2. **Modelo de Dados**: `UserPresence`
   ```dart
   class UserPresence {
     final bool isOnline;        // ← Verdadeiro/Falso
     final DateTime? lastSeen;   // ← Último visto
   }
   ```

3. **Fluxo**:
   ```dart
   // Line 439-441: Busca presença real
   final presence = ref.watch(presenceCacheProvider);
   final p = presence[participantId!];
   final isOnline = p?.isOnline ?? false;  // ← Usa dados reais
   
   // Line 449-459: Status condicional
   if (isOnline) {
     statusText = "Online";
     statusColor = GREEN;
   } else if (lastSeen != null) {
     statusText = "Visto às X";
   } else {
     statusText = "Offline";
   }
   ```

4. **No AppBar**:
   - Mostra avatar com indicador verde **apenas quando online**
   - Exibe status textual (Online/Typing/Visto/Offline)

---

## Perfil: ❌ MOCK DATA

**Arquivo**: `lib/ui/profile/widgets/profile_screen.dart`

### O problema:
- ❌ **Removido agora** (em nossa correção de hoje)
- ✅ Tinha indicador hardcoded em verde sempre
- ✅ Sem verificação de dados reais
- ✅ Sem modelo `UserPresence`

---

## Como Corrigir o Perfil

### Opção 1: Integrar com Chat PresenceProvider (Recomendado)

```dart
// 1. Importar provider
import '../chat/view_models/presence_provider.dart';

// 2. No _buildFull(), adicionar:
final presence = ref.watch(presenceCacheProvider);
final userPresence = presence[userId];
final isOnline = userPresence?.isOnline ?? false;

// 3. Renderizar condicionalmente:
if (isOnline)
  Positioned(
    right: 4,
    bottom: 4,
    child: Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colors.background,
          width: 2,
        ),
      ),
    ),
  ),

// 4. Inicializar watch:
ref.read(presenceCacheProvider.notifier).watch(userId);
```

### Opção 2: Adicionar ao Profile Model
- ❌ Duplicaria sistema de presença
- ❌ Pior performance (duas chamadas de presença)
- ✅ Use a Opção 1 em vez disso

---

## Backend API

**Endpoint**: `GET /chat/presence`
- **Params**: `user_ids` (lista)
- **Response**:
  ```json
  {
    "user_id_1": {
      "is_online": true,
      "last_seen": "2026-07-14T10:30:00Z"
    },
    "user_id_2": {
      "is_online": false,
      "last_seen": "2026-07-14T08:15:00Z"
    }
  }
  ```

---

## Status Atual

| Componente | Status | Dados | Poll |
|-----------|--------|-------|------|
| **Chat** | ✅ Implementado | Reais | 30s |
| **Perfil** | ✅ Removido mock | - | - |
| **Perfil com Presença** | ⏳ TODO | Poderia ser real | 30s |

---

## Próximos Passos

1. **Recomendado**: Integrar perfil com `presenceCacheProvider` (Opção 1)
2. **Alternativa**: Deixar perfil sem indicador até implementação completa
3. **Backend**: Verificar se endpoint `/chat/presence` está funcionando 100%

---

## Conclusão

✅ **Chat está correto!** Usa dados reais de presença.  
✅ **Perfil foi corrigido!** Removemos mock data.  
⏳ **Próximo**: Integrar presença real no perfil (quando quiser).
