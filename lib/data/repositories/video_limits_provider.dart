import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/video_limits.dart';
import '../services/post_service.dart';

/// Limites de vídeo de post lidos do servidor (fonte única). Falha de rede
/// ou servidor antigo → [VideoLimits.fallback]; nunca bloqueia o fluxo.
final videoLimitsProvider = FutureProvider.autoDispose<VideoLimits>((
  ref,
) async {
  final l = await ref.read(postServiceProvider).getVideoLimits();
  return l ?? VideoLimits.fallback;
});
