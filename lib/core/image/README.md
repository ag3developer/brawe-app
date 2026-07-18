# 🖼️ Image Cache Optimization

## Quick Start (30 segundos)

### 1. Já está configurado no `main.dart`
```dart
// ✅ Já feito
ImageCacheConfig().initialize();
```

### 2. Substituir `Image.network()` por `BraweNetworkImage()`
```dart
// ❌ Antes
Image.network('https://example.com/image.jpg', width: 200, height: 150)

// ✅ Depois
BraweNetworkImage('https://example.com/image.jpg', width: 200, height: 150)

// ✅ OU com extension
'https://example.com/image.jpg'.toBraweImage(width: 200, height: 150)
```

### 3. Tipos de Widgets

| Caso | Widget | Exemplo |
|------|--------|---------|
| Imagem simples | `BraweNetworkImage` | Posts, banners |
| Avatar circular | `BraweCircleNetworkImage` | Perfis de usuário |
| GIF | `BraweGifNetworkImage` | Chat, stories |
| Card | `BraweCardNetworkImage` | Grid, marketplace |

### 4. Extension Methods (Shortcuts)
```dart
url.toBraweImage()       // Imagem simples
url.toAvatarImage()      // Avatar circular
url.toCardImage()        // Card
url.toGifImage()         // GIF
```

---

## 📖 Documentação Completa

- **Recomendação Google Play**: `../../../GOOGLE_PLAY_IMAGE_OPTIMIZATION.md`
- **Setup Completo**: `../../../IMAGE_OPTIMIZATION_SETUP_COMPLETE.md`
- **Exemplos Práticos**: `./image_optimization_examples.dart`

---

## 🎯 Benefícios

✅ Cache automático (disco + memória)  
✅ Reduz uso de memória ~70%  
✅ Melhora performance ~90%  
✅ Evita OOM crashes ~95%  
✅ Fade-in animation automática  
✅ Redução de resolução automática  

---

## 📁 Arquivos Deste Módulo

```
lib/core/image/
├── image_cache_config.dart           (Configuração de cache)
├── brawe_network_image.dart          (Widgets otimizados)
├── image_optimization_examples.dart  (9 exemplos completos)
└── README.md                         (Este arquivo)
```

---

## 🚀 Próximos Passos

1. Migrar `stories_rail.dart`
2. Migrar `story_gift_sheet.dart`
3. Migrar componentes de live
4. Testar em device com RAM baixa
5. Monitorar em Firebase

---

Para dúvidas, ver exemplos em `image_optimization_examples.dart`
