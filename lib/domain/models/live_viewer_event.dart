/// Evento de viewer entrando/saindo da live (não persistido — só UI).
class LiveViewerEvent {
  const LiveViewerEvent({
    required this.userId,
    required this.viewerName,
    this.viewerAvatar,
    this.viewerCount = 0,
    required this.joined,
  });

  final String userId;
  final String viewerName;
  final String? viewerAvatar;
  final int viewerCount;
  final bool joined; // true=joined, false=left

  factory LiveViewerEvent.fromSocket(Map<String, dynamic> data, {required bool joined}) {
    return LiveViewerEvent(
      userId: data['user_id']?.toString() ?? '',
      viewerName: data['viewer_name']?.toString() ?? 'Alguém',
      viewerAvatar: data['viewer_avatar']?.toString(),
      viewerCount: (data['viewer_count'] is int)
          ? data['viewer_count'] as int
          : int.tryParse('${data['viewer_count']}') ?? 0,
      joined: joined,
    );
  }
}
