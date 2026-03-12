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
  static const String socketPath = '/socket.io/';
  static const List<String> socketTransports = ['websocket'];

  // Socket Events
  static const String eventJoinRoom = 'join_room';
  static const String eventLeaveRoom = 'leave_room';
  static const String eventNewMessage = 'new_message';
  static const String eventViewerCount = 'viewer_count';

  // Live Room Statuses
  static const String statusWaiting = 'waiting';
  static const String statusLive = 'live';
  static const String statusEnded = 'ended';

  // Video Configuration
  static const int videoFps = 30;
  static const int videoBitrate = 1 * 1024 * 1024; // 1 Mbps
  
  // Audio Configuration
  static const int audioBitrate = 64 * 1024; // 64 kbps

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
