import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/services/link_preview_service.dart';

part 'link_preview_provider.g.dart';

/// Busca (e cacheia em memória, por URL) o preview de um link para exibir
/// no `LinkPreviewCard`. Riverpod já cacheia o resultado por `url` — o
/// mesmo link repetido no feed não dispara múltiplos fetches.
@riverpod
Future<LinkPreview?> linkPreview(Ref ref, String url) async {
  final service = ref.watch(linkPreviewServiceProvider);
  return service.unfurl(url);
}
