# 📚 Brawe Connect - Documentação para Desenvolvedores

## Estrutura

```
docs/
├── NATIVE_APP_INTEGRATION.md   # Manual completo de integração
├── QUICK_REFERENCE.md          # Referência rápida (cheat sheet)
├── models/
│   ├── BraweConnectModels.swift    # Modelos de dados para iOS
│   └── BraweConnectModels.kt       # Modelos de dados para Android
└── examples/
    ├── BraweConnectAPI.swift       # API Service completo para iOS
    └── BraweConnectAPI.kt          # API Service completo para Android
```

## Início Rápido

### 1. Leia o Manual de Integração
O arquivo `NATIVE_APP_INTEGRATION.md` contém:
- Arquitetura do sistema
- Fluxo completo de broadcaster e viewer
- Todos os endpoints da API
- Configuração de RTMP streaming
- Playback HLS
- Socket.IO para tempo real
- Exemplos de código iOS/Android

### 2. Use os Modelos Prontos
Copie os arquivos de `models/` para seu projeto:
- **iOS**: `BraweConnectModels.swift`
- **Android**: `BraweConnectModels.kt`

### 3. Implemente o API Service
Use os exemplos de `examples/` como base:
- **iOS**: `BraweConnectAPI.swift` (usando async/await)
- **Android**: `BraweConnectAPI.kt` (usando Retrofit + Coroutines)

## URLs de Produção

| Serviço | URL |
|---------|-----|
| API REST | `https://connect.brawe.io/api/v1` |
| Swagger Docs | `https://connect.brawe.io/docs` |
| Health Check | `https://connect.brawe.io/health` |
| Socket.IO | `https://connect.brawe.io` (path: `/socket.io/`) |
| RTMP | `rtmp://global-live.mux.com:5222/app` |
| HLS | `https://stream.mux.com/{playback_id}.m3u8` |

## SDKs Recomendados

### iOS
| Função | Biblioteca |
|--------|------------|
| Streaming RTMP | LFLiveKit, HaishinKit |
| Playback HLS | AVFoundation (nativo) |
| Socket.IO | Socket.IO-Client-Swift |
| HTTP | URLSession (nativo), Alamofire |

### Android
| Função | Biblioteca |
|--------|------------|
| Streaming RTMP | rtmp-rtsp-stream-client-java |
| Playback HLS | ExoPlayer |
| Socket.IO | socket.io-client-java |
| HTTP | Retrofit, OkHttp |

## Suporte

- **Email**: dev@brawe.io
- **Docs Online**: https://docs.brawe.io
- **Status**: https://status.brawe.io

---

**© 2026 Brawe.io**
