/// Helpers to safely extract data from marketplace backend responses.
///
/// The backend is inconsistent in how it wraps list responses:
/// - Some endpoints return a raw JSON array: `[{...}, {...}]`
/// - Some wrap it: `{"data": [{...}, {...}]}`
/// - Some paginate it: `{"items": [{...}], "total": n, "page": 1, ...}`
///
/// Indexing a `List` with a `String` key (e.g. `response.data['data']`)
/// throws a runtime [TypeError] that is NOT a [DioException], so it slips
/// past `on DioException catch (e)` blocks and gets silently swallowed by
/// outer generic catches — causing screens to render empty with no visible
/// error. Always use [extractList] instead of indexing `response.data`
/// directly when the endpoint may return a raw array.
library;

/// Safely extracts a list from a decoded JSON response body that may be:
/// - a raw `List`
/// - a `Map` with a `data` key holding the list
/// - a `Map` with an `items` key holding the list (paginated response)
List<dynamic> extractList(dynamic body) {
  if (body is List) return body;
  if (body is Map) {
    final data = body['items'] ?? body['data'] ?? body;
    if (data is List) return data;
  }
  return const [];
}

/// Safely extracts a single object (`Map`) from a decoded JSON response body
/// that may be a raw `Map` or a `Map` wrapped under a `data` key.
Map<String, dynamic> extractMap(dynamic body) {
  if (body is Map<String, dynamic>) {
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    return body;
  }
  return const {};
}
