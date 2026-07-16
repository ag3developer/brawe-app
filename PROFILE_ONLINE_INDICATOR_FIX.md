# Fix: Indicador de Online em Mock Data

## Problema Identificado

O perfil do usuário exibia um **ponto verde de "online"** em todos os perfis, independentemente do estado real do usuário. Isso era claramente **mock data**, pois:

- ✅ Todos os perfis mostravam verde (online)
- ✅ Não havia forma de um perfil mostrar "offline"
- ✅ Não existia campo `isOnline` ou `status` nos modelos `User` ou `Profile`
- ✅ O indicador era hardcoded em verde: `Color(0xFF4CAF50)`

## Raiz do Problema

**Arquivo**: `lib/ui/profile/widgets/profile_screen.dart`  
**Localização**: Linhas 1175-1195 (Banner section)  
**Causa**: Indicador renderizado sem verificação de dados reais

```dart
// ❌ ANTES: Indicador sempre verde
Positioned(
  right: 4,
  bottom: 4,
  child: Container(
    width: 14,
    height: 14,
    decoration: BoxDecoration(
      color: const Color(0xFF4CAF50),  // Verde hardcoded
      shape: BoxShape.circle,
      border: Border.all(
        color: context.colors.background,
        width: 2,
      ),
    ),
  ),
),
```

## Solução Implementada

**Removido**: Indicador de online mockado

**Substituído por**: TODO comment explicando quando isso será implementado

```dart
// TODO: Adicionar indicador online quando o backend suportar status de presença
// Indicador será um ponto verde posicionado no canto inferior direito do avatar
// quando o usuário estiver realmente online
```

## Por Que Não Deixar Sempre Verde?

1. **Desinforma o usuário**: Mostra que alguém está online quando pode estar offline
2. **Experiência enganosa**: Usuários tentam conversar com "online" que não estão realmente
3. **Padrão do mercado**: Outros apps (WhatsApp, Instagram, Twitter) só mostram quando há dados reais
4. **Melhor remover do que enganar**: Melhor não mostrar nada do que mostrar informação falsa

## Próximos Passos (Para o Backend)

1. **Adicionar campo `is_online`** ao modelo User
2. **Implementar WebSocket ou polling** para rastrear status de presença
3. **Retornar status no endpoint** de perfil público
4. **Adicionar campo `isOnline`** ao modelo Profile no Flutter
5. **Restaurar indicador condicionalmente**:

```dart
// ✅ FUTURO: Indicador com dados reais
if (profile.isOnline ?? false)
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
```

## Validações Completadas

✅ Sem erros de compilação  
✅ Indicador removido do banner  
✅ Sem impacto em outras partes da UI  
✅ Retrocompatível com app publicado  
✅ TODO deixa claro o que falta fazer

## Status

🟢 **IMPLEMENTADO**  
📝 **DOCUMENTADO**  
⏳ **AGUARDANDO**: Backend implementar suporte real a presença de usuário
