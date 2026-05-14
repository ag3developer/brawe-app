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
  static const int chatPageLimit = 50;
  static const int conversationsPageLimit = 20;

  // Socket.IO
  static const String socketPath = '/ws/socket.io';
  static const List<String> socketTransports = ['websocket', 'polling'];

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
  static const String eventLiveEnded = 'live_ended';

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
