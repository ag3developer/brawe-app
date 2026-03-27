class AppConstants {
  const AppConstants._();

  // API URLs
  static const String connectApiBaseUrl = 'https://connect.brawe.io';
  static const String appApiBaseUrl = 'https://app.brawe.io';

  static const String connectApiV1Url = '$connectApiBaseUrl/api/v1';
  static const String appApiV1Url = '$appApiBaseUrl/api/v1';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration liveInitiationTimeout = Duration(seconds: 20);

  // Other constants
  static const int feedLimit = 10;
  static const int roomsLimit = 20;

  // Socket.IO
  static const String socketPath = '/ws/socket.io';
  static const List<String> socketTransports = ['websocket', 'polling'];

  // Socket Events
  static const String eventAuthenticate = 'authenticate';
  static const String eventAuthenticated = 'authenticated';
  static const String eventJoinRoom = 'join_live';
  static const String eventLeaveRoom = 'leave_live';
  static const String eventSendMessage = 'live_chat_message';
  static const String eventNewMessage = 'live_chat';
  static const String eventViewerCount = 'viewer_count_update';
  static const String eventRequestViewers = 'get_live_viewers';
  static const String eventNewGift = 'gift_received';
  static const String eventLiveEnded = 'live_ended';

  // Direct Message Events
  static const String eventDmMessage = 'dm_message';
  static const String eventDmReceived = 'dm_received';
  static const String eventTypingStart = 'typing_start';
  static const String eventTypingStop = 'typing_stop';
  static const String eventUserTyping = 'user_typing';
  static const String eventMarkRead = 'mark_read';
  static const String eventConversationUpdated = 'conversation_updated';

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
