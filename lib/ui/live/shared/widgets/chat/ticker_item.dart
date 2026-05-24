import '../../../../../domain/models/live_comment.dart';
import '../../../../../domain/models/live_gift.dart';

/// Item interno do ticker do chat: ou um comentário ou um presente.
///
/// Permite mesclar `LiveComment` + `LiveGift` numa única timeline
/// ordenada por timestamp.
class TickerItem {
  TickerItem({required this.timestamp, this.comment, this.gift});
  final DateTime timestamp;
  final LiveComment? comment;
  final LiveGift? gift;
}
