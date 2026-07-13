/// Abstract interface for Store Showcase Service.
/// Provides methods to browse marketplace affiliate showcases and manage applications.
///
/// Uses [dioProvider] (main backend) for all endpoints under /marketplace/*

abstract class StoreShowcaseService {
  /// Fetch list of available store showcases with pagination & filtering.
  ///
  /// GET /marketplace/affiliate/showcase
  ///
  /// - `page`: Page number (default 1)
  /// - `perPage`: Items per page, max 50 (default 12)
  /// - `search`: Optional search string
  /// - `category`: Optional category filter
  /// - `minCommission`: Optional minimum commission rate filter
  /// - `sortBy`: Sort order — "rating" | "commission" | "newest" | "products"
  ///
  /// Returns a paginated list of [Store] objects ready to display.
  /// Each store includes application status for current user.
  Future<List<dynamic>> getShowcase({
    int page = 1,
    int perPage = 12,
    String? search,
    String? category,
    double? minCommission,
    String? sortBy,
  });

  /// Fetch detailed store showcase by slug.
  ///
  /// GET /marketplace/affiliate/showcase/:slug
  ///
  /// Returns full [Store] object with top products and detailed metrics.
  /// Includes current user's application status and store response.
  Future<dynamic> getStore(String slug);

  /// Submit affiliate application to a store.
  ///
  /// POST /marketplace/affiliate/showcase/{slug}/apply
  ///
  /// Request body:
  /// - `message`: Pitch message (required)
  /// - `sample_requested`: Whether to request samples (bool)
  /// - `sample_product_ids`: List of product IDs to sample (optional)
  /// - `custom_commission`: Optional custom commission rate (only set by admin)
  ///
  /// Returns [AffiliateApplication] with pending status.
  /// Throws [AppException] if user is not an affiliate or application already exists.
  Future<dynamic> applyForPartnership(
    String storeSlug, {
    required String message,
    bool sampleRequested = false,
    List<String> sampleProductIds = const [],
    String? customCommission,
  });

  /// Fetch user's affiliate applications across all stores.
  ///
  /// GET /marketplace/affiliate/my-applications
  ///
  /// Query params:
  /// - `status`: Filter by status — "pending" | "approved" | "rejected" | "cancelled"
  ///
  /// Returns list of [AffiliateApplication] objects.
  Future<List<dynamic>> getMyApplications({String? status});

  /// Delete/cancel an affiliate application.
  ///
  /// DELETE /marketplace/affiliate/my-applications/{applicationId}
  ///
  /// Throws [AppException] if application not found or already reviewed.
  Future<void> deleteApplication(String applicationId);

  /// Review and approve/reject an affiliate application (ADMIN ONLY).
  ///
  /// PUT /marketplace/affiliate/my-applications/{applicationId}/review
  ///
  /// Request body:
  /// - `approved`: bool — approve or reject
  /// - `message`: Optional response message to affiliate
  /// - `custom_commission`: Optional custom commission rate (if approved)
  ///
  /// Returns updated [AffiliateApplication].
  /// Throws [AppException] if user is not admin or application not pending.
  Future<dynamic> submitApplicationReview(
    String applicationId, {
    required bool approved,
    String? message,
    String? customCommission,
  });

  /// Fetch the PUBLIC storefront(s) for an arbitrary user, by `userId` —
  /// no authentication required, works for ANY visited profile (own or
  /// someone else's).
  ///
  /// GET /marketplace/affiliate/{userId}/storefront
  ///
  /// Returns a list of store-with-products groups (one per store where
  /// the user has an approved+active affiliate application). Empty list
  /// means the user has no approved storefront — not an error.
  ///
  /// Used to decide whether the storefront icon/badge should be shown on
  /// a profile page, regardless of who is viewing it.
  Future<List<dynamic>> getPublicStorefront(String userId);
}
