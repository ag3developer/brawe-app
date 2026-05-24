# Quests Assets

Coloque os PNGs (fundo **transparente**) nesta pasta seguindo a
**convenção de resolução do Flutter**:

```
assets/images/quests/
├── nome.png        ← @1x (baseline)
├── 2.0x/nome.png   ← @2x
└── 3.0x/nome.png   ← @3x
```

O Flutter escolhe automaticamente a resolução adequada ao device.
Se um PNG não existir, o código faz **fallback para um ícone Material** —
então a tela nunca quebra.

## Lista de assets esperados

### 🏆 Hero / Topo
| Arquivo | @1x | @2x | @3x | Descrição |
|---|---|---|---|---|
| `trophy.png`     | 120×120 | 240×240 | 360×360 | Troféu dourado ao lado do nível |
| `hero_bg.png`    | 800×260 | 1600×520 | 2400×780 | Fundo decorativo (estrelas/partículas) |

### 🤖 Mascote
| Arquivo | @1x | @2x | @3x | Quando aparece |
|---|---|---|---|---|
| `mascot_happy.png`      | 200×200 | 400×400 | 600×600 | Estado normal |
| `mascot_fire.png`       | 200×200 | 400×400 | 600×600 | Streak > 3 dias |
| `mascot_celebrate.png`  | 200×200 | 400×400 | 600×600 | Todas missões completas |
| `empty_state.png`       | 240×240 | 480×480 | 720×720 | Lista vazia |

### 🎯 Ícones de quest (substituem os Material Icons)
| Arquivo | @1x | @2x | @3x | Categoria |
|---|---|---|---|---|
| `icon_like.png`     | 80×80 | 160×160 | 240×240 | Curtidas |
| `icon_comment.png`  | 80×80 | 160×160 | 240×240 | Comentários |
| `icon_follow.png`   | 80×80 | 160×160 | 240×240 | Seguidores |
| `icon_post.png`     | 80×80 | 160×160 | 240×240 | Posts/Stories |
| `icon_share.png`    | 80×80 | 160×160 | 240×240 | Compartilhar |
| `icon_watch.png`    | 80×80 | 160×160 | 240×240 | Assistir |
| `icon_streak.png`   | 80×80 | 160×160 | 240×240 | Streak diário |

### 💰 Recompensas
| Arquivo | @1x | @2x | @3x | Uso |
|---|---|---|---|---|
| `coin_brc.png`      | 48×48 | 96×96 | 144×144 | Moeda BRC |
| `xp_bolt.png`       | 48×48 | 96×96 | 144×144 | Raio de XP |
| `reward_chest.png`  | 160×160 | 320×320 | 480×480 | Baú no "Resgatar tudo" |

## Estilo recomendado
- Flat com leve gradiente + outline branco/glow
- Paleta: roxo neon `#6E4DFF`, ciano `#3BB8FF`, dourado `#FFD93D`, rosa `#FF4D8D`
- Fundo **transparente** (PNG)
- ~10% de padding interno
- Estilo: Duolingo / Brawl Stars / Habitica
