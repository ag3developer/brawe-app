# 📊 Comparativo: Brawe Connect Web vs App Flutter

> Mapeamento de funcionalidades existentes no **frontend web** (`/connect/*`) e seu status no **app Flutter**.
> Última atualização: 12/05/2026

---

## 🗺️ Estrutura de navegação (sidebar do web)

### Menu Principal (Primary nav)
| Item Web | Rota Web | Status App | Rota App | Observação |
|----------|----------|:----------:|----------|------------|
| Para você | `/connect/foryou` | ✅ | `/home` | Feed swipe vertical OK |
| Explorar | `/connect/explore` | ❌ | — | **FALTA** — busca + categorias + grid descoberta |
| Seguindo | `/connect/following` | 🟡 | `/follows/:id?tab=following` | Existe lista, falta **feed só de quem sigo** |
| LIVE | `/connect/lives` | ✅ | `/live` | OK |
| Mensagens | `/connect/messages` | ✅ | `/chat` | OK |
| Atividade | `/connect/notifications` | ✅ | `/notifications` | OK |
| Carregar | `/connect/go-live` | 🟡 | `/live/start` | Só go-live; **falta upload de post/vídeo** |
| Perfil | `/connect/profile` | ✅ | `/profile/:id` | OK + Editar perfil ✨ |

### Menu Secundário ("Mais")
| Item Web | Rota Web | Status App | Observação |
|----------|----------|:----------:|------------|
| Missões | `/connect/quests` | ✅ | OK |
| Battles | `/connect/battles` | 🟡 | Existe live battle view, **falta página de listagem** |
| Shopping | `/connect/shopping` | ❌ | **FALTA** — marketplace integrado |
| Analytics | `/connect/analytics` | ❌ | **FALTA** — dashboard de criador |
| Favoritos | `/connect/favorites` | ❌ | **FALTA** — posts/lives salvos |
| Configurações | `/connect/settings` | 🟡 | Existe, **falta paridade** (ver abaixo) |

### Categorias (top bar)
| Categoria | Status App |
|-----------|:----------:|
| Jogos | ❌ |
| Estilo de vida | ❌ |
| Música | ❌ |
| Esportes | ❌ |
| Educação | ❌ |
| Culinária | ❌ |
| Tecnologia | ❌ |
| Battles (filtro) | ❌ |
| Shopping (filtro) | ❌ |

> **Falta:** filtro de categoria no feed/explorar.

---

## 🔍 Detalhamento por página

### 1. **Explorar** (`/explore` — 715 linhas) ❌ **NÃO EXISTE NO APP**
Funcionalidades web:
- Busca em tempo real (`searchExplore`)
- Trending feed (`getTrending`)
- 30+ categorias com ícones
- Recomendados (`getRecommended`)
- Connect Pass stores (`getConnectPassStores`)
- Grid responsivo

**Impacto:** Sem Explorar, novos usuários não descobrem conteúdo além do For You.

---

### 2. **Profile** (`/profile/[id]` — versão moderna estilo IG/TikTok)
| Feature | Web | App | Falta? |
|---------|:---:|:---:|:------:|
| Banner + avatar | ✅ | ✅ | — |
| Stats (followers/following) | ✅ | ✅ | — |
| Bio com auto-link | ✅ | 🟡 | Parsear URLs |
| Social chips com ícones customizados | ✅ | 🟡 | Paleta de ícones limitada |
| Resolução username → UUID | ✅ | ❌ | App só aceita UUID na rota |
| Modal followers/following inline | ✅ | ✅ | — |
| Lista de posts | ✅ | ✅ | — |
| Lista de lives | ✅ | ✅ | — |
| Editar perfil | ✅ | ✅ | ✨ recém-feito |
| Compartilhar perfil | ✅ | ❌ | Falta share |
| Custom links (até 5) | ✅ | 🟡 | Hoje só 5 fixos (insta/twitter/tiktok/yt/site), web tem links custom com paleta de ícones |

---

### 3. **Settings** (`/settings` — 2014 linhas) 🟡 **PARIDADE PARCIAL**
| Seção | Web | App | Falta? |
|-------|:---:|:---:|:------:|
| Editar Perfil | ✅ | ✅ | — |
| **Senha e Segurança** (alterar senha) | ✅ | ❌ | **FALTA** |
| **Pagamentos** (cartões, Pix, histórico) | ✅ | ❌ | **FALTA** |
| **Dispositivos** (sessões ativas) | ✅ | ❌ | **FALTA** |
| Idioma (PT/EN/ES) | ✅ | 🟡 | Só PT no app |
| **Username** (alterar @) | ✅ | ❌ | **FALTA** |
| Custom links (drag-drop, ícones) | ✅ | ❌ | **FALTA** |
| Ajuda e Suporte | ✅ | ❌ | **FALTA** |
| Conta e Dados (excluir conta) | ✅ | ❌ | **FALTA** (LGPD!) |
| Tema (dark/light) | ✅ | 🟡 | Só dark |
| Notificações granulares | ✅ | ❌ | **FALTA** |
| Privacidade (perfil privado) | ✅ | 🟡 | UI existe, ações faltam |

---

### 4. **For You** (`/foryou` — 1956 linhas) ✅ **PARIDADE BOA**
| Feature | Web | App | Falta? |
|---------|:---:|:---:|:------:|
| Swipe vertical fullscreen | ✅ | ✅ | — |
| Abas Social/Lives | ✅ | ✅ | — |
| Funciona sem login | ✅ | ❌ | App força login |
| HLS player | ✅ | ✅ | (video_player) |
| Reactions picker (não só like) | ✅ | ❌ | **FALTA** — múltiplas reações |
| Floating hearts (double tap) | ✅ | 🟡 | Verificar |
| Comments panel inline | ✅ | ✅ | — |
| Seguir do feed | ✅ | ✅ | — |
| Quest tracking (like/watch/follow) | ✅ | 🟡 | Verificar integração |
| Mystery gift | ✅ | ❌ | **FALTA** |
| Chat ao vivo dentro do feed | ✅ | ✅ | — |

---

### 5. **Messages** (`/messages` — 946 linhas)
| Feature | Web | App | Falta? |
|---------|:---:|:---:|:------:|
| Lista de conversas | ✅ | ✅ | — |
| Detalhe de conversa | ✅ | ✅ | — |
| **Envio de mídia** (foto/vídeo) | ✅ | 🟡 | Verificar |
| **Indicador "digitando"** | ✅ | ❌ | Verificar |
| **Status online** | ✅ | ❌ | Verificar |
| Busca em conversas | ✅ | ❌ | **FALTA** |

---

### 6. **Quests** (`/quests` — 1219 linhas) ✅
| Feature | Web | App | Falta? |
|---------|:---:|:---:|:------:|
| Lista de missões | ✅ | ✅ | — |
| Progresso/recompensa | ✅ | ✅ | — |
| Reivindicar prêmio | ✅ | 🟡 | Verificar fluxo completo |
| Filtros (diárias/semanais) | ✅ | ❓ | Verificar |

---

### 7. **Coins** (`/coins` — 433 linhas) ✅ ≈ Wallet do app
| Feature | Web | App | Falta? |
|---------|:---:|:---:|:------:|
| Saldo de coins | ✅ | ✅ | — |
| Histórico transações | ✅ | ✅ | — |
| **Comprar coins** (top-up) | ✅ | ❌ | **FALTA** — IAP iOS / Google Play Billing |
| **Sacar/converter** | ✅ | ❌ | **FALTA** |
| Recibos/extratos PDF | ✅ | ❌ | **FALTA** |

---

### 8. **Go Live / Carregar** (`/go-live` — 280 linhas)
| Feature | Web | App | Falta? |
|---------|:---:|:---:|:------:|
| Iniciar live | ✅ | ✅ | OK |
| **Upload de post** (texto+imagem) | ✅ | ❌ | **FALTA** |
| **Upload de vídeo curto** (estilo TikTok) | ✅ | ❌ | **FALTA** |
| **Criar story** | ✅ | ❌ | **FALTA** |
| Schedule live | ✅ | ❌ | **FALTA** |
| Live commerce (anexar produtos) | ✅ | 🟡 | Verificar |

---

### 9. **Battles** (`/battles` — 261 linhas) ��
| Feature | Web | App | Falta? |
|---------|:---:|:---:|:------:|
| Lista de battles ativos | ✅ | ❌ | **FALTA página dedicada** |
| Ranking de battles | ✅ | ❌ | **FALTA** |
| Iniciar battle | ✅ | ❌ | **FALTA** |
| Assistir battle (ao vivo) | ✅ | ✅ | View existe |

---

### 10. **Shopping** (`/shopping` — 378 linhas) ❌ **NÃO EXISTE NO APP**
- Marketplace de produtos
- Carrinho
- Categorias
- Connect Pass stores

---

### 11. **Analytics** (`/analytics` — 238 linhas) ❌ **NÃO EXISTE NO APP**
- Dashboard de criador
- Visualizações, engajamento, ganhos
- Gráficos por período

---

### 12. **Favorites** (`/favorites` — 225 linhas) ❌ **NÃO EXISTE NO APP**
- Posts/lives salvos
- Coleções

---

### 13. **Followers/Following** ✅
| Feature | Web | App | Falta? |
|---------|:---:|:---:|:------:|
| Lista de followers | ✅ | ✅ | — |
| Lista de following | ✅ | ✅ | — |
| Busca dentro da lista | ✅ | ❌ | **FALTA** |
| **Feed só de quem sigo** | ✅ | ❌ | **FALTA** (página `/connect/following`) |

---

### 14. **Notifications** ✅
| Feature | Web | App | Falta? |
|---------|:---:|:---:|:------:|
| Lista cronológica | ✅ | ✅ | — |
| Marcar como lida | ✅ | ✅ | — |
| Filtros (likes/follows/comments) | ✅ | ❓ | Verificar |
| **Push real (FCM)** | ✅ | ❌ | **FALTA** |

---

## 🎯 GAPS CRÍTICOS — PRIORIDADE PARA APP

### 🔴 P0 (Bloqueadores reais — usuário sente falta logo)
1. **Criar Post** (texto + imagem) — `/go-live` upload
2. **Criar Story** (captura + envio)
3. **Explorar** — descoberta de conteúdo
4. **Search global** (usuários, posts, lives)
5. **Comprar coins** (in-app purchase)
6. **Alterar senha** (Settings → Senha e Segurança)
7. **Excluir conta** (Settings → Conta e Dados — LGPD/Apple)
8. **Sign in with Apple** (App Store requirement)
9. **Push notifications** (FCM)
10. **Suporte a username na rota** `/profile/josecarlosmartins`

### �� P1 (Importante para paridade)
11. **Custom links no perfil** (mais que só 5 fixos)
12. **Reactions múltiplas** no feed (não só like)
13. **Feed "Seguindo"** dedicado
14. **Compartilhar perfil/post**
15. **Schedule live**
16. **Configurações de notificações granulares**
17. **Idioma EN/ES**
18. **Dispositivos (sessões ativas)**
19. **Indicador "digitando" + online status** no chat

### 🟢 P2 (Nice-to-have)
20. **Shopping/Marketplace** integrado
21. **Analytics dashboard**
22. **Favoritos/Salvos**
23. **Battles dedicado** (lista + ranking)
24. **Mystery gift**
25. **Schedule live**
26. **Recibos/extratos PDF**

---

## 📊 SCORE DE PARIDADE

| Área | Paridade | Observação |
|------|---------:|------------|
| Auth | 70% | Falta Apple/Google + recuperar senha |
| Feed (For You) | 80% | Falta reactions + sem-login |
| Lives | 90% | Quase paridade |
| Messages | 75% | Falta typing/online/busca |
| Profile | 70% | Falta username route + custom links + share |
| **Settings** | **30%** | **Maior gap** — falta senha/pagamentos/dispositivos/excluir conta |
| Notifications | 60% | Falta push real (FCM) |
| Quests | 85% | Boa |
| Wallet/Coins | 50% | Falta comprar/sacar |
| **Criação de conteúdo** | **20%** | **Maior gap** — só go-live, falta post/story/vídeo |
| Explorar | 0% | **Não existe no app** |
| Shopping | 0% | **Não existe no app** |
| Analytics | 0% | **Não existe no app** |
| Favorites | 0% | **Não existe no app** |
| Battles | 30% | Só assistir |
| Followers/Following | 75% | Falta busca + feed seguindo |

> **Paridade global: ~50%**
> **Para "MVP equivalente ao web" precisaria ~70% paridade.**

---

## 🚀 ROADMAP AJUSTADO (com base no comparativo)

### Sprint 1 — Criação + Descoberta (essencial pro app valer a pena)
1. **Criar Post** (texto + imagem) ✏️
2. **Criar Story** 📸
3. **Explorar** (busca + categorias + recomendados) 🔍
4. **Search global** 🔎
5. **Suporte a username** na rota `/profile/{username}`

### Sprint 2 — Settings completo (paridade web)
6. **Alterar senha** 🔒
7. **Excluir conta** ⚠️ (LGPD)
8. **Sign in with Apple + Google** 🍎
9. **Recuperar senha** ("esqueci")
10. **Custom links** no perfil

### Sprint 3 — Engajamento + Push
11. **FCM push notifications** 🔔
12. **Reactions múltiplas** no feed
13. **Compartilhar perfil/post** (deeplink)
14. **Feed "Seguindo"** dedicado
15. **Indicador online + typing** no chat

### Sprint 4 — Monetização + Polimento
16. **Comprar coins** (IAP iOS + Google Play Billing) 💰
17. **Idioma EN/ES**
18. **Configurações granulares de notificação**
19. **Dispositivos/sessões ativas**

### Sprint 5+ (pós-lançamento)
20. Shopping/Marketplace
21. Analytics dashboard
22. Favoritos/Salvos
23. Battles dedicado
24. Schedule live

---

## ⚡ RECOMENDAÇÃO

Você tem razão: o **web está bem mais completo**. Mas a boa notícia é que **o backend já existe** para 90% dessas features — é "só" plugar no app Flutter.

**Próximo passo sugerido:** atacar **Sprint 1** (Criar Post + Explorar + Search) porque sem isso o app é "view-only" comparado ao web, e usuários vão abandonar pra usar o navegador.

Qual sprint você quer começar?
