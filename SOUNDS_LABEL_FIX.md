# Fix: Sounds Label - Texto Cortado

## Problema Identificado

O label "Brawe Sounds" no menu de criação estava sendo cortado, exibindo apenas "Brawe Sou..." na UI.

**Sintoma**:
```
Menu de Criação:
┌──────────────────────────┐
│ 📷 Story │ 🎥 Video     │
│ ✏️ Post  │ 🎵 Brawe Sou...│ ← Cortado!
└──────────────────────────┘
```

---

## Raiz do Problema

O espaço disponível no layout é limitado para 2 itens por linha. O texto "Brawe Sounds" (13 caracteres) é longo demais e ultrapassa o espaço do botão.

---

## Solução Implementada

Alterado o label de **"Brawe Sounds" → "Sounds"** em todos os idiomas.

### Arquivos Alterados

1. **`lib/l10n/app_pt.arb`** (Português)
   ```json
   "createSoundsTitle": "Brawe Sounds"  →  "createSoundsTitle": "Sounds"
   ```

2. **`lib/l10n/app_en.arb`** (Inglês)
   ```json
   "createSoundsTitle": "Brawe Sounds"  →  "createSoundsTitle": "Sounds"
   ```

3. **`lib/l10n/app_es.arb`** (Espanhol)
   ```json
   "createSoundsTitle": "Brawe Sounds"  →  "createSoundsTitle": "Sounds"
   ```

---

## Resultado

### Antes ❌
```
Menu de Criação:
┌──────────────────────────┐
│ 📷 Story  │ 🎥 Video    │
│ ✏️ Post   │ 🎵 Brawe Sou...│ ← Cortado
└──────────────────────────┘
```

### Depois ✅
```
Menu de Criação:
┌──────────────────────────┐
│ 📷 Story  │ 🎥 Video    │
│ ✏️ Post   │ 🎵 Sounds   │ ← Completo!
└──────────────────────────┘
```

---

## Impacto

✅ **UX Improvement**:
- Texto completo e visível
- Sem truncamento
- Melhor legibilidade

✅ **Validações**:
- ✅ Alterado em 3 idiomas (PT, EN, ES)
- ✅ Sem impacto em outras strings
- ✅ Retrocompatível
- ✅ Pronto para produção

---

## Contexto

O menu de criação tem 5 botões distribuídos em 2 linhas:
- **Linha 1**: Story, Video, Live (3 itens)
- **Linha 2**: Post, Sounds (2 itens + spacer)

Cada botão tem espaço limitado (~72px), então textos longos são truncados.

---

## Status

🟢 **IMPLEMENTADO E VALIDADO**
- ✅ Alterado em todos idiomas
- ✅ Texto agora visível
- ✅ Layout melhorado
- ✅ Pronto para produção

