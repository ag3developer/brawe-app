class CreateLiveRoomRequestDto {
  const CreateLiveRoomRequestDto({
    required this.title,
    this.description,
    this.category,
    this.isPrivate = false,
    this.liveType = 'solo',
    this.chatEnabled = true,
    this.giftsEnabled = true,
    this.shoppingEnabled = true,
  });

  final String title;
  final String? description;
  final String? category;
  final bool isPrivate;
  final String liveType;
  final bool chatEnabled;
  final bool giftsEnabled;
  final bool shoppingEnabled;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'live_type': liveType,
      'is_private': isPrivate,
      'chat_enabled': chatEnabled,
      'gifts_enabled': giftsEnabled,
      'shopping_enabled': shoppingEnabled,
    }..removeWhere((_, value) => value == null);
  }
}
