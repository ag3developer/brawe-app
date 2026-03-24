class CreateLiveRoomRequestDto {
  const CreateLiveRoomRequestDto({
    required this.title,
    this.description,
    this.category,
    this.tags,
    this.isPrivate = false,
    this.liveType = 'solo',
    this.scheduledAt,
    this.chatEnabled = true,
    this.giftsEnabled = true,
    this.shoppingEnabled = true,
  });

  final String title;
  final String? description;
  final String? category;
  final List<String>? tags;
  final bool isPrivate;
  final String liveType;
  final DateTime? scheduledAt;
  final bool chatEnabled;
  final bool giftsEnabled;
  final bool shoppingEnabled;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'tags': tags,
      'live_type': liveType,
      'is_private': isPrivate,
      'scheduled_at': scheduledAt?.toUtc().toIso8601String(),
      'chat_enabled': chatEnabled,
      'gifts_enabled': giftsEnabled,
      'shopping_enabled': shoppingEnabled,
    }..removeWhere((_, value) => value == null);
  }
}
