# 📱 Guia Completo: Como Iniciar o App Brawe Localmente

---

## ⚡ TL;DR - Comece Aqui!

### 🚀 Comando Mais Rápido (RECOMENDADO):

```bash
cd /Users/josecarlosmartins/Documents/developer/brawe-app && ./start-app.sh
```

**Pronto!** A app inicia em ~2-3 minutos de forma automática.

---

## Sumário
1. [Pré-requisitos](#pré-requisitos)
2. [Início Rápido com Script](#opção-1-usar-o-script-recomendado---mais-rápido) ⭐ RECOMENDADO
3. [Passo a Passo Manual](#opção-2-executar-manualmente-mais-controle)
4. [Detalhes de Cada Etapa](#detalhes-de-cada-etapa)
5. [Troubleshooting](#troubleshooting)
6. [Dicas Úteis](#dicas-úteis)

---

## Pré-requisitos

Certifique-se que você tem:
- ✅ Flutter SDK instalado
- ✅ Xcode instalado (com iOS Simulator)
- ✅ CocoaPods instalado
- ✅ Projeto brawe-app clonado em `/Users/josecarlosmartins/Documents/developer/brawe-app`

---

## Passo a Passo Rápido

### 🟢 Opção 1: Usar o Script (RECOMENDADO - Mais Rápido!)

Se você quer iniciar com um único comando:

```bash
# Navigate até o projeto
cd /Users/josecarlosmartins/Documents/developer/brawe-app

# Torne o script executável (apenas primeira vez)
chmod +x start-app.sh

# Execute o script (usa iPhone 17 Pro Max por padrão)
./start-app.sh

# OU use outro simulador passando o UUID
./start-app.sh "F2522C76-152F-4F1A-AAD4-85191C450EB8"  # iPhone 17 Pro
./start-app.sh "B850A910-0B97-45FE-8DA8-CBDB778461EF"  # iPhone 17
```

**Vantagens:**
- ✅ Apenas um comando
- ✅ Automático do início ao fim
- ✅ Verifica erros automaticamente
- ✅ Abre o Simulator automaticamente
- ✅ Output colorido e fácil de entender

---

### 🟡 Opção 2: Executar Manualmente (Mais Controle)

Se você prefere executar cada etapa manualmente:

```bash
# 1. Navegue até o projeto
cd /Users/josecarlosmartins/Documents/developer/brawe-app

# 2. Obtenha as dependências
flutter pub get

# 3. Liste os simuladores disponíveis
xcrun simctl list devices available | grep -i "iPhone"

# 4. Inicie o simulador desejado (exemplo: iPhone 17 Pro Max)
xcrun simctl boot "9EC13BF9-977A-42CA-8BF1-FC8A3E6F523B"

# 5. Execute o app no simulador
flutter run -d "9EC13BF9-977A-42CA-8BF1-FC8A3E6F523B"

# 6. Abra o Simulator visualmente (se não aparecer)
open -a "Simulator"
```

**Vantagens:**
- ✅ Mais controle sobre cada etapa
- ✅ Útil para debugging
- ✅ Pode pausar em qualquer momento

---

## Detalhes de Cada Etapa

### **Etapa 1: Verificar Localização do Projeto**

```bash
cd /Users/josecarlosmartins/Documents/developer/brawe-app
pwd
ls -la pubspec.yaml
```

**Esperado:** 
- Seu caminho deve ser `/Users/josecarlosmartins/Documents/developer/brawe-app`
- O arquivo `pubspec.yaml` deve existir

---

### **Etapa 2: Obter Dependências**

```bash
flutter pub get
```

**Esperado:**
```
Resolving dependencies... 
Downloading packages... 
Got dependencies!
48 packages have newer versions incompatible with dependency constraints.
```

⚠️ Os avisos sobre versões mais novas são normais e podem ser ignorados.

---

### **Etapa 3: Listar Dispositivos e Simuladores**

#### Opção A: Ver tudo (dispositivos + simuladores)
```bash
flutter devices
```

**Saída esperada:**
```
Found 2 connected devices:
  macOS (desktop) • macos  • darwin-x64     • macOS 15.7.3 24G419 darwin-x64
  Chrome (web)    • chrome • web-javascript • Google Chrome 149.0.7827.201

Found 1 wirelessly connected device:
  iPhone de Jose Carlos (wireless) (mobile) • 00008130-000409C621D3803A • ios •
  iOS 26.5 23F77
```

#### Opção B: Ver apenas simuladores iOS
```bash
xcrun simctl list devices available | grep -i "iPhone"
```

**Saída esperada:**
```
    iPhone 17 Pro (F2522C76-152F-4F1A-AAD4-85191C450EB8) (Shutdown) 
    iPhone 17 Pro Max (9EC13BF9-977A-42CA-8BF1-FC8A3E6F523B) (Shutdown) 
    iPhone Air (FFBD1BD2-EA3D-41ED-BA19-75B32A346882) (Shutdown) 
    iPhone 17 (B850A910-0B97-45FE-8DA8-CBDB778461EF) (Shutdown) 
    iPhone 16e (F5F732BF-E2D9-4301-B32C-44B90E53290C) (Shutdown) 
```

---

### **Etapa 4: Iniciar o Simulador**

Use um dos UUIDs do passo anterior:

```bash
# iPhone 17 Pro Max (recomendado)
xcrun simctl boot "9EC13BF9-977A-42CA-8BF1-FC8A3E6F523B"

# OU iPhone 17 Pro
xcrun simctl boot "F2522C76-152F-4F1A-AAD4-85191C450EB8"

# OU iPhone 17
xcrun simctl boot "B850A910-0B97-45FE-8DA8-CBDB778461EF"
```

**Esperado:** Comando retorna sem erros (leva alguns segundos)

---

### **Etapa 5: Executar Flutter no Simulador**

```bash
# Para iPhone 17 Pro Max
flutter run -d "9EC13BF9-977A-42CA-8BF1-FC8A3E6F523B"

# OU para iPhone 17 Pro
flutter run -d "F2522C76-152F-4F1A-AAD4-85191C450EB8"

# OU para iPhone 17
flutter run -d "B850A910-0B97-45FE-8DA8-CBDB778461EF"
```

**O que vai acontecer:**
1. Compilação do Swift Package Manager (~1-2 minutos)
2. Build do Xcode (~1-2 minutos)
3. App inicia no simulador
4. Logs do Flutter aparecem no terminal

**Esperado:** Quando terminar, você vê logs como:
```
flutter: Socket.IO: Connected
flutter: *** Response ***
flutter: uri: https://app.brawe.io/api/v1/auth/me
flutter: statusCode: 200
```

---

### **Etapa 6: Visualizar o Simulador**

Se a janela do simulador não aparecer automaticamente:

```bash
open -a "Simulator"
```

Ou use **CMD + Tab** para alternar entre aplicações abertas.

---

## Troubleshooting

### ❌ Erro: "The package product 'gal' requires minimum platform version 11.0 for the macOS platform"

**Causa:** Problema ao tentar rodar no macOS desktop (não no simulador iOS).

**Solução:** Use o simulador iOS em vez do macOS desktop.

```bash
# ❌ Evite
flutter run -d macos

# ✅ Use em vez disso
flutter run -d "9EC13BF9-977A-42CA-8BF1-FC8A3E6F523B"
```

---

### ❌ Erro: "Simulador não encontrado"

**Causa:** UUID do simulador inválido ou simulador não criado.

**Solução:** Liste os simuladores disponíveis novamente:
```bash
xcrun simctl list devices available
```

Copie o UUID correto (entre parênteses).

---

### ❌ Erro: "Xcode build failed"

**Causa:** Problemas de cache ou dependências.

**Solução:** Limpe e reconfigure (com autorização):
```bash
flutter clean
flutter pub get
flutter run -d "9EC13BF9-977A-42CA-8BF1-FC8A3E6F523B"
```

---

### ⚠️ Aviso: "The following plugins do not support Swift Package Manager"

**O que é:** Aviso sobre plugins (`record_darwin`, `flutter_native_video_trimmer`, etc.)

**É crítico?** Não! É apenas um aviso. A app funciona normalmente.

**Será corrigido?** Sim, quando os mantainers dos plugins atualizarem para Swift Package Manager.

---

## Dicas Úteis

### 🔥 Hot Reload

Depois que a app está rodando, você pode fazer mudanças no código e pressionar:

```
r    - Hot reload (recarrega apenas o código alterado)
R    - Hot restart (reinicia a app)
q    - Quit (sair)
```

No editor VS Code, simplesmente salve o arquivo (`CMD + S`) e o hot reload é acionado automaticamente!

---

### 📋 Usar o Script

Um arquivo `start-app.sh` já foi criado na raiz do projeto! Ele automatiza todo o processo.

**Primeira vez (setup):**
```bash
cd /Users/josecarlosmartins/Documents/developer/brawe-app
chmod +x start-app.sh
```

**Depois, sempre que quiser iniciar:**
```bash
./start-app.sh
```

**Com um simulador diferente:**
```bash
./start-app.sh "F2522C76-152F-4F1A-AAD4-85191C450EB8"  # iPhone 17 Pro
./start-app.sh "B850A910-0B97-45FE-8DA8-CBDB778461EF"  # iPhone 17
```

**O script faz automaticamente:**
- ✅ Verifica se o projeto está correto
- ✅ Obtém as dependências
- ✅ Inicia o simulador
- ✅ Abre a janela do Simulator
- ✅ Executa o Flutter
- ✅ Mostra dicas úteis durante a execução
- ✅ Trata erros automaticamente

---

### 🎯 Usar Outro Simulador

Simplesmente mude o UUID:

```bash
# iPhone 17 Pro
xcrun simctl boot "F2522C76-152F-4F1A-AAD4-85191C450EB8"
flutter run -d "F2522C76-152F-4F1A-AAD4-85191C450EB8"

# iPhone 17
xcrun simctl boot "B850A910-0B97-45FE-8DA8-CBDB778461EF"
flutter run -d "B850A910-0B97-45FE-8DA8-CBDB778461EF"
```

---

### 🛑 Parar a App

No terminal onde o Flutter está rodando, pressione:
- `q` para sair
- `CTRL + C` se `q` não funcionar

---

## Resumo de UUIDs dos Simuladores

| Simulador | UUID |
|-----------|------|
| iPhone 17 Pro Max | `9EC13BF9-977A-42CA-8BF1-FC8A3E6F523B` |
| iPhone 17 Pro | `F2522C76-152F-4F1A-AAD4-85191C450EB8` |
| iPhone 17 | `B850A910-0B97-45FE-8DA8-CBDB778461EF` |
| iPhone Air | `FFBD1BD2-EA3D-41ED-BA19-75B32A346882` |
| iPhone 16e | `F5F732BF-E2D9-4301-B32C-44B90E53290C` |

---

## Próximas Vezes

Quando quiser iniciar a app novamente:

1. Abra terminal
2. Execute os comandos da seção [Passo a Passo Rápido](#passo-a-passo-rápido)
3. Pronto! 🚀

---

**Última atualização:** 11 de Julho de 2026  
**Versão Flutter:** Recomendada (verifique com `flutter --version`)  
**Branch do Projeto:** refactor/live-architecture
