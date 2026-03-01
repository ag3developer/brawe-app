import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/live_room.dart';
import '../services/live_service.dart';
import '../model/live_room_dto.dart';
import '../../domain/models/failure.dart';
import 'package:dio/dio.dart';

part 'live_repository.g.dart';

@riverpod
LiveRepository liveRepository(Ref ref) {
  return LiveRepository(ref.watch(liveServiceProvider));
}

class LiveRepository {
  final LiveService _liveService;

  LiveRepository(this._liveService);

  Future<List<LiveRoom>> getLiveFeed({String? cursor, int limit = 10}) async {
    try {
      final dtos = await _liveService.getLiveFeed(cursor: cursor, limit: limit);
      return dtos.map((dto) => dto.toDomain()).toList();
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }
}
