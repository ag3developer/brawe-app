import 'package:dio/dio.dart';
import '../../domain/models/marketplace_models.dart';
import 'marketplace_response_utils.dart';
import 'store_showcase_service.dart';

/// Implementation of [StoreShowcaseService].
/// Communicates with Main Backend (/marketplace/* endpoints).
class StoreShowcaseServiceImpl implements StoreShowcaseService {
  final Dio _dio;

  StoreShowcaseServiceImpl(this._dio);

  @override
  Future<List<Store>> getShowcase({
    int page = 1,
    int perPage = 12,
    String? search,
    String? category,
    double? minCommission,
    String? sortBy,
  }) async {
    try {
      print('[StoreShowcaseService] getShowcase() called');

      final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};

      if (search != null) queryParams['search'] = search;
      if (category != null) queryParams['category'] = category;
      if (minCommission != null) queryParams['min_commission'] = minCommission;
      if (sortBy != null) queryParams['sort_by'] = sortBy;

      final response = await _dio.get(
        '/marketplace/affiliate/showcase',
        queryParameters: queryParams,
      );

      // Backend retorna resposta paginada: {items, total, page, per_page, pages}
      final data = extractList(response.data);
      return data
          .map((item) => Store.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('[StoreShowcaseService] Error in getShowcase: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<Store> getStore(String slug) async {
    try {
      print('[StoreShowcaseService] getStore($slug) called');

      final response = await _dio.get('/marketplace/affiliate/showcase/$slug');

      final data = extractMap(response.data);
      return Store.fromJson(data);
    } on DioException catch (e) {
      print('[StoreShowcaseService] Error in getStore: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<AffiliateApplication> applyForPartnership(
    String storeSlug, {
    required String message,
    bool sampleRequested = false,
    List<String> sampleProductIds = const [],
    String? customCommission,
  }) async {
    try {
      print('[StoreShowcaseService] applyForPartnership($storeSlug) called');

      final requestBody = <String, dynamic>{
        'message': message,
        'sample_requested': sampleRequested,
        'sample_product_ids': sampleProductIds,
      };

      if (customCommission != null) {
        requestBody['custom_commission'] = customCommission;
      }

      final response = await _dio.post(
        '/marketplace/affiliate/showcase/$storeSlug/apply',
        data: requestBody,
      );

      final data = extractMap(response.data);
      return AffiliateApplication.fromJson(data);
    } on DioException catch (e) {
      print(
        '[StoreShowcaseService] Error in applyForPartnership: ${e.message}',
      );
      rethrow;
    }
  }

  @override
  Future<List<AffiliateApplication>> getMyApplications({String? status}) async {
    try {
      print('[StoreShowcaseService] getMyApplications() called');

      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;

      final response = await _dio.get(
        '/marketplace/affiliate/my-applications',
        queryParameters: queryParams,
      );

      // Backend retorna lista direta (não wrapper {data: [...]}). Indexar
      // uma List com uma String ('data') lança TypeError em runtime — por
      // isso extraímos com segurança via [extractList].
      final data = extractList(response.data);
      return data
          .map(
            (item) =>
                AffiliateApplication.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      print('[StoreShowcaseService] Error in getMyApplications: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<void> deleteApplication(String applicationId) async {
    try {
      print('[StoreShowcaseService] deleteApplication($applicationId) called');

      await _dio.delete(
        '/marketplace/affiliate/my-applications/$applicationId',
      );
    } on DioException catch (e) {
      print('[StoreShowcaseService] Error in deleteApplication: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<AffiliateApplication> submitApplicationReview(
    String applicationId, {
    required bool approved,
    String? message,
    String? customCommission,
  }) async {
    try {
      print(
        '[StoreShowcaseService] submitApplicationReview($applicationId) called',
      );

      final requestBody = <String, dynamic>{'approved': approved};

      if (message != null) requestBody['message'] = message;
      if (customCommission != null) {
        requestBody['custom_commission'] = customCommission;
      }

      final response = await _dio.put(
        '/marketplace/affiliate/my-applications/$applicationId/review',
        data: requestBody,
      );

      final data = extractMap(response.data);
      return AffiliateApplication.fromJson(data);
    } on DioException catch (e) {
      print(
        '[StoreShowcaseService] Error in submitApplicationReview: ${e.message}',
      );
      rethrow;
    }
  }
}
