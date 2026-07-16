# Brawe App - Versão 1.0.28 (Build 28)

**Data de Release:** 14 de julho de 2026

## 🎯 Principais Mudanças

### ✅ Correções de Bugs Críticos

#### 1. **Perfil do Usuário - Navegação após salvar** 
- ✨ Novos usuários agora são redirecionados corretamente para `/home` após salvar o perfil na onboarding
- 🔧 Implementado `authStateProvider.notifier.updateSession()` para sincronizar avatar URL
- 📱 A sessão agora reflete corretamente o avatar carregado

#### 2. **Aba Posts - Mostrar todos os tipos de conteúdo**
- 📹 Aba Posts agora exibe TODOS os posts (texto, fotos e vídeos)
- ✨ Removido filtro que ocultava posts com mídia
- 🎬 Exibição unificada de conteúdo na aba Posts

#### 3. **Data de Criação do Perfil - Valor real**
- 📅 Perfis agora mostram a data de criação real do backend
- 🔧 Corrigido campo `created_at` no modelo Profile (Freezed)
- ❌ Removida dependência de data mock do usuário logado

#### 4. **Indicador de Online - Status em tempo real**
- 🟢 Status online agora sincroniza com presença real do usuário
- 🔄 Integração com `presenceCacheProvider` (polling a cada 30s)
- 🔌 Socket events atualizam status em tempo real
- 📊 Refatorado `_OnlineIndicator` como ConsumerWidget

### 🎨 Melhorias Visuais

#### 5. **Grid de Vídeos no Perfil - Proporções corretas**
- 📐 Mudado de 9:16 para 3:4 (Instagram Stories)
- 📏 Altura reduzida de 326px para 244px
- 📸 Encapsulado cada tile em `AspectRatio(3/4)`

#### 6. **Visibilidade de Sobreposições em Vídeos - Contraste melhorado**
- 🎬 Likes, views, captions agora com `Colors.white + Shadow`
- 🌙 Shadow com `color: Colors.black87, blurRadius: 2`
- ✨ Garantida legibilidade em qualquer background de vídeo
- 📹 Aplicado a grid, fullscreen e viewer

#### 7. **Labels de Navegação - Sem truncamento**
- 🎵 "Brawe Sounds" → "Sounds" (cabe sem truncamento)
- 📱 Melhor UX em telas pequenas
- 🌍 Atualizado em app_pt.arb, app_en.arb, app_es.arb

### 🔄 Melhorias no Backend (Sincronizadas)

#### 8. **Categorias de Lives - Validação robusta**
- ✅ 242 lives agora com categorias válidas
- 🔧 Migrado de ENUM bugado para validação Pydantic
- 📊 12 categorias suportadas: Shopping, Gaming, Talk Show, Música, Educação, Fitness, Culinária, Beleza, Tecnologia, Esportes, Entretenimento, Outro
- 🛡️ Validação em tempo de criação/atualização de lives

#### 9. **Explore Page - Carregamento correto**
- 📍 Endpoint `/explore/categories` agora retorna dados corretos
- 🎬 Sem mais erros de ENUM mismatch
- 📱 Frontend carrega categorias sem spinner infinito

## 📊 Detalhes Técnicos

| Métrica | Valor |
|---------|-------|
| Versão | 1.0.28 |
| Build Number | 28 |
| Versão Anterior | 1.0.27+27 |
| Tamanho AAB | ~90-100MB (estimado) |
| Plataformas | Android + iOS |
| Min SDK Android | API 21 (5.0) |
| Target SDK Android | API 35 (15.0) |

## 🚀 Instruções de Deploy

### Google Play Console - Android

1. **Upload do AAB:**
   - Acesse: https://play.google.com/console
   - Selecione app "Brawe"
   - Vá para: Release > Production
   - Clique: "Create new release"
   - Upload: `build/app/outputs/bundle/release/app-release.aab`

2. **Preencher informações:**
   - Version Name: 1.0.28
   - Version Code: 28
   - Release Notes (PT-BR):
     ```
     ✨ Novidades:
     • Perfil: data de criação real, indicador online em tempo real
     • Posts: exibe texto, fotos e vídeos unificados
     • Vídeos: grid com proporção 3:4, overlay com melhor visibilidade
     • Live: categorias validadas e funcionando na página Explore
     • Correções: navegação após salvar perfil, sincronização de dados
     ```

3. **Review & Release:**
   - Google Play pode levar 1-3 horas para revisar
   - Após aprovação, release automático em Production

### App Store - iOS

**Já enviado na etapa anterior (v1.0.28 iOS)** via Xcode Archive

## 🔗 Links Relacionados

- **Git Branch:** refactor/live-architecture
- **Backend Version:** Latest (com validação de categorias)
- **Database State:** 242 lives com categorias válidas

## ✅ Checklist de QA

- [x] Perfil salva e redireciona corretamente
- [x] Posts tab mostra todos os tipos de conteúdo
- [x] Data de criação é real
- [x] Online indicator funciona
- [x] Grid de vídeos com proporção correta
- [x] Overlays visíveis em qualquer background
- [x] Explore page carrega sem erros
- [x] Build Android compila sem erros
- [x] Build iOS compila sem erros

## 📝 Notas

- Todos os testes manuais passaram
- Sem breaking changes
- Backward compatible com 1.0.27
- Pronto para produção em ambas plataformas

---

**Build Date:** 2026-07-14 21:30 UTC
**Built by:** GitHub Copilot + Flutter CLI
