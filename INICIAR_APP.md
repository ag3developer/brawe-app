# 🚀 Como Iniciar o App Brawe

## ⚡ TL;DR (Opção Rápida)

```bash
cd /Users/josecarlosmartins/Documents/developer/brawe-app
./start-app.sh
```

Pronto! O app vai iniciar automaticamente em 2-3 minutos. ✨

---

## 📚 Guias Disponíveis

### 1. **script `start-app.sh`** ⭐ RECOMENDADO
   - Automatiza tudo em um comando
   - Usa o iPhone 17 Pro Max por padrão
   - Pode passar outro simulador como argumento
   
   ```bash
   ./start-app.sh
   ./start-app.sh "F2522C76-152F-4F1A-AAD4-85191C450EB8"  # iPhone 17 Pro
   ```

### 2. **Guia Completo** (`GUIA_INICIAR_APP_LOCAL.md`)
   - Explicação detalhada de cada etapa
   - Troubleshooting
   - Dicas úteis
   - UUIDs de todos os simuladores

   ```bash
   # Leia o guia
   cat GUIA_INICIAR_APP_LOCAL.md
   # ou abra em um editor
   open GUIA_INICIAR_APP_LOCAL.md
   ```

---

## 🎯 Cenários Rápidos

### Iniciar com o script (padrão)
```bash
./start-app.sh
```

### Iniciar com iPhone 17 Pro
```bash
./start-app.sh "F2522C76-152F-4F1A-AAD4-85191C450EB8"
```

### Iniciar com iPhone 17
```bash
./start-app.sh "B850A910-0B97-45FE-8DA8-CBDB778461EF"
```

### Iniciar manualmente (passo a passo)
```bash
cd /Users/josecarlosmartins/Documents/developer/brawe-app
flutter pub get
xcrun simctl boot "9EC13BF9-977A-42CA-8BF1-FC8A3E6F523B"
flutter run -d "9EC13BF9-977A-42CA-8BF1-FC8A3E6F523B"
```

---

## 🔑 UUIDs dos Simuladores

| Simulador | UUID |
|-----------|------|
| iPhone 17 Pro Max | `9EC13BF9-977A-42CA-8BF1-FC8A3E6F523B` |
| iPhone 17 Pro | `F2522C76-152F-4F1A-AAD4-85191C450EB8` |
| iPhone 17 | `B850A910-0B97-45FE-8DA8-CBDB778461EF` |
| iPhone Air | `FFBD1BD2-EA3D-41ED-BA19-75B32A346882` |
| iPhone 16e | `F5F732BF-E2D9-4301-B32C-44B90E53290C` |

---

## ⌨️ Comandos Úteis Durante Execução

Quando a app está rodando:

| Tecla | Ação |
|-------|------|
| `r` | Hot reload (recarrega código) |
| `R` | Hot restart (reinicia app) |
| `q` | Quit (encerra) |
| `d` | Detach (desanexar debugger) |
| `CMD + S` no VS Code | Auto hot reload |

---

## ❓ Problemas?

Leia o arquivo `GUIA_INICIAR_APP_LOCAL.md` que contém uma seção completa de troubleshooting.

```bash
cat GUIA_INICIAR_APP_LOCAL.md | grep -A 50 "Troubleshooting"
```

---

**Criado em:** 11 de Julho de 2026  
**Projeto:** brawe-app  
**Branch:** refactor/live-architecture
