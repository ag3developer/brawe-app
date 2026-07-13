import 'package:freezed_annotation/freezed_annotation.dart';

part 'marketplace_models.freezed.dart';
part 'marketplace_models.g.dart';

// ============================================================================
// JSON PARSE HELPERS
// ============================================================================
// O backend (Python/Decimal) às vezes serializa valores monetários como
// String (ex: "109.90") em vez de número — estes helpers tornam o parse
// resiliente a ambos os formatos, evitando exceções de cast em runtime.

double _priceFromJson(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

double? _nullablePriceFromJson(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Normaliza `images` do backend, que pode vir como lista de Strings ou
/// lista de objetos `{url, position}` — sempre retorna `List<String>`.
List<String> _imagesFromJson(dynamic value) {
  if (value is List) {
    return value
        .map((e) {
          if (e is String) return e;
          if (e is Map && e['url'] != null) return e['url'].toString();
          return null;
        })
        .whereType<String>()
        .toList();
  }
  return const [];
}

// ============================================================================
// ENUMS
// ============================================================================

enum ApplicationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('cancelled')
  cancelled,
}

enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('processing')
  processing,
  @JsonValue('shipped')
  shipped,
  @JsonValue('delivered')
  delivered,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('refunded')
  refunded,
}

enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('awaiting_payment')
  awaitingPayment,
  @JsonValue('paid')
  paid,
  @JsonValue('failed')
  failed,
  @JsonValue('refunded')
  refunded,
}

// ============================================================================
// STORE SHOWCASE
// ============================================================================

@freezed
sealed class StoreBanner with _$StoreBanner {
  const factory StoreBanner({
    required String id,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'mobile_image_url') String? mobileImageUrl,
    required String title,
    required String subtitle,
    @JsonKey(name: 'link_url') required String linkUrl,
    @JsonKey(name: 'link_text') required String linkText,
    required int position,
  }) = _StoreBanner;

  factory StoreBanner.fromJson(Map<String, dynamic> json) =>
      _$StoreBannerFromJson(json);
}

@freezed
sealed class Store with _$Store {
  const factory Store({
    required String id,
    @JsonKey(name: 'owner_user_id') String? ownerUserId,
    required String name,
    required String slug,
    required String description,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @JsonKey(name: 'banner_url') String? bannerUrl,
    @JsonKey(name: 'banners') List<StoreBanner>? banners,
    required String currency,
    // ⚠️ Nunca exibir na vitrine pública (regra de negócio) — ausente na
    // resposta pública de /shopping/stores/{slug}, presente só no showcase
    // interno de afiliados.
    @JsonKey(name: 'default_affiliate_commission')
    double? defaultAffiliateCommission,
    @JsonKey(name: 'total_products') required int totalProducts,
    @JsonKey(name: 'total_orders') required int totalOrders,
    @JsonKey(name: 'total_sales') double? totalSales,
    required double rating,
    @JsonKey(name: 'rating_count') required int ratingCount,
    // Ausente na resposta pública -> default false.
    @JsonKey(name: 'is_premium') @Default(false) bool isPremium,
    @JsonKey(name: 'has_brawe_pass') required bool hasBrawePass,
    @JsonKey(name: 'contact_email') String? contactEmail,
    @JsonKey(name: 'contact_whatsapp') String? contactWhatsapp,
    @JsonKey(name: 'social_instagram') String? socialInstagram,
    @JsonKey(name: 'social_facebook') String? socialFacebook,
    @JsonKey(name: 'social_tiktok') String? socialTiktok,
    // Ausente na resposta pública -> default lista vazia.
    @Default(<String>[]) List<String> categories,
    @JsonKey(name: 'top_products') List<Product>? topProducts,
    // Endpoint público retorna `member_since` em vez de `created_at`.
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'member_since') String? memberSince,
    @JsonKey(name: 'application_status') ApplicationStatus? applicationStatus,
    @JsonKey(name: 'application_id') String? applicationId,
    @JsonKey(name: 'application_message') String? applicationMessage,
    @JsonKey(name: 'store_response') String? storeResponse,
    // Campos extras do endpoint público (/shopping/stores/{slug}).
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'legal_name') String? legalName,
    @JsonKey(name: 'trade_name') String? tradeName,
    String? cnpj,
    String? location,
    String? country,
    @JsonKey(name: 'store_url') String? storeUrl,
    // Configurações de frete
    @JsonKey(name: 'free_shipping_threshold', fromJson: _nullablePriceFromJson)
    double? freeShippingThreshold,
    @JsonKey(name: 'local_delivery_enabled')
    @Default(false)
    bool localDeliveryEnabled,
    @JsonKey(name: 'local_delivery_radius_km')
    @Default(0)
    int localDeliveryRadiusKm,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
}

@freezed
sealed class AffiliateApplication with _$AffiliateApplication {
  const factory AffiliateApplication({
    required String id,
    @JsonKey(name: 'store_id') required String storeId,
    @JsonKey(name: 'store_name') required String storeName,
    @JsonKey(name: 'store_logo') String? storeLogo,
    required ApplicationStatus status,
    required String message,
    @JsonKey(name: 'store_response') String? storeResponse,
    @JsonKey(name: 'custom_commission') double? customCommission,
    @JsonKey(name: 'sample_requested') required bool sampleRequested,
    @JsonKey(name: 'sample_product_ids') required List<String> sampleProductIds,
    @JsonKey(name: 'sample_products')
    required List<Map<String, dynamic>> sampleProducts,
    @JsonKey(name: 'sample_sent') required bool sampleSent,
    @JsonKey(name: 'sample_sent_at') String? sampleSentAt,
    @JsonKey(name: 'sample_tracking_code') String? sampleTrackingCode,
    @JsonKey(name: 'removal_requested') required bool removalRequested,
    @JsonKey(name: 'removal_requested_at') String? removalRequestedAt,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'reviewed_at') String? reviewedAt,
  }) = _AffiliateApplication;

  factory AffiliateApplication.fromJson(Map<String, dynamic> json) =>
      _$AffiliateApplicationFromJson(json);
}

// ============================================================================
// PRODUCTS
// ============================================================================

@freezed
sealed class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    @JsonKey(fromJson: _priceFromJson) required double price,
    @JsonKey(name: 'compare_at_price', fromJson: _nullablePriceFromJson)
    double? compareAtPrice,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(fromJson: _imagesFromJson)
    @Default(<String>[])
    List<String> images,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'category_name') String? categoryName,
    required int quantity,
    String? sku,
    double? rating,
    @JsonKey(name: 'rating_count') @Default(0) int ratingCount,
    @JsonKey(name: 'total_sold') @Default(0) int totalSold,
    @JsonKey(name: 'store_id') String? storeId,
    @JsonKey(name: 'store_name') String? storeName,
    @JsonKey(name: 'store_slug') String? storeSlug,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

/// Helpers de conveniência para exibição do produto.
extension ProductDisplayX on Product {
  /// Primeira imagem disponível: prioriza `imageUrl` (usado pelo endpoint de
  /// showcase), com fallback para a primeira entrada de `images` (usado
  /// pelos endpoints `/products/store/:id` e `/products/:id`).
  String? get primaryImageUrl =>
      imageUrl ?? (images.isNotEmpty ? images.first : null);
}

// ============================================================================
// CART & CHECKOUT
// ============================================================================

@freezed
sealed class ShippingAddress with _$ShippingAddress {
  const factory ShippingAddress({
    // Ausente para um endereço ainda não salvo (preenchido no formulário
    // de checkout, mas ainda não enviado ao backend).
    String? id,
    // Rótulo amigável definido pelo usuário (ex.: "Casa", "Trabalho").
    String? label,
    required String street,
    required String number,
    String? complement,
    required String neighborhood,
    required String city,
    required String state,
    @Default('BR') String country,
    @JsonKey(name: 'postal_code') required String postalCode,
    double? lat,
    double? lng,
    // ⚠️ Dados fiscais do destinatário — OBRIGATÓRIOS para a loja emitir
    // NF do pedido físico. 'cpf' ou 'cnpj'.
    @JsonKey(name: 'document_type') @Default('cpf') String documentType,
    @JsonKey(name: 'document_number') String? documentNumber,
    @JsonKey(name: 'recipient_name') String? recipientName,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ShippingAddress;

  factory ShippingAddress.fromJson(Map<String, dynamic> json) =>
      _$ShippingAddressFromJson(json);
}

@freezed
sealed class CartItem with _$CartItem {
  const factory CartItem({
    required String id,
    @JsonKey(name: 'product_id') required String productId,
    @JsonKey(name: 'variant_id') String? variantId,
    @JsonKey(name: 'store_id') required String storeId,
    required int quantity,
    // Backend serializa Decimal como String no JSON (ex.: "79.90") — usar o
    // mesmo helper resiliente de Product para aceitar String ou num.
    @JsonKey(name: 'unit_price', fromJson: _priceFromJson)
    required double unitPrice,
    @JsonKey(name: 'total_price', fromJson: _priceFromJson)
    required double totalPrice,
    @JsonKey(name: 'product_name') required String productName,
    @JsonKey(name: 'product_image') String? productImage,
    @JsonKey(name: 'variant_name') String? variantName,
    // Nome real da loja (via Product.store no backend) — usado para
    // agrupar itens por loja no checkout quando há múltiplas lojas.
    @JsonKey(name: 'store_name') String? storeName,
    // ⭐ CRÍTICO: campos de comissão do afiliado
    @JsonKey(name: 'affiliate_ref_code') String? affiliateRefCode,
    @JsonKey(name: 'room_id') String? roomId,
    @JsonKey(name: 'comissao_rate', fromJson: _nullablePriceFromJson)
    double? comissaoRate,
    @JsonKey(name: 'comissao_amount', fromJson: _nullablePriceFromJson)
    double? comissaoAmount,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}

@freezed
sealed class Cart with _$Cart {
  const factory Cart({
    // Carrinho de visitante (sem itens ainda) pode não ter `id`.
    String? id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'store_id') String? storeId,
    required List<CartItem> items,
    // Todos os valores monetários abaixo vêm como String do backend
    // (Decimal serializado) — usar o helper resiliente para aceitar
    // String ou num.
    @JsonKey(fromJson: _priceFromJson) @Default(0) double subtotal,
    @JsonKey(fromJson: _priceFromJson) @Default(0) double discount,
    @JsonKey(fromJson: _priceFromJson) @Default(0) double shipping,
    @JsonKey(fromJson: _priceFromJson) @Default(0) double total,
    @JsonKey(name: 'coupon_code') String? couponCode,
    @JsonKey(name: 'coupon_discount', fromJson: _priceFromJson)
    @Default(0)
    double couponDiscount,
    @JsonKey(name: 'item_count') @Default(0) int itemCount,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
}

@freezed
sealed class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String id,
    @JsonKey(name: 'product_id') required String productId,
    @JsonKey(name: 'variant_id') String? variantId,
    @JsonKey(name: 'product_name') required String productName,
    @JsonKey(name: 'variant_name') String? variantName,
    String? sku,
    @JsonKey(name: 'image_url') String? imageUrl,
    required int quantity,
    @JsonKey(name: 'unit_price', fromJson: _priceFromJson)
    required double unitPrice,
    @JsonKey(name: 'total_price', fromJson: _priceFromJson)
    required double totalPrice,
    // ⭐ CRÍTICO: comissão do afiliado
    @JsonKey(
      name: 'affiliate_commission_rate',
      fromJson: _nullablePriceFromJson,
    )
    double? affiliateCommissionRate,
    @JsonKey(
      name: 'affiliate_commission_amount',
      fromJson: _nullablePriceFromJson,
    )
    double? affiliateCommissionAmount,
    @JsonKey(name: 'fulfilled_quantity') @Default(0) int fulfilledQuantity,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}

@freezed
sealed class Order with _$Order {
  const factory Order({
    required String id,
    @JsonKey(name: 'order_number') required String number,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'store_id') String? storeId,
    required List<OrderItem> items,
    // ⭐ CRÍTICO: rastreamento de comissão
    @JsonKey(name: 'affiliate_id') String? affiliateId,
    @JsonKey(
      name: 'affiliate_commission_amount',
      fromJson: _nullablePriceFromJson,
    )
    double? affiliateCommissionAmount,
    @JsonKey(fromJson: _priceFromJson) required double subtotal,
    @JsonKey(fromJson: _priceFromJson) required double tax,
    @JsonKey(name: 'shipping_cost', fromJson: _priceFromJson)
    required double shipping,
    @JsonKey(fromJson: _priceFromJson) required double total,
    required OrderStatus status,
    @JsonKey(name: 'payment_status') required PaymentStatus paymentStatus,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

@freezed
sealed class PaymentIntent with _$PaymentIntent {
  const factory PaymentIntent({
    required String id,
    @JsonKey(name: 'order_id') String? orderId,
    required double amount,
    required String method,
    required PaymentStatus status,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    Map<String, dynamic>? metadata,
  }) = _PaymentIntent;

  factory PaymentIntent.fromJson(Map<String, dynamic> json) =>
      _$PaymentIntentFromJson(json);
}

// ============================================================================
// REQUEST/RESPONSE DTOs
// ============================================================================

@freezed
sealed class CartItemRequest with _$CartItemRequest {
  const factory CartItemRequest({
    @JsonKey(name: 'product_id') required String productId,
    required int quantity,
    @JsonKey(name: 'affiliate_ref_code') String? affiliateRefCode,
    @JsonKey(name: 'room_id') String? roomId,
  }) = _CartItemRequest;

  factory CartItemRequest.fromJson(Map<String, dynamic> json) =>
      _$CartItemRequestFromJson(json);
}

@freezed
sealed class CartItemUpdateRequest with _$CartItemUpdateRequest {
  const factory CartItemUpdateRequest({required int quantity}) =
      _CartItemUpdateRequest;

  factory CartItemUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$CartItemUpdateRequestFromJson(json);
}

@freezed
sealed class CheckoutRequest with _$CheckoutRequest {
  const factory CheckoutRequest({
    @JsonKey(name: 'shipping_address') required ShippingAddress shippingAddress,
    @JsonKey(name: 'billing_address') ShippingAddress? billingAddress,
    @JsonKey(name: 'customer_name') required String customerName,
    @JsonKey(name: 'customer_email') required String customerEmail,
    @JsonKey(name: 'customer_phone') String? customerPhone,
    @JsonKey(name: 'customer_document') String? customerDocument,
    @JsonKey(name: 'customer_fiscal_data')
    Map<String, dynamic>? customerFiscalData,
    @JsonKey(name: 'shipping_method') required String shippingMethod,
    @JsonKey(name: 'shipping_cost') double? shippingCost,
    @JsonKey(name: 'payment_method') required String paymentMethod,
    @JsonKey(name: 'coupon_code') String? couponCode,
    @JsonKey(name: 'customer_note') String? customerNote,
    @JsonKey(name: 'session_id') String? sessionId,
    // ⭐ CRÍTICO: afiliado que referiu
    @JsonKey(name: 'affiliate_id') String? affiliateId,
  }) = _CheckoutRequest;

  factory CheckoutRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckoutRequestFromJson(json);
}

@freezed
sealed class PaymentRequest with _$PaymentRequest {
  const factory PaymentRequest({
    @JsonKey(name: 'order_id') required String orderId,
    required double amount,
    required String method,
    Map<String, dynamic>? metadata,
  }) = _PaymentRequest;

  factory PaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestFromJson(json);
}
