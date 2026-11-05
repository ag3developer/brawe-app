class AppConstants {
  const AppConstants._();

  // API URLs
  // Produção por padrão. Para apontar para backends locais:
  //   flutter run --dart-define=CONNECT_API_URL=http://localhost:8001 \
  //               --dart-define=APP_API_URL=http://localhost:8000
  static const String connectApiBaseUrl = String.fromEnvironment(
    'CONNECT_API_URL',
    defaultValue: 'https://connect.brawe.io',
  );
  static const String appApiBaseUrl = String.fromEnvironment(
    'APP_API_URL',
    defaultValue: 'https://app.brawe.io',
  );

  static const String connectApiV1Url = '$connectApiBaseUrl/api/v1';
  static const String appApiV1Url = '$appApiBaseUrl/api/v1';

  // Public site (deeplinks / share / legal pages) — hosted at brawe.app
  static const String publicBaseUrl = 'https://brawe.app';
  static const String legalBaseUrl = publicBaseUrl;
  static const String termsUrl = '$legalBaseUrl/terms';
  static const String privacyUrl = '$legalBaseUrl/privacy';
  static const String supportUrl = '$legalBaseUrl/support';
  static const String supportEmail = 'support@brawe.app';

  // Public deeplinks (compartilhamento)
  static String profileUrl(String handleOrId) =>
      '$publicBaseUrl/connect/u/$handleOrId';
  static String postUrl(String postId) => '$publicBaseUrl/connect/p/$postId';
  static String liveUrl(String slug) => '$publicBaseUrl/live/$slug';

  // Legal versions (must match backend TERMS_VERSION / PRIVACY_VERSION)
  static const String termsVersion = '2025-01-01';
  static const String privacyVersion = '2025-01-01';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration liveInitiationTimeout = Duration(seconds: 20);

  // Other constants
  static const int feedLimit = 10;
  static const int roomsLimit = 20;
  static const int chatPageLimit = 50;
  static const int conversationsPageLimit = 20;

  // Socket.IO
  static const String socketPath = '/ws/socket.io';
  static const List<String> socketTransports = ['websocket'];

  // Socket Events — Auth
  static const String eventAuthenticate = 'authenticate';
  static const String eventAuthenticated = 'authenticated';

  // Socket Events — Live rooms
  static const String eventJoinRoom = 'join_live';
  static const String eventLeaveRoom = 'leave_live';
  static const String eventSendMessage = 'live_chat_message';
  static const String eventLiveChat = 'live_chat';
  static const String eventViewerCount = 'viewer_count_update';
  static const String eventRequestViewers = 'get_live_viewers';
  static const String eventNewGift = 'gift_received';
  static const String eventLiveReaction = 'live_reaction';
  static const String eventSendReaction = 'live_reaction';
  static const String eventLiveEnded = 'live_ended';
  static const String eventLivePaused = 'live_paused';
  static const String eventLiveResumed = 'live_resumed';
  static const String eventLikeCountUpdate = 'like_count_update';
  static const String eventCommentCountUpdate = 'comment_count_update';

  // Socket Events — Direct Messages (alinhados ao backend)
  // Backend emite/escuta estes nomes em app/services/socket_manager.py
  static const String eventJoinConversation = 'join_conversation';
  static const String eventLeaveConversation = 'leave_conversation';
  static const String eventNewMessage = 'new_message'; // backend -> client
  static const String eventMessageNotification = 'message_notification'; // backend -> client
  static const String eventTyping = 'typing'; // client -> backend
  static const String eventStopTyping = 'stop_typing'; // client -> backend
  static const String eventUserTyping = 'user_typing'; // backend -> client
  static const String eventUserStopTyping = 'user_stop_typing'; // backend -> client
  static const String eventPresenceUpdate = 'presence_update'; // backend -> client
  static const String eventMessageBurned = 'message_burned'; // backend -> client
  static const String eventMessageReaction = 'message_reaction'; // backend -> client

  // Socket Events — Battle
  static const String eventBattleInvite = 'connect:battle:invite';
  static const String eventBattleCountdown = 'connect:battle:countdown';
  static const String eventBattleStarted = 'connect:battle:started';
  static const String eventBattleScoreUpdate = 'connect:battle:score_update';
  static const String eventBattleEnded = 'connect:battle:ended';
  static const String eventBattleCancelled = 'connect:battle:cancelled';
  static const String eventBattleMute = 'connect:battle:mute';
  static const String eventBattleFlash = 'connect:battle:flash';
  static const String eventBattleRtcFallback = 'connect:battle:rtc_fallback';

  // Socket Events — Conexão entre criadores (§8)
  static const String eventLinkInvite = 'connect:link:invite';
  static const String eventLinkInviteStatus = 'connect:link:invite_status';
  static const String eventLinkStarted = 'connect:link:started';
  static const String eventLinkEnded = 'connect:link:ended';
  static const String eventLinkMute = 'connect:link:mute';
  /// Mudanças de estado do convite (pending/accepted/declined/expired/
  /// cancelled) — emitido para a sala `user:{id}` dos 2 streamers.
  static const String eventBattleInviteStatus = 'connect:battle:invite_status';

  // Live Room Statuses
  static const String statusWaiting = 'waiting';
  static const String statusScheduled = 'scheduled';
  static const String statusLive = 'live';
  static const String statusEnded = 'ended';

  // Video Configuration
  static const int videoFps = 30;
  static const int videoBitrate = 800 * 1024; // 800 kbps

  // Audio Configuration
  static const int audioBitrate = 32 * 1024; // 32 kbps

  static const List<String> categories = [
    'Shopping',
    'Gaming',
    'Talk Show',
    'Música',
    'Educação',
    'Fitness',
    'Culinária',
    'Beleza',
    'Tecnologia',
    'Esportes',
    'Entretenimento',
    'Outro',
  ];
}
