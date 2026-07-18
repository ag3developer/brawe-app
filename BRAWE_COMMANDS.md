# 🚀 Comandos Rápidos do Brawe App

Adicione estes aliases no seu `.zshrc` ou `.bash_profile` para facilitar o desenvolvimento:

## Opção 1: Adicionar Aliases Globais (Recomendado)

Abra seu arquivo de configuração shell:
```bash
nano ~/.zshrc
# ou
nano ~/.bash_profile
```

Adicione no final do arquivo:
```bash
# ══════════════════════════════════════════════════════════════════
# 🚀 BRAWE APP - Aliases de Desenvolvimento
# ══════════════════════════════════════════════════════════════════

# Navegar para o projeto
alias brawe="cd /Users/josecarlosmartins/Documents/developer/brawe-app"

# Limpeza automática de Xcode (PRINCIPAL)
alias brawe-clean="bash /Users/josecarlosmartins/Documents/developer/brawe-app/scripts/auto_clean_xcode.sh"

# Setup Git Hooks
alias brawe-setup-hooks="bash /Users/josecarlosmartins/Documents/developer/brawe-app/scripts/setup_git_hooks.sh"

# Abrir no Xcode
alias brawe-xcode="open /Users/josecarlosmartins/Documents/developer/brawe-app/ios/Runner.xcworkspace"

# Abrir release folder
alias brawe-release="open /Users/josecarlosmartins/Documents/developer/brawe-app/build/app/outputs/bundle/release/"

# Build APK
alias brawe-apk="cd /Users/josecarlosmartins/Documents/developer/brawe-app && flutter build apk --release"

# Build App Bundle
alias brawe-aab="cd /Users/josecarlosmartins/Documents/developer/brawe-app && flutter build appbundle --release"

# Build iOS
alias brawe-ios="cd /Users/josecarlosmartins/Documents/developer/brawe-app && flutter build ios --release"

# Rodar app no simulador
alias brawe-run="cd /Users/josecarlosmartins/Documents/developer/brawe-app && flutter run -d iPhone"

# Análise estática
alias brawe-analyze="cd /Users/josecarlosmartins/Documents/developer/brawe-app && flutter analyze"

# Testes
alias brawe-test="cd /Users/josecarlosmartins/Documents/developer/brawe-app && flutter test"

# Pub get
alias brawe-pub="cd /Users/josecarlosmartins/Documents/developer/brawe-app && flutter pub get"

# Informações do projeto
alias brawe-info="echo '📱 BRAWE APP v1.0.33' && echo '📍 Location: /Users/josecarlosmartins/Documents/developer/brawe-app' && echo '🔗 Repo: ag3developer/brawe-app' && echo '🎯 Main: refactor/live-architecture'"

# ══════════════════════════════════════════════════════════════════
```

Depois execute:
```bash
source ~/.zshrc
# ou
source ~/.bash_profile
```

## Opção 2: Criar Script de Aliases Local

Se preferir não mexer no shell rc, crie um script:

```bash
# Salvar como: ~/brawe_aliases.sh

export BRAWE_PATH="/Users/josecarlosmartins/Documents/developer/brawe-app"

alias brawe="cd $BRAWE_PATH"
alias brawe-clean="bash $BRAWE_PATH/scripts/auto_clean_xcode.sh"
alias brawe-setup-hooks="bash $BRAWE_PATH/scripts/setup_git_hooks.sh"
alias brawe-xcode="open $BRAWE_PATH/ios/Runner.xcworkspace"
alias brawe-release="open $BRAWE_PATH/build/app/outputs/bundle/release/"
alias brawe-apk="cd $BRAWE_PATH && flutter build apk --release"
alias brawe-aab="cd $BRAWE_PATH && flutter build appbundle --release"
alias brawe-ios="cd $BRAWE_PATH && flutter build ios --release"
alias brawe-run="cd $BRAWE_PATH && flutter run -d iPhone"
alias brawe-analyze="cd $BRAWE_PATH && flutter analyze"
alias brawe-test="cd $BRAWE_PATH && flutter test"
alias brawe-pub="cd $BRAWE_PATH && flutter pub get"
alias brawe-info="echo '📱 BRAWE APP' && pwd"
```

Depois adicione ao `.zshrc`:
```bash
source ~/brawe_aliases.sh
```

---

## 📖 Uso dos Comandos

### 🧹 **Limpeza de Xcode (MAIS IMPORTANTE)**
```bash
brawe-clean
```
Limpa todos os caches obsoletos do Xcode automaticamente. Use quando:
- Xcode não reconhece versão iOS correta
- Erro de build "firebase-core requires minimum platform version 15.0"
- Problemas de configuração obsoleta

### ⚙️ **Configurar Git Hooks** (Uma Única Vez)
```bash
brawe-setup-hooks
```
Ativa limpeza automática ao fazer pull/merge/checkout

### 🏃 **Navegação Rápida**
```bash
brawe              # Vai para o diretório do projeto
brawe-xcode        # Abre Xcode
brawe-release      # Abre pasta de release (AAB/APK)
```

### 🔨 **Build**
```bash
brawe-apk          # Build APK
brawe-aab          # Build App Bundle (recomendado)
brawe-ios          # Build iOS
brawe-run          # Rodar em simulador
```

### 📊 **Análise**
```bash
brawe-analyze      # Flutter analyze
brawe-test         # Flutter test
brawe-pub          # flutter pub get
brawe-info         # Informações do projeto
```

---

## 🤖 Automação Completa (Recomendado)

Para configurar TUDO automaticamente de uma vez:

```bash
# 1. Ir para o projeto
cd /Users/josecarlosmartins/Documents/developer/brawe-app

# 2. Tornar scripts executáveis
chmod +x scripts/*.sh

# 3. Executar limpeza inicial
./scripts/auto_clean_xcode.sh

# 4. Configurar Git Hooks
./scripts/setup_git_hooks.sh

# 5. Adicionar aliases ao shell (siga Opção 1 acima)

# 🎉 Pronto! Agora use: brawe-clean, brawe-xcode, etc.
```

---

## ✅ Verificação

Para verificar se tudo foi configurado:

```bash
# Testar um alias
brawe-info

# Verificar Git Hooks
git config core.hooksPath

# Listar arquivos de hooks
ls -la .githooks/
```

---

## 💡 Dica Pro

Crie um pequeno script que executa frequentemente:

```bash
# Salve como: ~/run_brawe_daily.sh
#!/bin/bash
cd /Users/josecarlosmartins/Documents/developer/brawe-app
./scripts/auto_clean_xcode.sh
open ios/Runner.xcworkspace
```

Depois deixe em cron para executar automaticamente toda manhã!

---

## 🆘 Troubleshooting

Se os aliases não funcionarem:

```bash
# Verificar se o arquivo foi carregado
echo $SHELL

# Recarregar shell
exec $SHELL

# Testar um comando diretamente
bash /Users/josecarlosmartins/Documents/developer/brawe-app/scripts/auto_clean_xcode.sh
```

