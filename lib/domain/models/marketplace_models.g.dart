// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoreBanner _$StoreBannerFromJson(Map<String, dynamic> json) => _StoreBanner(
  id: json['id'] as String,
  imageUrl: json['image_url'] as String,
  mobileImageUrl: json['mobile_image_url'] as String?,
  title: json['title'] as String,
  subtitle: json['subtitle'] as String,
  linkUrl: json['link_url'] as String,
  linkText: json['link_text'] as String,
  position: (json['position'] as num).toInt(),
);

Map<String, dynamic> _$StoreBannerToJson(_StoreBanner instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image_url': instance.imageUrl,
      'mobile_image_url': instance.mobileImageUrl,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'link_url': instance.linkUrl,
      'link_text': instance.linkText,
      'position': instance.position,
    };

_Store _$StoreFromJson(Map<String, dynamic> json) => _Store(
  id: json['id'] as String,
  ownerUserId: json['owner_user_id'] as String?,
  name: json['name'] as String,
  slug: json['slug'] as String,
  description: json['description'] as String,
  logoUrl: json['logo_url'] as String?,
  bannerUrl: json['banner_url'] as String?,
  banners: (json['banners'] as List<dynamic>?)
      ?.map((e) => StoreBanner.fromJson(e as Map<String, dynamic>))
      .toList(),
  currency: json['currency'] as String,
  defaultAffiliateCommission: (json['default_affiliate_commission'] as num?)
      ?.toDouble(),
  totalProducts: (json['total_products'] as num).toInt(),
  totalOrders: (json['total_orders'] as num).toInt(),
  totalSales: (json['total_sales'] as num?)?.toDouble(),
  rating: (json['rating'] as num).toDouble(),
  ratingCount: (json['rating_count'] as num).toInt(),
  isPremium: json['is_premium'] as bool? ?? false,
  hasBrawePass: json['has_brawe_pass'] as bool,
  contactEmail: json['contact_email'] as String?,
  contactWhatsapp: json['contact_whatsapp'] as String?,
  socialInstagram: json['social_instagram'] as String?,
  socialFacebook: json['social_facebook'] as String?,
  socialTiktok: json['social_tiktok'] as String?,
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  topProducts: (json['top_products'] as List<dynamic>?)
      ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['created_at'] as String?,
  memberSince: json['member_since'] as String?,
  applicationStatus: $enumDecodeNullable(
    _$ApplicationStatusEnumMap,
    json['application_status'],
  ),
  applicationId: json['application_id'] as String?,
  applicationMessage: json['application_message'] as String?,
  storeResponse: json['store_response'] as String?,
  isVerified: json['is_verified'] as bool? ?? false,
  legalName: json['legal_name'] as String?,
  tradeName: json['trade_name'] as String?,
  cnpj: json['cnpj'] as String?,
  location: json['location'] as String?,
  country: json['country'] as String?,
  storeUrl: json['store_url'] as String?,
  freeShippingThreshold: _nullablePriceFromJson(
    json['free_shipping_threshold'],
  ),
  localDeliveryEnabled: json['local_delivery_enabled'] as bool? ?? false,
  localDeliveryRadiusKm:
      (json['local_delivery_radius_km'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$StoreToJson(_Store instance) => <String, dynamic>{
  'id': instance.id,
  'owner_user_id': instance.ownerUserId,
  'name': instance.name,
  'slug': instance.slug,
  'description': instance.description,
  'logo_url': instance.logoUrl,
  'banner_url': instance.bannerUrl,
  'banners': instance.banners,
  'currency': instance.currency,
  'default_affiliate_commission': instance.defaultAffiliateCommission,
  'total_products': instance.totalProducts,
  'total_orders': instance.totalOrders,
  'total_sales': instance.totalSales,
  'rating': instance.rating,
  'rating_count': instance.ratingCount,
  'is_premium': instance.isPremium,
  'has_brawe_pass': instance.hasBrawePass,
  'contact_email': instance.contactEmail,
  'contact_whatsapp': instance.contactWhatsapp,
  'social_instagram': instance.socialInstagram,
  'social_facebook': instance.socialFacebook,
  'social_tiktok': instance.socialTiktok,
  'categories': instance.categories,
  'top_products': instance.topProducts,
  'created_at': instance.createdAt,
  'member_since': instance.memberSince,
  'application_status': _$ApplicationStatusEnumMap[instance.applicationStatus],
  'application_id': instance.applicationId,
  'application_message': instance.applicationMessage,
  'store_response': instance.storeResponse,
  'is_verified': instance.isVerified,
  'legal_name': instance.legalName,
  'trade_name': instance.tradeName,
  'cnpj': instance.cnpj,
  'location': instance.location,
  'country': instance.country,
  'store_url': instance.storeUrl,
  'free_shipping_threshold': instance.freeShippingThreshold,
  'local_delivery_enabled': instance.localDeliveryEnabled,
  'local_delivery_radius_km': instance.localDeliveryRadiusKm,
};

const _$ApplicationStatusEnumMap = {
  ApplicationStatus.pending: 'pending',
  ApplicationStatus.approved: 'approved',
  ApplicationStatus.rejected: 'rejected',
  ApplicationStatus.cancelled: 'cancelled',
};

_AffiliateApplication _$AffiliateApplicationFromJson(
  Map<String, dynamic> json,
) => _AffiliateApplication(
  id: json['id'] as String,
  storeId: json['store_id'] as String,
  storeName: json['store_name'] as String,
  storeLogo: json['store_logo'] as String?,
  status: $enumDecode(_$ApplicationStatusEnumMap, json['status']),
  message: json['message'] as String,
  storeResponse: json['store_response'] as String?,
  customCommission: (json['custom_commission'] as num?)?.toDouble(),
  sampleRequested: json['sample_requested'] as bool,
  sampleProductIds: (json['sample_product_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  sampleProducts: (json['sample_products'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  sampleSent: json['sample_sent'] as bool,
  sampleSentAt: json['sample_sent_at'] as String?,
  sampleTrackingCode: json['sample_tracking_code'] as String?,
  removalRequested: json['removal_requested'] as bool,
  removalRequestedAt: json['removal_requested_at'] as String?,
  createdAt: json['created_at'] as String,
  reviewedAt: json['reviewed_at'] as String?,
);

Map<String, dynamic> _$AffiliateApplicationToJson(
  _AffiliateApplication instance,
) => <String, dynamic>{
  'id': instance.id,
  'store_id': instance.storeId,
  'store_name': instance.storeName,
  'store_logo': instance.storeLogo,
  'status': _$ApplicationStatusEnumMap[instance.status]!,
  'message': instance.message,
  'store_response': instance.storeResponse,
  'custom_commission': instance.customCommission,
  'sample_requested': instance.sampleRequested,
  'sample_product_ids': instance.sampleProductIds,
  'sample_products': instance.sampleProducts,
  'sample_sent': instance.sampleSent,
  'sample_sent_at': instance.sampleSentAt,
  'sample_tracking_code': instance.sampleTrackingCode,
  'removal_requested': instance.removalRequested,
  'removal_requested_at': instance.removalRequestedAt,
  'created_at': instance.createdAt,
  'reviewed_at': instance.reviewedAt,
};

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  name: json['name'] as String,
  price: _priceFromJson(json['price']),
  compareAtPrice: _nullablePriceFromJson(json['compare_at_price']),
  description: json['description'] as String?,
  imageUrl: json['image_url'] as String?,
  images: json['images'] == null
      ? const <String>[]
      : _imagesFromJson(json['images']),
  categoryId: json['category_id'] as String?,
  categoryName: json['category_name'] as String?,
  quantity: (json['quantity'] as num).toInt(),
  sku: json['sku'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
  totalSold: (json['total_sold'] as num?)?.toInt() ?? 0,
  storeId: json['store_id'] as String?,
  storeName: json['store_name'] as String?,
  storeSlug: json['store_slug'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'compare_at_price': instance.compareAtPrice,
  'description': instance.description,
  'image_url': instance.imageUrl,
  'images': instance.images,
  'category_id': instance.categoryId,
  'category_name': instance.categoryName,
  'quantity': instance.quantity,
  'sku': instance.sku,
  'rating': instance.rating,
  'rating_count': instance.ratingCount,
  'total_sold': instance.totalSold,
  'store_id': instance.storeId,
  'store_name': instance.storeName,
  'store_slug': instance.storeSlug,
  'created_at': instance.createdAt,
};

_ShippingAddress _$ShippingAddressFromJson(Map<String, dynamic> json) =>
    _ShippingAddress(
      id: json['id'] as String?,
      label: json['label'] as String?,
      street: json['street'] as String,
      number: json['number'] as String,
      complement: json['complement'] as String?,
      neighborhood: json['neighborhood'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String? ?? 'BR',
      postalCode: json['postal_code'] as String,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      documentType: json['document_type'] as String? ?? 'cpf',
      documentNumber: json['document_number'] as String?,
      recipientName: json['recipient_name'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$ShippingAddressToJson(_ShippingAddress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'street': instance.street,
      'number': instance.number,
      'complement': instance.complement,
      'neighborhood': instance.neighborhood,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'postal_code': instance.postalCode,
      'lat': instance.lat,
      'lng': instance.lng,
      'document_type': instance.documentType,
      'document_number': instance.documentNumber,
      'recipient_name': instance.recipientName,
      'is_default': instance.isDefault,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_CartItem _$CartItemFromJson(Map<String, dynamic> json) => _CartItem(
  id: json['id'] as String,
  productId: json['product_id'] as String,
  variantId: json['variant_id'] as String?,
  storeId: json['store_id'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: _priceFromJson(json['unit_price']),
  totalPrice: _priceFromJson(json['total_price']),
  productName: json['product_name'] as String,
  productImage: json['product_image'] as String?,
  variantName: json['variant_name'] as String?,
  storeName: json['store_name'] as String?,
  affiliateRefCode: json['affiliate_ref_code'] as String?,
  roomId: json['room_id'] as String?,
  comissaoRate: _nullablePriceFromJson(json['comissao_rate']),
  comissaoAmount: _nullablePriceFromJson(json['comissao_amount']),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$CartItemToJson(_CartItem instance) => <String, dynamic>{
  'id': instance.id,
  'product_id': instance.productId,
  'variant_id': instance.variantId,
  'store_id': instance.storeId,
  'quantity': instance.quantity,
  'unit_price': instance.unitPrice,
  'total_price': instance.totalPrice,
  'product_name': instance.productName,
  'product_image': instance.productImage,
  'variant_name': instance.variantName,
  'store_name': instance.storeName,
  'affiliate_ref_code': instance.affiliateRefCode,
  'room_id': instance.roomId,
  'comissao_rate': instance.comissaoRate,
  'comissao_amount': instance.comissaoAmount,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

_Cart _$CartFromJson(Map<String, dynamic> json) => _Cart(
  id: json['id'] as String?,
  userId: json['user_id'] as String?,
  storeId: json['store_id'] as String?,
  items: (json['items'] as List<dynamic>)
      .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  subtotal: json['subtotal'] == null ? 0 : _priceFromJson(json['subtotal']),
  discount: json['discount'] == null ? 0 : _priceFromJson(json['discount']),
  shipping: json['shipping'] == null ? 0 : _priceFromJson(json['shipping']),
  total: json['total'] == null ? 0 : _priceFromJson(json['total']),
  couponCode: json['coupon_code'] as String?,
  couponDiscount: json['coupon_discount'] == null
      ? 0
      : _priceFromJson(json['coupon_discount']),
  itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$CartToJson(_Cart instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'store_id': instance.storeId,
  'items': instance.items,
  'subtotal': instance.subtotal,
  'discount': instance.discount,
  'shipping': instance.shipping,
  'total': instance.total,
  'coupon_code': instance.couponCode,
  'coupon_discount': instance.couponDiscount,
  'item_count': instance.itemCount,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

_OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => _OrderItem(
  id: json['id'] as String,
  productId: json['product_id'] as String,
  variantId: json['variant_id'] as String?,
  productName: json['product_name'] as String,
  variantName: json['variant_name'] as String?,
  sku: json['sku'] as String?,
  imageUrl: json['image_url'] as String?,
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: _priceFromJson(json['unit_price']),
  totalPrice: _priceFromJson(json['total_price']),
  affiliateCommissionRate: _nullablePriceFromJson(
    json['affiliate_commission_rate'],
  ),
  affiliateCommissionAmount: _nullablePriceFromJson(
    json['affiliate_commission_amount'],
  ),
  fulfilledQuantity: (json['fulfilled_quantity'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OrderItemToJson(_OrderItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'variant_id': instance.variantId,
      'product_name': instance.productName,
      'variant_name': instance.variantName,
      'sku': instance.sku,
      'image_url': instance.imageUrl,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'total_price': instance.totalPrice,
      'affiliate_commission_rate': instance.affiliateCommissionRate,
      'affiliate_commission_amount': instance.affiliateCommissionAmount,
      'fulfilled_quantity': instance.fulfilledQuantity,
    };

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  id: json['id'] as String,
  number: json['order_number'] as String,
  userId: json['user_id'] as String?,
  storeId: json['store_id'] as String?,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  affiliateId: json['affiliate_id'] as String?,
  affiliateCommissionAmount: _nullablePriceFromJson(
    json['affiliate_commission_amount'],
  ),
  subtotal: _priceFromJson(json['subtotal']),
  tax: _priceFromJson(json['tax']),
  shipping: _priceFromJson(json['shipping_cost']),
  total: _priceFromJson(json['total']),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  paymentStatus: $enumDecode(_$PaymentStatusEnumMap, json['payment_status']),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'id': instance.id,
  'order_number': instance.number,
  'user_id': instance.userId,
  'store_id': instance.storeId,
  'items': instance.items,
  'affiliate_id': instance.affiliateId,
  'affiliate_commission_amount': instance.affiliateCommissionAmount,
  'subtotal': instance.subtotal,
  'tax': instance.tax,
  'shipping_cost': instance.shipping,
  'total': instance.total,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'payment_status': _$PaymentStatusEnumMap[instance.paymentStatus]!,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.processing: 'processing',
  OrderStatus.shipped: 'shipped',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
  OrderStatus.refunded: 'refunded',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.awaitingPayment: 'awaiting_payment',
  PaymentStatus.paid: 'paid',
  PaymentStatus.failed: 'failed',
  PaymentStatus.refunded: 'refunded',
};

_PaymentIntent _$PaymentIntentFromJson(Map<String, dynamic> json) =>
    _PaymentIntent(
      id: json['id'] as String,
      orderId: json['order_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String,
      status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PaymentIntentToJson(_PaymentIntent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'amount': instance.amount,
      'method': instance.method,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'metadata': instance.metadata,
    };

_CartItemRequest _$CartItemRequestFromJson(Map<String, dynamic> json) =>
    _CartItemRequest(
      productId: json['product_id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      affiliateRefCode: json['affiliate_ref_code'] as String?,
      roomId: json['room_id'] as String?,
    );

Map<String, dynamic> _$CartItemRequestToJson(_CartItemRequest instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'quantity': instance.quantity,
      'affiliate_ref_code': instance.affiliateRefCode,
      'room_id': instance.roomId,
    };

_CartItemUpdateRequest _$CartItemUpdateRequestFromJson(
  Map<String, dynamic> json,
) => _CartItemUpdateRequest(quantity: (json['quantity'] as num).toInt());

Map<String, dynamic> _$CartItemUpdateRequestToJson(
  _CartItemUpdateRequest instance,
) => <String, dynamic>{'quantity': instance.quantity};

_CheckoutRequest _$CheckoutRequestFromJson(Map<String, dynamic> json) =>
    _CheckoutRequest(
      shippingAddress: ShippingAddress.fromJson(
        json['shipping_address'] as Map<String, dynamic>,
      ),
      billingAddress: json['billing_address'] == null
          ? null
          : ShippingAddress.fromJson(
              json['billing_address'] as Map<String, dynamic>,
            ),
      customerName: json['customer_name'] as String,
      customerEmail: json['customer_email'] as String,
      customerPhone: json['customer_phone'] as String?,
      customerDocument: json['customer_document'] as String?,
      customerFiscalData: json['customer_fiscal_data'] as Map<String, dynamic>?,
      shippingMethod: json['shipping_method'] as String,
      shippingCost: (json['shipping_cost'] as num?)?.toDouble(),
      paymentMethod: json['payment_method'] as String,
      couponCode: json['coupon_code'] as String?,
      customerNote: json['customer_note'] as String?,
      sessionId: json['session_id'] as String?,
      affiliateId: json['affiliate_id'] as String?,
    );

Map<String, dynamic> _$CheckoutRequestToJson(_CheckoutRequest instance) =>
    <String, dynamic>{
      'shipping_address': instance.shippingAddress,
      'billing_address': instance.billingAddress,
      'customer_name': instance.customerName,
      'customer_email': instance.customerEmail,
      'customer_phone': instance.customerPhone,
      'customer_document': instance.customerDocument,
      'customer_fiscal_data': instance.customerFiscalData,
      'shipping_method': instance.shippingMethod,
      'shipping_cost': instance.shippingCost,
      'payment_method': instance.paymentMethod,
      'coupon_code': instance.couponCode,
      'customer_note': instance.customerNote,
      'session_id': instance.sessionId,
      'affiliate_id': instance.affiliateId,
    };

_PaymentRequest _$PaymentRequestFromJson(Map<String, dynamic> json) =>
    _PaymentRequest(
      orderId: json['order_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PaymentRequestToJson(_PaymentRequest instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'amount': instance.amount,
      'method': instance.method,
      'metadata': instance.metadata,
    };
