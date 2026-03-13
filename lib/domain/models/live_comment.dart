class LiveComment {
  const LiveComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.timestamp,
    this.avatarUrl,
    this.isPending = false,
  });

  final String id;
  final String userId;
  final String userName;
  final String message;
  final DateTime timestamp;
  final String? avatarUrl;
  final bool isPending;

  LiveComment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? message,
    DateTime? timestamp,
    String? avatarUrl,
    bool? isPending,
  }) {
    return LiveComment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPending: isPending ?? this.isPending,
    );
  }
}
