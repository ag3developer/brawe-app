# 🚀 Checklist — Brawe App v1 (Lançamento Inicial)

> Objetivo: liberar **versão pública mínima** onde usuários conseguem **criar conta, completar perfil, consumir conteúdo, criar conteúdo e interagir socialmente**.
> Última atualização: 12/05/2026

---

## ✅ FASE 1 — JÁ ENTREGUE (Core funcional)

### Autenticação
- [x] Welcome / Login / Signup
- [x] Persistência de sessão (`flutter_secure_storage`)
- [x] Refresh listenable no GoRouter

### Feed & Conteúdo
- [x] For You (vídeo + foto + lives)
- [x] Feed clássico (posts)
- [x] Live feed + Live player
- [x] Stories (viewer)
- [x] Likes / Repost / Comments (sheet)

### Perfil
- [x] Profile screen (próprio + de terceiros)
- [x] Stats card (followers/following/lives/viewers)
- [x] Tabs (lives + posts)
- [x] **Editar perfil** (avatar, banner, bio, social links) ✨ recém-entregue

### Social
- [x] Follow / Unfollow
- [x] Follows screen (followers + following tabs)
- [x] Notificações + unread count
- [x] Chat (lista + detalhe)

### Live
- [x] Start live (broadcaster)
- [x] Player com gifts e chat
- [x] Live commerce / battle / chat views

### Outros
- [x] Quests
- [x] Wallet (saldo + extrato)
- [x] Settings (theme, idioma, privacidade)

---

## 🔴 FASE 2 — BLOQUEADORES DE LANÇAMENTO (P0)

### 🐛 Bugs conhecidos
- [ ] **404 em `GET /users/{id}/products`** (profile screen tenta carregar produtos inexistentes) — implementar endpoint OU esconder aba até v2
- [ ] Hot restart às vezes necessário após mudanças em router (sem impacto pro usuário final)
- [ ] Loop de chamadas `/profile/me` ao abrir Editar Perfil rapidamente em sequência (debounce)

### 🔐 Autenticação completa
- [ ] **"Esqueci minha senha"** (recuperação por email)
- [ ] **Verificação de email** no signup (link/código)
- [ ] **Login social** (Google / Apple) — *Apple é OBRIGATÓRIO para a App Store*
- [ ] **Aceite de Termos de Uso e Política de Privacidade** no cadastro
- [ ] **Logout** funcional e visível em Settings

### 📱 Configuração de plataforma (build release)
- [ ] **Android:** trocar `applicationId = "com.example.brawe_app"` → `io.brawe.app` (ou similar)
- [ ] **Android:** keystore de produção + `signingConfig release` (hoje usa debug — não publica)
- [ ] **Android:** `minSdk` definido explicitamente (≥ 23 recomendado)
- [ ] **iOS:** Bundle ID definitivo + Team de produção
- [ ] **iOS:** preencher textos de uso (NSCamera, NSMicrophone, NSPhotoLibrary) com mensagens em PT-BR claras
- [ ] **Ambos:** ícones do app (1024×1024 + variantes) e splash screen
- [ ] **Ambos:** versionar 1.0.0+1 → bumps automáticos de build

### 📜 Conformidade legal
- [ ] **Política de Privacidade** publicada (URL pública obrigatória nas lojas)
- [ ] **Termos de Uso** publicados
- [ ] **LGPD:** banner de consentimento + opção "excluir minha conta" (Apple exige desde 2022)
- [ ] **Diretrizes de comunidade** (regras contra nudez, spam, etc.) acessíveis

### 🛡️ Moderação mínima
- [ ] **Bloquear usuário** (já existe Privacidade no Settings — falta a ação completa)
- [ ] **Denunciar post / live / usuário** (botão + endpoint backend)
- [ ] **Filtro automático de conteúdo NSFW** mínimo (mesmo que só palavras-chave)
- [ ] **Auto-mute / shadow-ban** para contas reportadas

---

## 🟡 FASE 3 — IMPORTANTES (P1, recomendado antes do lançamento)

### Onboarding
- [ ] Tela de boas-vindas pós-cadastro (3 slides explicando o app)
- [ ] **Sugestão de perfis para seguir** (não pode abrir o app vazio)
- [ ] Permissões pedidas no momento certo (notificações no 1º login, câmera só ao gravar)

### Push notifications
- [ ] Integrar **Firebase Cloud Messaging** (FCM) — falta no pubspec
- [ ] Token registrado no backend
- [ ] Notificações de: novo follower, novo comentário, live de quem você segue, mensagem nova
- [ ] Tela de configurações granulares (já tem Settings, falta toggles)

### Criação de conteúdo
- [ ] **Criar post** (texto + imagem) — endpoint existe; tela falta?
- [ ] **Criar story** — endpoint existe; falta UI de captura
- [ ] **Upload de vídeo curto** (estilo TikTok) — versão "lite": só upload sem editor
- [ ] Cropper de imagem (avatar/banner já têm picker, falta crop)

### Busca
- [ ] **Search global** (usuários + lives + posts) — alimenta For You
- [ ] Histórico de buscas
- [ ] Hashtags clicáveis nos posts

### Perfil
- [ ] **Bloqueados / Silenciados** (lista + ação reverter)
- [ ] **Histórico Wallet** detalhado (extrato com filtros)
- [ ] **Verificar selo** (`is_verified`) — fluxo de solicitação
- [ ] **Compartilhar perfil** (deeplink + share_plus)

### Performance e estabilidade
- [ ] **Crashlytics** (Firebase) integrado
- [ ] **Analytics** (Firebase / PostHog / Mixpanel) — eventos chave
- [ ] **Sentry** ou similar para erros Dart
- [ ] **Cache de imagens** ajustado (já tem cached_network_image, validar TTL)
- [ ] **Loading skeletons** em vez de spinners genéricos

---

## 🟢 FASE 4 — NICE-TO-HAVE (P2, pode ir em v1.1)

- [ ] Dark/Light mode completo (hoje só dark)
- [ ] Internacionalização (i18n EN/ES) — só PT no MVP é OK
- [ ] Modo offline mínimo (cache do feed)
- [ ] Editor de stories (filtros, stickers, texto)
- [ ] Gravação de vídeo in-app
- [ ] Biometria para login
- [ ] AppClip (iOS) / Instant App (Android)
- [ ] Suporte a tablets / iPad (layout adaptativo)
- [ ] Acessibilidade (semantic labels, contraste WCAG)

---

## �� FASE 5 — PUBLICAÇÃO (P0 imediato antes da release)

### Google Play Console
- [ ] Conta Developer ($25 único)
- [ ] Listagem da loja (descrição, screenshots 6,5"/Tablet, ícone, banner)
- [ ] Classificação etária (questionário IARC)
- [ ] Política de Privacidade URL
- [ ] Data Safety form preenchido
- [ ] Build assinado AAB enviado (Internal Testing primeiro)
- [ ] Closed/Open testing com 12+ usuários por 14 dias

### App Store Connect
- [ ] Conta Apple Developer ($99/ano)
- [ ] App ID + Provisioning Profiles
- [ ] Screenshots 6,7" iPhone + iPad
- [ ] App Privacy form (declarar rastreadores)
- [ ] **Sign in with Apple** funcional (obrigatório se tem outro login social)
- [ ] **TestFlight** com beta testers
- [ ] Review notes explicando funcionalidades sociais

### Backend / Infra
- [ ] Endpoints em produção com rate limiting
- [ ] CORS / domínios autorizados
- [ ] Backup de banco automático
- [ ] Monitoramento (UptimeRobot / Better Uptime)
- [ ] CDN para mídia (já usa DigitalOcean Spaces ✓)
- [ ] WebSocket de live com escalabilidade testada

---

## 🎯 RECOMENDAÇÃO DE ROADMAP (próximas 2-4 semanas)

### Semana 1 — Bloqueadores P0
1. Trocar `applicationId` Android + setup keystore
2. Esqueci a senha + verificação de email
3. Sign in with Apple
4. Aceite Termos + Política
5. Endpoint `/users/{id}/products` (ou esconder aba)

### Semana 2 — Moderação + Push
1. FCM integrado
2. Denunciar / Bloquear funcional
3. Logout visível em Settings
4. Excluir conta (LGPD)

### Semana 3 — Onboarding + Criação
1. Onboarding 3 slides
2. Sugestões de quem seguir
3. Criar post (texto + imagem)
4. Search global básica

### Semana 4 — Polimento + Submission
1. Crashlytics + Analytics
2. Loading skeletons
3. Screenshots da loja
4. Submit Internal Testing (Android) + TestFlight (iOS)

---

## 📊 STATUS GERAL

| Categoria              | Completo | Total | %    |
|------------------------|----------|-------|------|
| Fase 1 — Core          | 26       | 26    | 100% |
| Fase 2 — Bloqueadores  | 0        | 18    | 0%   |
| Fase 3 — Importantes   | 0        | 22    | 0%   |
| Fase 4 — Nice-to-have  | 0        | 9     | 0%   |
| Fase 5 — Publicação    | 1        | 17    | 6%   |
| **TOTAL**              | **27**   | **92**| **29%** |

> **Estimativa para v1 público:** 3-4 semanas focadas em P0 + P1.
> Já dá pra começar **TestFlight interno** essa semana com o que existe — só faltam os bloqueadores legais (termos/privacidade) e build release configurado.
