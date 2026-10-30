# 🎁 Brawe Connect — Gifts Asset Pack

Catálogo local de ícones de presentes usados na **galeria de seleção** durante as lives.

> **Comportamento:** o widget `GiftsOverlay` tenta carregar primeiro o asset
> local (`assets/images/gifts/<tier>/<slug>.png`) e, se não existir, faz
> fallback para o `icon_url` que vem do backend (CDN soberano `cdn.brawe.io`).
> Assim podemos lançar assets oficiais sem republicar o app, e ao mesmo
> tempo manter visuais consistentes offline.

---

## 📁 Estrutura de pastas

```
assets/images/gifts/
├── free/             ← Tier FREE (1–9 créditos)
│   ├── <slug>.png             (baseline 256×256 px)
│   ├── 2.0x/<slug>.png        (512×512 px)
│   └── 3.0x/<slug>.png        (768×768 px)
├── basic/            ← Tier BASIC (10–99 créditos)
├── premium/          ← Tier PREMIUM (100–999 créditos)
├── luxury/           ← Tier LUXURY (1k–9.9k créditos)
└── legendary/        ← Tier LEGENDARY (10k+ créditos)
```

> Cada tier também tem `2.0x/` e `3.0x/` para Retina/HD (mesma convenção do Flutter).

---

## 📐 Especificações para o designer

### Tamanho do canvas
| Resolução | Tamanho | Onde usar |
|---|---|---|
| **1.0x (baseline)** | **256×256 px** | Para PNGs simples |
| **2.0x** | **512×512 px** | Recomendado entregar |
| **3.0x** | **768×768 px** | Recomendado entregar |
| **Master art** | **512×512 px ou 1024×1024 px** | Arquivo fonte (vamos fazer downscale) |

📝 **Se entregar apenas 1 PNG por gift**, faça em **1024×1024 px** que o script gera as 3 variantes automaticamente.

### Regras visuais
1. **Formato:** PNG com canal alfa (transparência total no fundo)
2. **Padding interno:** ~10% nas bordas (objeto ocupa ~80% do canvas)
3. **Centralização:** objeto centralizado vertical e horizontalmente
4. **Sombras/glow:** podem ultrapassar levemente o "círculo seguro" interno
5. **Cor:** evite branco puro como cor principal (atrapalha em fundos claros). Prefira tons saturados.
6. **Peso:** otimizar com `pngquant` / TinyPNG → cada arquivo final < **80 KB**

### Coerência visual por tier
- **FREE / BASIC:** flat, cores sólidas, sem efeitos elaborados (ex: coração, rosa, estrela)
- **PREMIUM:** semi-realista, com brilho/glow sutil (ex: foguete, coroa, diamante)
- **LUXURY:** detalhes metálicos, partículas, raios (ex: carro esportivo, iate)
- **LEGENDARY:** "épico" — aura, fogo, raios de luz, gradient holográfico (ex: galáxia, mansão)

---

## 🎁 Catálogo de slugs (alinhar nomes com backend)

> Os slugs **devem bater exatamente** com o campo `slug` na tabela `connect_gifts`.

### FREE
| Slug | Nome | Sugestão visual |
|---|---|---|
| `heart` | Coração | ❤️ vermelho |
| `like` | Like | 👍 azul |
| `rose` | Rosa | 🌹 vermelha |

### BASIC
| Slug | Nome | Sugestão visual |
|---|---|---|
| `star` | Estrela | ⭐ amarela com glow |
| `kiss` | Beijo | 💋 |
| `applause` | Aplauso | 👏 |

### PREMIUM
| Slug | Nome | Sugestão visual |
|---|---|---|
| `rocket` | Foguete | 🚀 com chama |
| `crown` | Coroa | 👑 dourada |
| `diamond` | Diamante | 💎 com facetas |

### LUXURY
| Slug | Nome | Sugestão visual |
|---|---|---|
| `sports-car` | Carro Esportivo | 🏎️ vermelho/preto |
| `yacht` | Iate | ⛵ branco/azul |

### LEGENDARY
| Slug | Nome | Sugestão visual |
|---|---|---|
| `galaxy` | Galáxia | 🌌 espiral holográfica |
| `mansion` | Mansão | 🏰 dourada com luzes |

---

## 🔧 Processamento

Use o script:

```bash
python3 /Users/josecarlosmartins/Documents/Brawe/scripts/process_gift_assets.py
```

Ele lê PNGs de `~/Downloads/gifts/` (organizados por tier) e:
1. Remove fundo branco (se houver) e mantém transparência
2. Faz crop do conteúdo + padding fixo
3. Gera 3 variantes (96 / 192 / 288 px)
4. Salva em `assets/images/gifts/<tier>/<slug>.png`, `2.0x/`, `3.0x/`

Estrutura esperada em `~/Downloads/gifts/`:
```
~/Downloads/gifts/
├── free/heart.png
├── free/like.png
├── basic/star.png
├── premium/rocket.png
└── ...
```

---

## 📤 Sincronização com CDN

Depois de adicionar localmente, **também subir para o CDN soberano**:

- **Domínio público (usado pelo app):** `https://cdn.brawe.io`
- **Arquitetura:** Cloudflare (proxy/cache) → origin **DigitalOcean Spaces** hoje
  → futuro **Cloudflare R2** (a migração trocará só o origin no Cloudflare,
  sem mexer em código ou banco — o domínio `cdn.brawe.io` continua igual).
- **Path do bucket:** `connect/gifts/<slug>.png` (apenas a versão @3x — 288×288 ou maior)
- **URL final no banco:** `https://cdn.brawe.io/connect/gifts/<slug>.png`
- Atualizar `icon_url` no seed: `brawe-connect/backend/scripts/seed_gifts.py`

### Animações (vídeos / Lottie / SVGA)

Esses **não vão no app** (peso). Ficam só no CDN:

```
https://cdn.brawe.io/connect/gifts/animations/
├── lottie/<slug>.json     (vetorial leve — free/basic)
├── svga/<slug>.svga       (animação 2D — premium)
└── video/<slug>.mp4       (épico fullscreen — luxury/legendary)
```

Campos no banco: `animation_url` + `animation_type` (`lottie` | `svga` | `video`).

