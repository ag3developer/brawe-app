# 📱 Brawe Connect - Manual de Integração para Apps Nativos

## Guia Técnico para Desenvolvedores iOS/Android

**Versão:** 1.0.0  
**Última atualização:** 8 de Março de 2026  
**Base URL Produção:** `https://connect.brawe.io`  
**Base URL Staging:** `https://staging-connect.brawe.io`

---

## 📋 Índice

1. [Visão Geral](#1-visão-geral)
2. [Autenticação](#2-autenticação)
3. [Fluxo Completo de Live](#3-fluxo-completo-de-live)
4. [Endpoints da API](#4-endpoints-da-api)
5. [Streaming RTMP (Broadcaster)](#5-streaming-rtmp-broadcaster)
6. [Playback HLS (Viewer)](#6-playback-hls-viewer)
7. [Socket.IO - Tempo Real](#7-socketio-tempo-real)
8. [Tratamento de Erros](#8-tratamento-de-erros)
9. [Exemplos de Código](#9-exemplos-de-código)
10. [SDKs Recomendados](#10-sdks-recomendados)
11. [Troubleshooting](#11-troubleshooting)

---

## 1. Visão Geral

### Arquitetura

```
┌─────────────────┐     RTMP      ┌─────────────────┐
│   App Nativo    │──────────────▶│      Mux        │
│  (Broadcaster)  │               │  (Live Server)  │
└─────────────────┘               └────────┬────────┘
                                           │ HLS
┌─────────────────┐     HLS       ┌────────▼────────┐
│   App Nativo    │◀──────────────│   Mux CDN       │
│    (Viewer)     │               │ stream.mux.com  │
└─────────────────┘               └─────────────────┘
        │
        │ Socket.IO
        ▼
┌─────────────────┐
│ Brawe Connect   │
│   Realtime      │
│  (port 8002)    │
└─────────────────┘
```

### Componentes

| Componente | URL | Função |
|------------|-----|--------|
| **API REST** | `https://connect.brawe.io/api/v1` | Gerenciamento de salas e streams |
| **Swagger Docs** | `https://connect.brawe.io/docs` | Documentação interativa da API |
| **Socket.IO** | `https://connect.brawe.io` (path: `/socket.io/`) | Chat, presença, eventos em tempo real |
| **Mux RTMP** | `rtmp://global-live.mux.com:5222/app` | Envio de stream (broadcaster) |
| **Mux HLS** | `https://stream.mux.com/{playback_id}.m3u8` | Playback (viewers) |

---

## 2. Autenticação

### JWT Token

Todas as requisições autenticadas devem incluir o header:

```
Authorization: Bearer <jwt_token>
```

O token JWT é obtido através do sistema de autenticação principal do Brawe (`https://brawe.io`).

### Exemplo de Header

```http
GET /api/v1/live/rooms HTTP/1.1
Host: connect.brawe.io
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

### Estrutura do JWT (Payload)

```json
{
  "sub": "user_id",
  "email": "user@example.com",
  "name": "Nome do Usuário",
  "avatar_url": "https://...",
  "exp": 1709913600
}
```

---

## 3. Fluxo Completo de Live

### 3.1 Fluxo do Broadcaster (Host)

```
1. Criar Sala (POST /api/v1/live/rooms)
   ↓
2. Receber credenciais RTMP (rtmp_url + stream_key)
   ↓
3. Configurar encoder com credenciais
   ↓
4. Iniciar transmissão RTMP
   ↓
5. Aguardar status "live" (webhook ou polling)
   ↓
6. Durante a live: gerenciar chat via Socket.IO
   ↓
7. Encerrar live (POST /api/v1/live/rooms/{id}/end)
```

### 3.2 Fluxo do Viewer (Espectador)

```
1. Descobrir lives ativas (GET /api/v1/live/rooms?status=live)
   ↓
2. Entrar na sala (GET /api/v1/live/rooms/{slug})
   ↓
3. Obter playback_url (HLS)
   ↓
4. Iniciar player HLS nativo
   ↓
5. Conectar Socket.IO para chat
   ↓
6. Interagir: enviar mensagens, presentes
   ↓
7. Sair da sala (Socket.IO disconnect)
```

---

## 4. Endpoints da API

### 4.1 Listar Salas Ativas

```http
GET /api/v1/live/rooms?status=live&page=1&per_page=20
```

**Response:**
```json
{
  "items": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "slug": "minha-live-001",
      "title": "Live de Produtos",
      "description": "Apresentando novos produtos",
      "status": "live",
      "host": {
        "id": "user-123",
        "name": "João Silva",
        "avatar_url": "https://..."
      },
      "thumbnail_url": "https://image.mux.com/{playback_id}/thumbnail.jpg",
      "playback_url": "https://stream.mux.com/{playback_id}.m3u8",
      "viewer_count": 150,
      "started_at": "2026-03-08T15:30:00Z"
    }
  ],
  "total": 45,
  "page": 1,
  "pages": 3
}
```

### 4.2 Criar Nova Sala (Broadcaster)

```http
POST /api/v1/live/rooms
Content-Type: application/json
Authorization: Bearer <token>

{
  "title": "Minha Live de Vendas",
  "description": "Produtos exclusivos com desconto",
  "thumbnail_url": "https://...",
  "store_id": "optional-store-uuid",
  "is_private": false,
  "allow_gifts": true,
  "allow_products": true
}
```

**Response (201 Created):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "slug": "minha-live-de-vendas-abc123",
  "title": "Minha Live de Vendas",
  "status": "waiting",
  "stream_config": {
    "rtmp_url": "rtmp://global-live.mux.com:5222/app",
    "stream_key": "sk_live_xxxxxxxxxxxxxxxxxxxxx",
    "playback_id": "DS00Spx1CV902MCtPj5WknGlR102V5HFkDe",
    "playback_url": "https://stream.mux.com/DS00Spx1CV902MCtPj5WknGlR102V5HFkDe.m3u8"
  },
  "host": {
    "id": "user-123",
    "name": "João Silva"
  },
  "created_at": "2026-03-08T15:00:00Z"
}
```

### 4.3 Obter Detalhes da Sala

```http
GET /api/v1/live/rooms/{id_or_slug}
```

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "slug": "minha-live-abc123",
  "title": "Live de Vendas",
  "description": "Produtos exclusivos",
  "status": "live",
  "host": {
    "id": "user-123",
    "name": "João Silva",
    "avatar_url": "https://..."
  },
  "playback_url": "https://stream.mux.com/DS00Spx1CV902MCtPj5WknGlR102V5HFkDe.m3u8",
  "thumbnail_url": "https://image.mux.com/DS00Spx1CV902MCtPj5WknGlR102V5HFkDe/thumbnail.jpg",
  "viewer_count": 150,
  "started_at": "2026-03-08T15:30:00Z",
  "allow_gifts": true,
  "allow_products": true,
  "products": [
    {
      "id": "prod-001",
      "name": "Camiseta Premium",
      "price": 89.90,
      "image_url": "https://..."
    }
  ]
}
```

### 4.4 Verificar Status do Stream

```http
GET /api/v1/live/rooms/{id_or_slug}/stream-status
```

**Response:**
```json
{
  "room_id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "live",
  "is_active": true,
  "viewer_count": 150,
  "started_at": "2026-03-08T15:30:00Z",
  "duration_seconds": 1800,
  "stream_health": {
    "bitrate": 2500000,
    "fps": 30,
    "resolution": "1920x1080"
  }
}
```

### 4.5 Encerrar Live

```http
POST /api/v1/live/rooms/{id}/end
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "message": "Live encerrada com sucesso",
  "recording_url": "https://stream.mux.com/DS00Spx.../high.mp4",
  "duration_seconds": 3600,
  "total_viewers": 500,
  "peak_viewers": 200
}
```

### 4.6 Regenerar Stream Key

```http
POST /api/v1/live/rooms/{id}/regenerate-key
Authorization: Bearer <token>
```

**Response:**
```json
{
  "stream_key": "sk_live_new_key_xxxxxxxxxxxxx"
}
```

---

## 5. Streaming RTMP (Broadcaster)

### 5.1 Configuração do Encoder

| Parâmetro | Valor Recomendado |
|-----------|-------------------|
| **Server URL** | `rtmp://global-live.mux.com:5222/app` |
| **Stream Key** | Obtido via API (campo `stream_key`) |
| **Video Codec** | H.264 (Main ou High Profile) |
| **Audio Codec** | AAC |
| **Bitrate (video)** | 2000-4500 kbps |
| **Bitrate (audio)** | 128-192 kbps |
| **Resolução** | 1920x1080 ou 1280x720 |
| **Frame Rate** | 30 fps |
| **Keyframe Interval** | 2 segundos |

### 5.2 URL Completa de Streaming

```
rtmp://global-live.mux.com:5222/app/{stream_key}
```

**Exemplo:**
```
rtmp://global-live.mux.com:5222/app/sk_live_abc123xyz789
```

### 5.3 iOS - Código de Exemplo (LFLiveKit)

```swift
import LFLiveKit

class LiveStreamViewController: UIViewController {
    
    private var session: LFLiveSession?
    
    func setupLiveSession(rtmpUrl: String, streamKey: String) {
        // Configuração de áudio
        let audioConfiguration = LFLiveAudioConfiguration.default()
        audioConfiguration.audioBitrate = .audioBitRate128Kbps
        audioConfiguration.audioSampleRate = .audioSampleRate44100Hz
        
        // Configuração de vídeo
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: .high3)
        videoConfiguration.videoSize = CGSize(width: 1280, height: 720)
        videoConfiguration.videoFrameRate = 30
        videoConfiguration.videoBitRate = 2500 * 1024
        videoConfiguration.videoMaxKeyframeInterval = 60
        
        // Criar sessão
        session = LFLiveSession(
            audioConfiguration: audioConfiguration,
            videoConfiguration: videoConfiguration
        )
        session?.delegate = self
        session?.preView = previewView
        
        // Iniciar preview
        session?.running = true
    }
    
    func startStreaming(rtmpUrl: String, streamKey: String) {
        let stream = LFLiveStreamInfo()
        stream.url = "\(rtmpUrl)/\(streamKey)"
        session?.startLive(stream)
    }
    
    func stopStreaming() {
        session?.stopLive()
    }
}

extension LiveStreamViewController: LFLiveSessionDelegate {
    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState) {
        switch state {
        case .ready:
            print("📹 Pronto para transmitir")
        case .pending:
            print("🔄 Conectando...")
        case .start:
            print("🔴 LIVE! Transmissão iniciada")
            // Chamar API para atualizar status
        case .stop:
            print("⏹ Transmissão parada")
        case .error:
            print("❌ Erro na transmissão")
        case .refresh:
            print("🔄 Reconectando...")
        @unknown default:
            break
        }
    }
    
    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode) {
        print("❌ Erro de socket: \(errorCode)")
    }
}
```

### 5.4 Android - Código de Exemplo (rtmp-rtsp-stream-client)

```kotlin
import com.pedro.rtplibrary.rtmp.RtmpCamera2

class LiveStreamActivity : AppCompatActivity(), ConnectCheckerRtmp {
    
    private lateinit var rtmpCamera: RtmpCamera2
    private lateinit var surfaceView: SurfaceView
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        surfaceView = findViewById(R.id.surfaceView)
        rtmpCamera = RtmpCamera2(surfaceView, this)
    }
    
    fun startStreaming(rtmpUrl: String, streamKey: String) {
        // Configurar encoder
        if (rtmpCamera.prepareAudio(128 * 1024, 44100, true) &&
            rtmpCamera.prepareVideo(1280, 720, 30, 2500 * 1024, 2, 0)) {
            
            // Iniciar streaming
            rtmpCamera.startStream("$rtmpUrl/$streamKey")
        }
    }
    
    fun stopStreaming() {
        rtmpCamera.stopStream()
    }
    
    // ConnectCheckerRtmp callbacks
    override fun onConnectionStartedRtmp(rtmpUrl: String) {
        Log.d("RTMP", "🔄 Conectando: $rtmpUrl")
    }
    
    override fun onConnectionSuccessRtmp() {
        Log.d("RTMP", "🔴 LIVE! Conectado com sucesso")
        // Chamar API para atualizar status
    }
    
    override fun onConnectionFailedRtmp(reason: String) {
        Log.e("RTMP", "❌ Falha: $reason")
        rtmpCamera.stopStream()
    }
    
    override fun onDisconnectRtmp() {
        Log.d("RTMP", "⏹ Desconectado")
    }
    
    override fun onAuthErrorRtmp() {
        Log.e("RTMP", "🔐 Erro de autenticação")
    }
    
    override fun onAuthSuccessRtmp() {
        Log.d("RTMP", "✅ Autenticado")
    }
    
    override fun onNewBitrateRtmp(bitrate: Long) {
        // Adaptive bitrate
    }
}
```

---

## 6. Playback HLS (Viewer)

### 6.1 URL de Playback

```
https://stream.mux.com/{playback_id}.m3u8
```

### 6.2 Thumbnail/Preview

```
https://image.mux.com/{playback_id}/thumbnail.jpg
https://image.mux.com/{playback_id}/thumbnail.jpg?width=640&height=360
https://image.mux.com/{playback_id}/thumbnail.jpg?time=10
```

### 6.3 Animated GIF Preview

```
https://image.mux.com/{playback_id}/animated.gif
https://image.mux.com/{playback_id}/animated.gif?width=320&fps=15
```

### 6.4 iOS - AVPlayer

```swift
import AVKit

class LiveViewerViewController: UIViewController {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    func playLiveStream(playbackUrl: String) {
        guard let url = URL(string: playbackUrl) else { return }
        
        // Criar player
        player = AVPlayer(url: url)
        
        // Criar layer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = view.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer!)
        
        // Configurar para live
        player?.automaticallyWaitsToMinimizeStalling = true
        
        // Iniciar playback
        player?.play()
        
        // Observar status
        player?.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, 
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            switch player?.status {
            case .readyToPlay:
                print("▶️ Pronto para reproduzir")
            case .failed:
                print("❌ Erro: \(player?.error?.localizedDescription ?? "")")
            default:
                break
            }
        }
    }
    
    func seekToLive() {
        // Ir para o ponto mais recente (live edge)
        if let duration = player?.currentItem?.duration,
           duration.isIndefinite {
            player?.seek(to: .positiveInfinity)
        }
    }
}
```

### 6.5 Android - ExoPlayer

```kotlin
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.ui.PlayerView

class LiveViewerActivity : AppCompatActivity() {
    
    private lateinit var player: ExoPlayer
    private lateinit var playerView: PlayerView
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        playerView = findViewById(R.id.playerView)
        
        // Criar player
        player = ExoPlayer.Builder(this).build()
        playerView.player = player
    }
    
    fun playLiveStream(playbackUrl: String) {
        // Criar media item
        val mediaItem = MediaItem.Builder()
            .setUri(playbackUrl)
            .setLiveConfiguration(
                MediaItem.LiveConfiguration.Builder()
                    .setMaxPlaybackSpeed(1.02f)
                    .build()
            )
            .build()
        
        // Configurar e iniciar
        player.setMediaItem(mediaItem)
        player.prepare()
        player.playWhenReady = true
        
        // Listener
        player.addListener(object : Player.Listener {
            override fun onPlaybackStateChanged(state: Int) {
                when (state) {
                    Player.STATE_READY -> Log.d("Player", "▶️ Reproduzindo")
                    Player.STATE_BUFFERING -> Log.d("Player", "⏳ Buffering...")
                    Player.STATE_ENDED -> Log.d("Player", "⏹ Finalizado")
                    Player.STATE_IDLE -> Log.d("Player", "💤 Idle")
                }
            }
            
            override fun onPlayerError(error: PlaybackException) {
                Log.e("Player", "❌ Erro: ${error.message}")
            }
        })
    }
    
    fun seekToLive() {
        // Ir para o ponto mais recente
        player.seekToDefaultPosition()
    }
    
    override fun onDestroy() {
        super.onDestroy()
        player.release()
    }
}
```

---

## 7. Socket.IO - Tempo Real

### 7.1 Conexão

```
URL: https://connect.brawe.io
Path: /socket.io/
Transports: ['websocket']
```

### 7.2 Autenticação na Conexão

```javascript
// JavaScript/TypeScript
const socket = io('https://connect.brawe.io', {
  path: '/socket.io/',
  transports: ['websocket'],
  auth: {
    token: 'jwt_token_here'
  }
});
```

```swift
// Swift (SocketIO-Kit)
let manager = SocketManager(socketURL: URL(string: "https://connect.brawe.io")!, config: [
    .log(true),
    .compress,
    .path("/socket.io/"),
    .connectParams(["token": jwtToken])
])
let socket = manager.defaultSocket
```

```kotlin
// Kotlin (socket.io-client-java)
val options = IO.Options().apply {
    transports = arrayOf("websocket")
    path = "/socket.io/"
    auth = mapOf("token" to jwtToken)
}
val socket = IO.socket("https://connect.brawe.io", options)
```

### 7.3 Eventos - Cliente → Servidor

| Evento | Payload | Descrição |
|--------|---------|-----------|
| `join_room` | `{ room_id: string }` | Entrar numa sala |
| `leave_room` | `{ room_id: string }` | Sair da sala |
| `chat_message` | `{ room_id: string, message: string }` | Enviar mensagem |
| `send_gift` | `{ room_id: string, gift_id: string, quantity: number }` | Enviar presente |
| `react` | `{ room_id: string, emoji: string }` | Enviar reação |

### 7.4 Eventos - Servidor → Cliente

| Evento | Payload | Descrição |
|--------|---------|-----------|
| `room_joined` | `{ room_id, user_count }` | Confirmação de entrada |
| `user_joined` | `{ user_id, name, avatar_url }` | Novo usuário entrou |
| `user_left` | `{ user_id }` | Usuário saiu |
| `new_message` | `{ id, user_id, name, avatar_url, message, timestamp }` | Nova mensagem de chat |
| `gift_received` | `{ from_user, gift_id, gift_name, value, animation_url }` | Presente recebido |
| `reaction` | `{ user_id, emoji }` | Reação recebida |
| `viewer_count` | `{ count }` | Atualização de viewers |
| `stream_started` | `{ room_id }` | Live começou |
| `stream_ended` | `{ room_id, duration, recording_url }` | Live terminou |
| `product_highlight` | `{ product_id, name, price, image_url }` | Produto destacado |

### 7.5 iOS - Exemplo Completo

```swift
import SocketIO

class LiveChatManager {
    
    private var manager: SocketManager!
    private var socket: SocketIOClient!
    
    weak var delegate: LiveChatDelegate?
    
    func connect(token: String) {
        manager = SocketManager(
            socketURL: URL(string: "https://connect.brawe.io")!,
            config: [
                .log(true),
                .compress,
                .path("/socket.io/"),
                .connectParams(["token": token]),
                .forceWebsockets(true)
            ]
        )
        
        socket = manager.defaultSocket
        setupHandlers()
        socket.connect()
    }
    
    private func setupHandlers() {
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            print("✅ Socket conectado")
            self?.delegate?.didConnect()
        }
        
        socket.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("🔌 Socket desconectado")
            self?.delegate?.didDisconnect()
        }
        
        socket.on("new_message") { [weak self] data, ack in
            guard let messageData = data[0] as? [String: Any] else { return }
            let message = ChatMessage(
                id: messageData["id"] as? String ?? "",
                userId: messageData["user_id"] as? String ?? "",
                userName: messageData["name"] as? String ?? "",
                avatarUrl: messageData["avatar_url"] as? String,
                text: messageData["message"] as? String ?? "",
                timestamp: messageData["timestamp"] as? String ?? ""
            )
            self?.delegate?.didReceiveMessage(message)
        }
        
        socket.on("gift_received") { [weak self] data, ack in
            guard let giftData = data[0] as? [String: Any] else { return }
            let gift = Gift(
                fromUser: giftData["from_user"] as? String ?? "",
                giftId: giftData["gift_id"] as? String ?? "",
                giftName: giftData["gift_name"] as? String ?? "",
                value: giftData["value"] as? Double ?? 0,
                animationUrl: giftData["animation_url"] as? String
            )
            self?.delegate?.didReceiveGift(gift)
        }
        
        socket.on("viewer_count") { [weak self] data, ack in
            guard let countData = data[0] as? [String: Any],
                  let count = countData["count"] as? Int else { return }
            self?.delegate?.didUpdateViewerCount(count)
        }
        
        socket.on("stream_ended") { [weak self] data, ack in
            guard let endData = data[0] as? [String: Any] else { return }
            self?.delegate?.didStreamEnd(
                duration: endData["duration"] as? Int ?? 0,
                recordingUrl: endData["recording_url"] as? String
            )
        }
    }
    
    func joinRoom(_ roomId: String) {
        socket.emit("join_room", ["room_id": roomId])
    }
    
    func leaveRoom(_ roomId: String) {
        socket.emit("leave_room", ["room_id": roomId])
    }
    
    func sendMessage(_ message: String, roomId: String) {
        socket.emit("chat_message", [
            "room_id": roomId,
            "message": message
        ])
    }
    
    func sendGift(giftId: String, quantity: Int, roomId: String) {
        socket.emit("send_gift", [
            "room_id": roomId,
            "gift_id": giftId,
            "quantity": quantity
        ])
    }
    
    func sendReaction(emoji: String, roomId: String) {
        socket.emit("react", [
            "room_id": roomId,
            "emoji": emoji
        ])
    }
    
    func disconnect() {
        socket.disconnect()
    }
}

// MARK: - Delegate Protocol

protocol LiveChatDelegate: AnyObject {
    func didConnect()
    func didDisconnect()
    func didReceiveMessage(_ message: ChatMessage)
    func didReceiveGift(_ gift: Gift)
    func didUpdateViewerCount(_ count: Int)
    func didStreamEnd(duration: Int, recordingUrl: String?)
}
```

### 7.6 Android - Exemplo Completo

```kotlin
import io.socket.client.IO
import io.socket.client.Socket
import org.json.JSONObject

class LiveChatManager(private val listener: LiveChatListener) {
    
    private lateinit var socket: Socket
    
    fun connect(token: String) {
        val options = IO.Options().apply {
            transports = arrayOf("websocket")
            path = "/socket.io/"
            auth = mapOf("token" to token)
        }
        
        socket = IO.socket("https://connect.brawe.io", options)
        setupHandlers()
        socket.connect()
    }
    
    private fun setupHandlers() {
        socket.on(Socket.EVENT_CONNECT) {
            Log.d("Socket", "✅ Conectado")
            listener.onConnect()
        }
        
        socket.on(Socket.EVENT_DISCONNECT) {
            Log.d("Socket", "🔌 Desconectado")
            listener.onDisconnect()
        }
        
        socket.on("new_message") { args ->
            val data = args[0] as JSONObject
            val message = ChatMessage(
                id = data.getString("id"),
                userId = data.getString("user_id"),
                userName = data.getString("name"),
                avatarUrl = data.optString("avatar_url"),
                text = data.getString("message"),
                timestamp = data.getString("timestamp")
            )
            listener.onMessage(message)
        }
        
        socket.on("gift_received") { args ->
            val data = args[0] as JSONObject
            val gift = Gift(
                fromUser = data.getString("from_user"),
                giftId = data.getString("gift_id"),
                giftName = data.getString("gift_name"),
                value = data.getDouble("value"),
                animationUrl = data.optString("animation_url")
            )
            listener.onGift(gift)
        }
        
        socket.on("viewer_count") { args ->
            val data = args[0] as JSONObject
            listener.onViewerCount(data.getInt("count"))
        }
        
        socket.on("stream_ended") { args ->
            val data = args[0] as JSONObject
            listener.onStreamEnd(
                duration = data.getInt("duration"),
                recordingUrl = data.optString("recording_url")
            )
        }
    }
    
    fun joinRoom(roomId: String) {
        socket.emit("join_room", JSONObject().put("room_id", roomId))
    }
    
    fun leaveRoom(roomId: String) {
        socket.emit("leave_room", JSONObject().put("room_id", roomId))
    }
    
    fun sendMessage(message: String, roomId: String) {
        socket.emit("chat_message", JSONObject().apply {
            put("room_id", roomId)
            put("message", message)
        })
    }
    
    fun sendGift(giftId: String, quantity: Int, roomId: String) {
        socket.emit("send_gift", JSONObject().apply {
            put("room_id", roomId)
            put("gift_id", giftId)
            put("quantity", quantity)
        })
    }
    
    fun sendReaction(emoji: String, roomId: String) {
        socket.emit("react", JSONObject().apply {
            put("room_id", roomId)
            put("emoji", emoji)
        })
    }
    
    fun disconnect() {
        socket.disconnect()
    }
}

// Listener Interface
interface LiveChatListener {
    fun onConnect()
    fun onDisconnect()
    fun onMessage(message: ChatMessage)
    fun onGift(gift: Gift)
    fun onViewerCount(count: Int)
    fun onStreamEnd(duration: Int, recordingUrl: String?)
}
```

---

## 8. Tratamento de Erros

### 8.1 Códigos HTTP

| Código | Significado | Ação Recomendada |
|--------|-------------|------------------|
| `200` | Sucesso | - |
| `201` | Criado | - |
| `400` | Request inválido | Verificar payload |
| `401` | Não autorizado | Renovar token JWT |
| `403` | Proibido | Verificar permissões |
| `404` | Não encontrado | Sala/recurso não existe |
| `409` | Conflito | Recurso já existe |
| `422` | Validação falhou | Verificar campos |
| `429` | Rate limit | Aguardar e retry |
| `500` | Erro interno | Retry com backoff |

### 8.2 Estrutura de Erro

```json
{
  "detail": "Descrição do erro",
  "error_code": "ROOM_NOT_FOUND",
  "timestamp": "2026-03-08T15:30:00Z"
}
```

### 8.3 Erros Comuns de Streaming

| Erro | Causa | Solução |
|------|-------|---------|
| `Stream key invalid` | Key expirada ou incorreta | Regenerar via API |
| `Connection refused` | Servidor RTMP indisponível | Verificar URL |
| `Encoder disconnected` | Rede instável | Reconectar com backoff |
| `Bitrate too high` | Rede não suporta | Reduzir qualidade |

---

## 9. Exemplos de Código

### 9.1 Fluxo Completo - Broadcaster iOS

```swift
class BroadcastManager {
    
    private let apiService = BraweAPIService()
    private let streamManager = LiveStreamManager()
    private let chatManager = LiveChatManager()
    
    var currentRoom: LiveRoom?
    
    func startBroadcast(title: String, description: String) async throws -> LiveRoom {
        // 1. Criar sala via API
        let room = try await apiService.createRoom(
            title: title,
            description: description
        )
        currentRoom = room
        
        // 2. Configurar streaming
        streamManager.configure(
            rtmpUrl: room.streamConfig.rtmpUrl,
            streamKey: room.streamConfig.streamKey
        )
        
        // 3. Conectar chat
        chatManager.connect(token: apiService.token)
        chatManager.joinRoom(room.id)
        
        // 4. Iniciar preview
        streamManager.startPreview()
        
        return room
    }
    
    func goLive() {
        streamManager.startStreaming()
    }
    
    func endBroadcast() async throws {
        guard let room = currentRoom else { return }
        
        // 1. Parar streaming
        streamManager.stopStreaming()
        
        // 2. Sair do chat
        chatManager.leaveRoom(room.id)
        chatManager.disconnect()
        
        // 3. Encerrar sala via API
        try await apiService.endRoom(roomId: room.id)
        
        currentRoom = nil
    }
}
```

### 9.2 Fluxo Completo - Viewer Android

```kotlin
class ViewerManager(
    private val apiService: BraweAPIService,
    private val playerView: PlayerView,
    private val context: Context
) : LiveChatListener {
    
    private var player: ExoPlayer? = null
    private var chatManager: LiveChatManager? = null
    private var currentRoom: LiveRoom? = null
    
    suspend fun joinLive(roomId: String): LiveRoom {
        // 1. Obter detalhes da sala
        val room = apiService.getRoom(roomId)
        currentRoom = room
        
        // 2. Iniciar player
        setupPlayer(room.playbackUrl)
        
        // 3. Conectar chat
        chatManager = LiveChatManager(this).apply {
            connect(apiService.token)
            joinRoom(room.id)
        }
        
        return room
    }
    
    private fun setupPlayer(playbackUrl: String) {
        player = ExoPlayer.Builder(context).build().apply {
            playerView.player = this
            
            val mediaItem = MediaItem.Builder()
                .setUri(playbackUrl)
                .setLiveConfiguration(
                    MediaItem.LiveConfiguration.Builder()
                        .setMaxPlaybackSpeed(1.02f)
                        .build()
                )
                .build()
            
            setMediaItem(mediaItem)
            prepare()
            playWhenReady = true
        }
    }
    
    fun leaveLive() {
        currentRoom?.let { room ->
            chatManager?.leaveRoom(room.id)
        }
        chatManager?.disconnect()
        player?.release()
        player = null
        currentRoom = null
    }
    
    // LiveChatListener
    override fun onMessage(message: ChatMessage) {
        // Atualizar UI com nova mensagem
    }
    
    override fun onGift(gift: Gift) {
        // Mostrar animação de presente
    }
    
    override fun onViewerCount(count: Int) {
        // Atualizar contador
    }
    
    override fun onStreamEnd(duration: Int, recordingUrl: String?) {
        // Mostrar tela de fim da live
        leaveLive()
    }
}
```

---

## 10. SDKs Recomendados

### iOS

| Funcionalidade | SDK | Instalação |
|----------------|-----|------------|
| **Streaming RTMP** | LFLiveKit | `pod 'LFLiveKit'` |
| **Streaming RTMP** | HaishinKit | `pod 'HaishinKit'` |
| **Playback HLS** | AVFoundation | Nativo |
| **Socket.IO** | Socket.IO-Client-Swift | `pod 'Socket.IO-Client-Swift'` |
| **HTTP** | Alamofire | `pod 'Alamofire'` |

### Android

| Funcionalidade | SDK | Instalação |
|----------------|-----|------------|
| **Streaming RTMP** | rtmp-rtsp-stream-client | `implementation 'com.github.pedroSG94.rtmp-rtsp-stream-client-java:rtplibrary:2.2.7'` |
| **Playback HLS** | ExoPlayer | `implementation 'com.google.android.exoplayer:exoplayer:2.19.1'` |
| **Socket.IO** | socket.io-client-java | `implementation 'io.socket:socket.io-client:2.1.0'` |
| **HTTP** | Retrofit | `implementation 'com.squareup.retrofit2:retrofit:2.9.0'` |

---

## 11. Troubleshooting

### Stream não inicia

1. ✅ Verificar se `stream_key` está correto
2. ✅ Verificar URL RTMP: `rtmp://global-live.mux.com:5222/app`
3. ✅ Verificar se encoder está configurado com H.264
4. ✅ Verificar conexão de rede
5. ✅ Verificar se sala está no status `waiting` ou `preview`

### Playback não funciona

1. ✅ Verificar se `playback_url` está correta
2. ✅ Verificar se live está no status `live`
3. ✅ Verificar se player suporta HLS
4. ✅ Testar URL no navegador: `https://stream.mux.com/{playback_id}.m3u8`

### Socket.IO não conecta

1. ✅ Verificar se token JWT é válido
2. ✅ Verificar URL: `https://connect.brawe.io` com path `/socket.io/`
3. ✅ Verificar se está usando transport `websocket`
4. ✅ Verificar CORS (deve funcionar com qualquer origem)

### Alta latência

1. ✅ Usar keyframe interval de 2 segundos
2. ✅ Reduzir buffer do player (iOS: `automaticallyWaitsToMinimizeStalling`)
3. ✅ Usar `seekToLive()` para ir ao ponto mais recente
4. ✅ Considerar Mux Low-Latency HLS (extra config)

---

## 📞 Suporte

- **Email:** dev@brawe.io
- **Documentação:** https://docs.brawe.io
- **Status API:** https://status.brawe.io

---

**© 2026 Brawe.io - Todos os direitos reservados**
