// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marketplace_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StoreBanner {

 String get id;@JsonKey(name: 'image_url') String get imageUrl;@JsonKey(name: 'mobile_image_url') String? get mobileImageUrl; String get title; String get subtitle;@JsonKey(name: 'link_url') String get linkUrl;@JsonKey(name: 'link_text') String get linkText; int get position;
/// Create a copy of StoreBanner
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreBannerCopyWith<StoreBanner> get copyWith => _$StoreBannerCopyWithImpl<StoreBanner>(this as StoreBanner, _$identity);

  /// Serializes this StoreBanner to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreBanner&&(identical(other.id, id) || other.id == id)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.mobileImageUrl, mobileImageUrl) || other.mobileImageUrl == mobileImageUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.linkUrl, linkUrl) || other.linkUrl == linkUrl)&&(identical(other.linkText, linkText) || other.linkText == linkText)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,imageUrl,mobileImageUrl,title,subtitle,linkUrl,linkText,position);

@override
String toString() {
  return 'StoreBanner(id: $id, imageUrl: $imageUrl, mobileImageUrl: $mobileImageUrl, title: $title, subtitle: $subtitle, linkUrl: $linkUrl, linkText: $linkText, position: $position)';
}


}

/// @nodoc
abstract mixin class $StoreBannerCopyWith<$Res>  {
  factory $StoreBannerCopyWith(StoreBanner value, $Res Function(StoreBanner) _then) = _$StoreBannerCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'mobile_image_url') String? mobileImageUrl, String title, String subtitle,@JsonKey(name: 'link_url') String linkUrl,@JsonKey(name: 'link_text') String linkText, int position
});




}
/// @nodoc
class _$StoreBannerCopyWithImpl<$Res>
    implements $StoreBannerCopyWith<$Res> {
  _$StoreBannerCopyWithImpl(this._self, this._then);

  final StoreBanner _self;
  final $Res Function(StoreBanner) _then;

/// Create a copy of StoreBanner
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? imageUrl = null,Object? mobileImageUrl = freezed,Object? title = null,Object? subtitle = null,Object? linkUrl = null,Object? linkText = null,Object? position = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,mobileImageUrl: freezed == mobileImageUrl ? _self.mobileImageUrl : mobileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,linkUrl: null == linkUrl ? _self.linkUrl : linkUrl // ignore: cast_nullable_to_non_nullable
as String,linkText: null == linkText ? _self.linkText : linkText // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StoreBanner].
extension StoreBannerPatterns on StoreBanner {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreBanner value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreBanner() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreBanner value)  $default,){
final _that = this;
switch (_that) {
case _StoreBanner():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreBanner value)?  $default,){
final _that = this;
switch (_that) {
case _StoreBanner() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'mobile_image_url')  String? mobileImageUrl,  String title,  String subtitle, @JsonKey(name: 'link_url')  String linkUrl, @JsonKey(name: 'link_text')  String linkText,  int position)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreBanner() when $default != null:
return $default(_that.id,_that.imageUrl,_that.mobileImageUrl,_that.title,_that.subtitle,_that.linkUrl,_that.linkText,_that.position);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'mobile_image_url')  String? mobileImageUrl,  String title,  String subtitle, @JsonKey(name: 'link_url')  String linkUrl, @JsonKey(name: 'link_text')  String linkText,  int position)  $default,) {final _that = this;
switch (_that) {
case _StoreBanner():
return $default(_that.id,_that.imageUrl,_that.mobileImageUrl,_that.title,_that.subtitle,_that.linkUrl,_that.linkText,_that.position);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'mobile_image_url')  String? mobileImageUrl,  String title,  String subtitle, @JsonKey(name: 'link_url')  String linkUrl, @JsonKey(name: 'link_text')  String linkText,  int position)?  $default,) {final _that = this;
switch (_that) {
case _StoreBanner() when $default != null:
return $default(_that.id,_that.imageUrl,_that.mobileImageUrl,_that.title,_that.subtitle,_that.linkUrl,_that.linkText,_that.position);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoreBanner implements StoreBanner {
  const _StoreBanner({required this.id, @JsonKey(name: 'image_url') required this.imageUrl, @JsonKey(name: 'mobile_image_url') this.mobileImageUrl, required this.title, required this.subtitle, @JsonKey(name: 'link_url') required this.linkUrl, @JsonKey(name: 'link_text') required this.linkText, required this.position});
  factory _StoreBanner.fromJson(Map<String, dynamic> json) => _$StoreBannerFromJson(json);

@override final  String id;
@override@JsonKey(name: 'image_url') final  String imageUrl;
@override@JsonKey(name: 'mobile_image_url') final  String? mobileImageUrl;
@override final  String title;
@override final  String subtitle;
@override@JsonKey(name: 'link_url') final  String linkUrl;
@override@JsonKey(name: 'link_text') final  String linkText;
@override final  int position;

/// Create a copy of StoreBanner
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreBannerCopyWith<_StoreBanner> get copyWith => __$StoreBannerCopyWithImpl<_StoreBanner>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreBannerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreBanner&&(identical(other.id, id) || other.id == id)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.mobileImageUrl, mobileImageUrl) || other.mobileImageUrl == mobileImageUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.linkUrl, linkUrl) || other.linkUrl == linkUrl)&&(identical(other.linkText, linkText) || other.linkText == linkText)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,imageUrl,mobileImageUrl,title,subtitle,linkUrl,linkText,position);

@override
String toString() {
  return 'StoreBanner(id: $id, imageUrl: $imageUrl, mobileImageUrl: $mobileImageUrl, title: $title, subtitle: $subtitle, linkUrl: $linkUrl, linkText: $linkText, position: $position)';
}


}

/// @nodoc
abstract mixin class _$StoreBannerCopyWith<$Res> implements $StoreBannerCopyWith<$Res> {
  factory _$StoreBannerCopyWith(_StoreBanner value, $Res Function(_StoreBanner) _then) = __$StoreBannerCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'mobile_image_url') String? mobileImageUrl, String title, String subtitle,@JsonKey(name: 'link_url') String linkUrl,@JsonKey(name: 'link_text') String linkText, int position
});




}
/// @nodoc
class __$StoreBannerCopyWithImpl<$Res>
    implements _$StoreBannerCopyWith<$Res> {
  __$StoreBannerCopyWithImpl(this._self, this._then);

  final _StoreBanner _self;
  final $Res Function(_StoreBanner) _then;

/// Create a copy of StoreBanner
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? imageUrl = null,Object? mobileImageUrl = freezed,Object? title = null,Object? subtitle = null,Object? linkUrl = null,Object? linkText = null,Object? position = null,}) {
  return _then(_StoreBanner(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,mobileImageUrl: freezed == mobileImageUrl ? _self.mobileImageUrl : mobileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,linkUrl: null == linkUrl ? _self.linkUrl : linkUrl // ignore: cast_nullable_to_non_nullable
as String,linkText: null == linkText ? _self.linkText : linkText // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Store {

 String get id; String get name; String get slug; String get description;@JsonKey(name: 'logo_url') String? get logoUrl;@JsonKey(name: 'banner_url') String? get bannerUrl; List<StoreBanner> get banners; String get currency;@JsonKey(name: 'default_affiliate_commission') double get defaultAffiliateCommission;@JsonKey(name: 'total_products') int get totalProducts;@JsonKey(name: 'total_orders') int get totalOrders;@JsonKey(name: 'total_sales') double? get totalSales; double get rating;@JsonKey(name: 'rating_count') int get ratingCount;@JsonKey(name: 'is_premium') bool get isPremium;@JsonKey(name: 'has_brawe_pass') bool get hasBrawePass;@JsonKey(name: 'contact_email') String? get contactEmail;@JsonKey(name: 'contact_whatsapp') String? get contactWhatsapp;@JsonKey(name: 'social_instagram') String? get socialInstagram;@JsonKey(name: 'social_facebook') String? get socialFacebook;@JsonKey(name: 'social_tiktok') String? get socialTiktok; List<String> get categories;@JsonKey(name: 'top_products') List<Product>? get topProducts;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'application_status') ApplicationStatus? get applicationStatus;@JsonKey(name: 'application_id') String? get applicationId;@JsonKey(name: 'application_message') String? get applicationMessage;@JsonKey(name: 'store_response') String? get storeResponse;
/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreCopyWith<Store> get copyWith => _$StoreCopyWithImpl<Store>(this as Store, _$identity);

  /// Serializes this Store to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Store&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&const DeepCollectionEquality().equals(other.banners, banners)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.defaultAffiliateCommission, defaultAffiliateCommission) || other.defaultAffiliateCommission == defaultAffiliateCommission)&&(identical(other.totalProducts, totalProducts) || other.totalProducts == totalProducts)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders)&&(identical(other.totalSales, totalSales) || other.totalSales == totalSales)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.hasBrawePass, hasBrawePass) || other.hasBrawePass == hasBrawePass)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.contactWhatsapp, contactWhatsapp) || other.contactWhatsapp == contactWhatsapp)&&(identical(other.socialInstagram, socialInstagram) || other.socialInstagram == socialInstagram)&&(identical(other.socialFacebook, socialFacebook) || other.socialFacebook == socialFacebook)&&(identical(other.socialTiktok, socialTiktok) || other.socialTiktok == socialTiktok)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.topProducts, topProducts)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.applicationStatus, applicationStatus) || other.applicationStatus == applicationStatus)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.applicationMessage, applicationMessage) || other.applicationMessage == applicationMessage)&&(identical(other.storeResponse, storeResponse) || other.storeResponse == storeResponse));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,slug,description,logoUrl,bannerUrl,const DeepCollectionEquality().hash(banners),currency,defaultAffiliateCommission,totalProducts,totalOrders,totalSales,rating,ratingCount,isPremium,hasBrawePass,contactEmail,contactWhatsapp,socialInstagram,socialFacebook,socialTiktok,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(topProducts),createdAt,applicationStatus,applicationId,applicationMessage,storeResponse]);

@override
String toString() {
  return 'Store(id: $id, name: $name, slug: $slug, description: $description, logoUrl: $logoUrl, bannerUrl: $bannerUrl, banners: $banners, currency: $currency, defaultAffiliateCommission: $defaultAffiliateCommission, totalProducts: $totalProducts, totalOrders: $totalOrders, totalSales: $totalSales, rating: $rating, ratingCount: $ratingCount, isPremium: $isPremium, hasBrawePass: $hasBrawePass, contactEmail: $contactEmail, contactWhatsapp: $contactWhatsapp, socialInstagram: $socialInstagram, socialFacebook: $socialFacebook, socialTiktok: $socialTiktok, categories: $categories, topProducts: $topProducts, createdAt: $createdAt, applicationStatus: $applicationStatus, applicationId: $applicationId, applicationMessage: $applicationMessage, storeResponse: $storeResponse)';
}


}

/// @nodoc
abstract mixin class $StoreCopyWith<$Res>  {
  factory $StoreCopyWith(Store value, $Res Function(Store) _then) = _$StoreCopyWithImpl;
@useResult
$Res call({
 String id, String name, String slug, String description,@JsonKey(name: 'logo_url') String? logoUrl,@JsonKey(name: 'banner_url') String? bannerUrl, List<StoreBanner> banners, String currency,@JsonKey(name: 'default_affiliate_commission') double defaultAffiliateCommission,@JsonKey(name: 'total_products') int totalProducts,@JsonKey(name: 'total_orders') int totalOrders,@JsonKey(name: 'total_sales') double? totalSales, double rating,@JsonKey(name: 'rating_count') int ratingCount,@JsonKey(name: 'is_premium') bool isPremium,@JsonKey(name: 'has_brawe_pass') bool hasBrawePass,@JsonKey(name: 'contact_email') String? contactEmail,@JsonKey(name: 'contact_whatsapp') String? contactWhatsapp,@JsonKey(name: 'social_instagram') String? socialInstagram,@JsonKey(name: 'social_facebook') String? socialFacebook,@JsonKey(name: 'social_tiktok') String? socialTiktok, List<String> categories,@JsonKey(name: 'top_products') List<Product>? topProducts,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'application_status') ApplicationStatus? applicationStatus,@JsonKey(name: 'application_id') String? applicationId,@JsonKey(name: 'application_message') String? applicationMessage,@JsonKey(name: 'store_response') String? storeResponse
});




}
/// @nodoc
class _$StoreCopyWithImpl<$Res>
    implements $StoreCopyWith<$Res> {
  _$StoreCopyWithImpl(this._self, this._then);

  final Store _self;
  final $Res Function(Store) _then;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? description = null,Object? logoUrl = freezed,Object? bannerUrl = freezed,Object? banners = null,Object? currency = null,Object? defaultAffiliateCommission = null,Object? totalProducts = null,Object? totalOrders = null,Object? totalSales = freezed,Object? rating = null,Object? ratingCount = null,Object? isPremium = null,Object? hasBrawePass = null,Object? contactEmail = freezed,Object? contactWhatsapp = freezed,Object? socialInstagram = freezed,Object? socialFacebook = freezed,Object? socialTiktok = freezed,Object? categories = null,Object? topProducts = freezed,Object? createdAt = null,Object? applicationStatus = freezed,Object? applicationId = freezed,Object? applicationMessage = freezed,Object? storeResponse = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,banners: null == banners ? _self.banners : banners // ignore: cast_nullable_to_non_nullable
as List<StoreBanner>,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,defaultAffiliateCommission: null == defaultAffiliateCommission ? _self.defaultAffiliateCommission : defaultAffiliateCommission // ignore: cast_nullable_to_non_nullable
as double,totalProducts: null == totalProducts ? _self.totalProducts : totalProducts // ignore: cast_nullable_to_non_nullable
as int,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,totalSales: freezed == totalSales ? _self.totalSales : totalSales // ignore: cast_nullable_to_non_nullable
as double?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,hasBrawePass: null == hasBrawePass ? _self.hasBrawePass : hasBrawePass // ignore: cast_nullable_to_non_nullable
as bool,contactEmail: freezed == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String?,contactWhatsapp: freezed == contactWhatsapp ? _self.contactWhatsapp : contactWhatsapp // ignore: cast_nullable_to_non_nullable
as String?,socialInstagram: freezed == socialInstagram ? _self.socialInstagram : socialInstagram // ignore: cast_nullable_to_non_nullable
as String?,socialFacebook: freezed == socialFacebook ? _self.socialFacebook : socialFacebook // ignore: cast_nullable_to_non_nullable
as String?,socialTiktok: freezed == socialTiktok ? _self.socialTiktok : socialTiktok // ignore: cast_nullable_to_non_nullable
as String?,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,topProducts: freezed == topProducts ? _self.topProducts : topProducts // ignore: cast_nullable_to_non_nullable
as List<Product>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,applicationStatus: freezed == applicationStatus ? _self.applicationStatus : applicationStatus // ignore: cast_nullable_to_non_nullable
as ApplicationStatus?,applicationId: freezed == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String?,applicationMessage: freezed == applicationMessage ? _self.applicationMessage : applicationMessage // ignore: cast_nullable_to_non_nullable
as String?,storeResponse: freezed == storeResponse ? _self.storeResponse : storeResponse // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Store].
extension StorePatterns on Store {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Store value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Store value)  $default,){
final _that = this;
switch (_that) {
case _Store():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Store value)?  $default,){
final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String description, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'banner_url')  String? bannerUrl,  List<StoreBanner> banners,  String currency, @JsonKey(name: 'default_affiliate_commission')  double defaultAffiliateCommission, @JsonKey(name: 'total_products')  int totalProducts, @JsonKey(name: 'total_orders')  int totalOrders, @JsonKey(name: 'total_sales')  double? totalSales,  double rating, @JsonKey(name: 'rating_count')  int ratingCount, @JsonKey(name: 'is_premium')  bool isPremium, @JsonKey(name: 'has_brawe_pass')  bool hasBrawePass, @JsonKey(name: 'contact_email')  String? contactEmail, @JsonKey(name: 'contact_whatsapp')  String? contactWhatsapp, @JsonKey(name: 'social_instagram')  String? socialInstagram, @JsonKey(name: 'social_facebook')  String? socialFacebook, @JsonKey(name: 'social_tiktok')  String? socialTiktok,  List<String> categories, @JsonKey(name: 'top_products')  List<Product>? topProducts, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'application_status')  ApplicationStatus? applicationStatus, @JsonKey(name: 'application_id')  String? applicationId, @JsonKey(name: 'application_message')  String? applicationMessage, @JsonKey(name: 'store_response')  String? storeResponse)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.description,_that.logoUrl,_that.bannerUrl,_that.banners,_that.currency,_that.defaultAffiliateCommission,_that.totalProducts,_that.totalOrders,_that.totalSales,_that.rating,_that.ratingCount,_that.isPremium,_that.hasBrawePass,_that.contactEmail,_that.contactWhatsapp,_that.socialInstagram,_that.socialFacebook,_that.socialTiktok,_that.categories,_that.topProducts,_that.createdAt,_that.applicationStatus,_that.applicationId,_that.applicationMessage,_that.storeResponse);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String description, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'banner_url')  String? bannerUrl,  List<StoreBanner> banners,  String currency, @JsonKey(name: 'default_affiliate_commission')  double defaultAffiliateCommission, @JsonKey(name: 'total_products')  int totalProducts, @JsonKey(name: 'total_orders')  int totalOrders, @JsonKey(name: 'total_sales')  double? totalSales,  double rating, @JsonKey(name: 'rating_count')  int ratingCount, @JsonKey(name: 'is_premium')  bool isPremium, @JsonKey(name: 'has_brawe_pass')  bool hasBrawePass, @JsonKey(name: 'contact_email')  String? contactEmail, @JsonKey(name: 'contact_whatsapp')  String? contactWhatsapp, @JsonKey(name: 'social_instagram')  String? socialInstagram, @JsonKey(name: 'social_facebook')  String? socialFacebook, @JsonKey(name: 'social_tiktok')  String? socialTiktok,  List<String> categories, @JsonKey(name: 'top_products')  List<Product>? topProducts, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'application_status')  ApplicationStatus? applicationStatus, @JsonKey(name: 'application_id')  String? applicationId, @JsonKey(name: 'application_message')  String? applicationMessage, @JsonKey(name: 'store_response')  String? storeResponse)  $default,) {final _that = this;
switch (_that) {
case _Store():
return $default(_that.id,_that.name,_that.slug,_that.description,_that.logoUrl,_that.bannerUrl,_that.banners,_that.currency,_that.defaultAffiliateCommission,_that.totalProducts,_that.totalOrders,_that.totalSales,_that.rating,_that.ratingCount,_that.isPremium,_that.hasBrawePass,_that.contactEmail,_that.contactWhatsapp,_that.socialInstagram,_that.socialFacebook,_that.socialTiktok,_that.categories,_that.topProducts,_that.createdAt,_that.applicationStatus,_that.applicationId,_that.applicationMessage,_that.storeResponse);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String slug,  String description, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'banner_url')  String? bannerUrl,  List<StoreBanner> banners,  String currency, @JsonKey(name: 'default_affiliate_commission')  double defaultAffiliateCommission, @JsonKey(name: 'total_products')  int totalProducts, @JsonKey(name: 'total_orders')  int totalOrders, @JsonKey(name: 'total_sales')  double? totalSales,  double rating, @JsonKey(name: 'rating_count')  int ratingCount, @JsonKey(name: 'is_premium')  bool isPremium, @JsonKey(name: 'has_brawe_pass')  bool hasBrawePass, @JsonKey(name: 'contact_email')  String? contactEmail, @JsonKey(name: 'contact_whatsapp')  String? contactWhatsapp, @JsonKey(name: 'social_instagram')  String? socialInstagram, @JsonKey(name: 'social_facebook')  String? socialFacebook, @JsonKey(name: 'social_tiktok')  String? socialTiktok,  List<String> categories, @JsonKey(name: 'top_products')  List<Product>? topProducts, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'application_status')  ApplicationStatus? applicationStatus, @JsonKey(name: 'application_id')  String? applicationId, @JsonKey(name: 'application_message')  String? applicationMessage, @JsonKey(name: 'store_response')  String? storeResponse)?  $default,) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.description,_that.logoUrl,_that.bannerUrl,_that.banners,_that.currency,_that.defaultAffiliateCommission,_that.totalProducts,_that.totalOrders,_that.totalSales,_that.rating,_that.ratingCount,_that.isPremium,_that.hasBrawePass,_that.contactEmail,_that.contactWhatsapp,_that.socialInstagram,_that.socialFacebook,_that.socialTiktok,_that.categories,_that.topProducts,_that.createdAt,_that.applicationStatus,_that.applicationId,_that.applicationMessage,_that.storeResponse);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Store implements Store {
  const _Store({required this.id, required this.name, required this.slug, required this.description, @JsonKey(name: 'logo_url') this.logoUrl, @JsonKey(name: 'banner_url') this.bannerUrl, required final  List<StoreBanner> banners, required this.currency, @JsonKey(name: 'default_affiliate_commission') required this.defaultAffiliateCommission, @JsonKey(name: 'total_products') required this.totalProducts, @JsonKey(name: 'total_orders') required this.totalOrders, @JsonKey(name: 'total_sales') this.totalSales, required this.rating, @JsonKey(name: 'rating_count') required this.ratingCount, @JsonKey(name: 'is_premium') required this.isPremium, @JsonKey(name: 'has_brawe_pass') required this.hasBrawePass, @JsonKey(name: 'contact_email') this.contactEmail, @JsonKey(name: 'contact_whatsapp') this.contactWhatsapp, @JsonKey(name: 'social_instagram') this.socialInstagram, @JsonKey(name: 'social_facebook') this.socialFacebook, @JsonKey(name: 'social_tiktok') this.socialTiktok, required final  List<String> categories, @JsonKey(name: 'top_products') final  List<Product>? topProducts, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'application_status') this.applicationStatus, @JsonKey(name: 'application_id') this.applicationId, @JsonKey(name: 'application_message') this.applicationMessage, @JsonKey(name: 'store_response') this.storeResponse}): _banners = banners,_categories = categories,_topProducts = topProducts;
  factory _Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

@override final  String id;
@override final  String name;
@override final  String slug;
@override final  String description;
@override@JsonKey(name: 'logo_url') final  String? logoUrl;
@override@JsonKey(name: 'banner_url') final  String? bannerUrl;
 final  List<StoreBanner> _banners;
@override List<StoreBanner> get banners {
  if (_banners is EqualUnmodifiableListView) return _banners;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_banners);
}

@override final  String currency;
@override@JsonKey(name: 'default_affiliate_commission') final  double defaultAffiliateCommission;
@override@JsonKey(name: 'total_products') final  int totalProducts;
@override@JsonKey(name: 'total_orders') final  int totalOrders;
@override@JsonKey(name: 'total_sales') final  double? totalSales;
@override final  double rating;
@override@JsonKey(name: 'rating_count') final  int ratingCount;
@override@JsonKey(name: 'is_premium') final  bool isPremium;
@override@JsonKey(name: 'has_brawe_pass') final  bool hasBrawePass;
@override@JsonKey(name: 'contact_email') final  String? contactEmail;
@override@JsonKey(name: 'contact_whatsapp') final  String? contactWhatsapp;
@override@JsonKey(name: 'social_instagram') final  String? socialInstagram;
@override@JsonKey(name: 'social_facebook') final  String? socialFacebook;
@override@JsonKey(name: 'social_tiktok') final  String? socialTiktok;
 final  List<String> _categories;
@override List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<Product>? _topProducts;
@override@JsonKey(name: 'top_products') List<Product>? get topProducts {
  final value = _topProducts;
  if (value == null) return null;
  if (_topProducts is EqualUnmodifiableListView) return _topProducts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'application_status') final  ApplicationStatus? applicationStatus;
@override@JsonKey(name: 'application_id') final  String? applicationId;
@override@JsonKey(name: 'application_message') final  String? applicationMessage;
@override@JsonKey(name: 'store_response') final  String? storeResponse;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreCopyWith<_Store> get copyWith => __$StoreCopyWithImpl<_Store>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Store&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&const DeepCollectionEquality().equals(other._banners, _banners)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.defaultAffiliateCommission, defaultAffiliateCommission) || other.defaultAffiliateCommission == defaultAffiliateCommission)&&(identical(other.totalProducts, totalProducts) || other.totalProducts == totalProducts)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders)&&(identical(other.totalSales, totalSales) || other.totalSales == totalSales)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.hasBrawePass, hasBrawePass) || other.hasBrawePass == hasBrawePass)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.contactWhatsapp, contactWhatsapp) || other.contactWhatsapp == contactWhatsapp)&&(identical(other.socialInstagram, socialInstagram) || other.socialInstagram == socialInstagram)&&(identical(other.socialFacebook, socialFacebook) || other.socialFacebook == socialFacebook)&&(identical(other.socialTiktok, socialTiktok) || other.socialTiktok == socialTiktok)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._topProducts, _topProducts)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.applicationStatus, applicationStatus) || other.applicationStatus == applicationStatus)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.applicationMessage, applicationMessage) || other.applicationMessage == applicationMessage)&&(identical(other.storeResponse, storeResponse) || other.storeResponse == storeResponse));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,slug,description,logoUrl,bannerUrl,const DeepCollectionEquality().hash(_banners),currency,defaultAffiliateCommission,totalProducts,totalOrders,totalSales,rating,ratingCount,isPremium,hasBrawePass,contactEmail,contactWhatsapp,socialInstagram,socialFacebook,socialTiktok,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_topProducts),createdAt,applicationStatus,applicationId,applicationMessage,storeResponse]);

@override
String toString() {
  return 'Store(id: $id, name: $name, slug: $slug, description: $description, logoUrl: $logoUrl, bannerUrl: $bannerUrl, banners: $banners, currency: $currency, defaultAffiliateCommission: $defaultAffiliateCommission, totalProducts: $totalProducts, totalOrders: $totalOrders, totalSales: $totalSales, rating: $rating, ratingCount: $ratingCount, isPremium: $isPremium, hasBrawePass: $hasBrawePass, contactEmail: $contactEmail, contactWhatsapp: $contactWhatsapp, socialInstagram: $socialInstagram, socialFacebook: $socialFacebook, socialTiktok: $socialTiktok, categories: $categories, topProducts: $topProducts, createdAt: $createdAt, applicationStatus: $applicationStatus, applicationId: $applicationId, applicationMessage: $applicationMessage, storeResponse: $storeResponse)';
}


}

/// @nodoc
abstract mixin class _$StoreCopyWith<$Res> implements $StoreCopyWith<$Res> {
  factory _$StoreCopyWith(_Store value, $Res Function(_Store) _then) = __$StoreCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String slug, String description,@JsonKey(name: 'logo_url') String? logoUrl,@JsonKey(name: 'banner_url') String? bannerUrl, List<StoreBanner> banners, String currency,@JsonKey(name: 'default_affiliate_commission') double defaultAffiliateCommission,@JsonKey(name: 'total_products') int totalProducts,@JsonKey(name: 'total_orders') int totalOrders,@JsonKey(name: 'total_sales') double? totalSales, double rating,@JsonKey(name: 'rating_count') int ratingCount,@JsonKey(name: 'is_premium') bool isPremium,@JsonKey(name: 'has_brawe_pass') bool hasBrawePass,@JsonKey(name: 'contact_email') String? contactEmail,@JsonKey(name: 'contact_whatsapp') String? contactWhatsapp,@JsonKey(name: 'social_instagram') String? socialInstagram,@JsonKey(name: 'social_facebook') String? socialFacebook,@JsonKey(name: 'social_tiktok') String? socialTiktok, List<String> categories,@JsonKey(name: 'top_products') List<Product>? topProducts,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'application_status') ApplicationStatus? applicationStatus,@JsonKey(name: 'application_id') String? applicationId,@JsonKey(name: 'application_message') String? applicationMessage,@JsonKey(name: 'store_response') String? storeResponse
});




}
/// @nodoc
class __$StoreCopyWithImpl<$Res>
    implements _$StoreCopyWith<$Res> {
  __$StoreCopyWithImpl(this._self, this._then);

  final _Store _self;
  final $Res Function(_Store) _then;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? description = null,Object? logoUrl = freezed,Object? bannerUrl = freezed,Object? banners = null,Object? currency = null,Object? defaultAffiliateCommission = null,Object? totalProducts = null,Object? totalOrders = null,Object? totalSales = freezed,Object? rating = null,Object? ratingCount = null,Object? isPremium = null,Object? hasBrawePass = null,Object? contactEmail = freezed,Object? contactWhatsapp = freezed,Object? socialInstagram = freezed,Object? socialFacebook = freezed,Object? socialTiktok = freezed,Object? categories = null,Object? topProducts = freezed,Object? createdAt = null,Object? applicationStatus = freezed,Object? applicationId = freezed,Object? applicationMessage = freezed,Object? storeResponse = freezed,}) {
  return _then(_Store(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,banners: null == banners ? _self._banners : banners // ignore: cast_nullable_to_non_nullable
as List<StoreBanner>,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,defaultAffiliateCommission: null == defaultAffiliateCommission ? _self.defaultAffiliateCommission : defaultAffiliateCommission // ignore: cast_nullable_to_non_nullable
as double,totalProducts: null == totalProducts ? _self.totalProducts : totalProducts // ignore: cast_nullable_to_non_nullable
as int,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,totalSales: freezed == totalSales ? _self.totalSales : totalSales // ignore: cast_nullable_to_non_nullable
as double?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,hasBrawePass: null == hasBrawePass ? _self.hasBrawePass : hasBrawePass // ignore: cast_nullable_to_non_nullable
as bool,contactEmail: freezed == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String?,contactWhatsapp: freezed == contactWhatsapp ? _self.contactWhatsapp : contactWhatsapp // ignore: cast_nullable_to_non_nullable
as String?,socialInstagram: freezed == socialInstagram ? _self.socialInstagram : socialInstagram // ignore: cast_nullable_to_non_nullable
as String?,socialFacebook: freezed == socialFacebook ? _self.socialFacebook : socialFacebook // ignore: cast_nullable_to_non_nullable
as String?,socialTiktok: freezed == socialTiktok ? _self.socialTiktok : socialTiktok // ignore: cast_nullable_to_non_nullable
as String?,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,topProducts: freezed == topProducts ? _self._topProducts : topProducts // ignore: cast_nullable_to_non_nullable
as List<Product>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,applicationStatus: freezed == applicationStatus ? _self.applicationStatus : applicationStatus // ignore: cast_nullable_to_non_nullable
as ApplicationStatus?,applicationId: freezed == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String?,applicationMessage: freezed == applicationMessage ? _self.applicationMessage : applicationMessage // ignore: cast_nullable_to_non_nullable
as String?,storeResponse: freezed == storeResponse ? _self.storeResponse : storeResponse // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AffiliateApplication {

 String get id;@JsonKey(name: 'store_id') String get storeId;@JsonKey(name: 'store_name') String get storeName;@JsonKey(name: 'store_logo') String? get storeLogo; ApplicationStatus get status; String get message;@JsonKey(name: 'store_response') String? get storeResponse;@JsonKey(name: 'custom_commission') double? get customCommission;@JsonKey(name: 'sample_requested') bool get sampleRequested;@JsonKey(name: 'sample_product_ids') List<String> get sampleProductIds;@JsonKey(name: 'sample_products') List<Map<String, dynamic>> get sampleProducts;@JsonKey(name: 'sample_sent') bool get sampleSent;@JsonKey(name: 'sample_sent_at') String? get sampleSentAt;@JsonKey(name: 'sample_tracking_code') String? get sampleTrackingCode;@JsonKey(name: 'removal_requested') bool get removalRequested;@JsonKey(name: 'removal_requested_at') String? get removalRequestedAt;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'reviewed_at') String? get reviewedAt;
/// Create a copy of AffiliateApplication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AffiliateApplicationCopyWith<AffiliateApplication> get copyWith => _$AffiliateApplicationCopyWithImpl<AffiliateApplication>(this as AffiliateApplication, _$identity);

  /// Serializes this AffiliateApplication to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AffiliateApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.storeLogo, storeLogo) || other.storeLogo == storeLogo)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.storeResponse, storeResponse) || other.storeResponse == storeResponse)&&(identical(other.customCommission, customCommission) || other.customCommission == customCommission)&&(identical(other.sampleRequested, sampleRequested) || other.sampleRequested == sampleRequested)&&const DeepCollectionEquality().equals(other.sampleProductIds, sampleProductIds)&&const DeepCollectionEquality().equals(other.sampleProducts, sampleProducts)&&(identical(other.sampleSent, sampleSent) || other.sampleSent == sampleSent)&&(identical(other.sampleSentAt, sampleSentAt) || other.sampleSentAt == sampleSentAt)&&(identical(other.sampleTrackingCode, sampleTrackingCode) || other.sampleTrackingCode == sampleTrackingCode)&&(identical(other.removalRequested, removalRequested) || other.removalRequested == removalRequested)&&(identical(other.removalRequestedAt, removalRequestedAt) || other.removalRequestedAt == removalRequestedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,storeName,storeLogo,status,message,storeResponse,customCommission,sampleRequested,const DeepCollectionEquality().hash(sampleProductIds),const DeepCollectionEquality().hash(sampleProducts),sampleSent,sampleSentAt,sampleTrackingCode,removalRequested,removalRequestedAt,createdAt,reviewedAt);

@override
String toString() {
  return 'AffiliateApplication(id: $id, storeId: $storeId, storeName: $storeName, storeLogo: $storeLogo, status: $status, message: $message, storeResponse: $storeResponse, customCommission: $customCommission, sampleRequested: $sampleRequested, sampleProductIds: $sampleProductIds, sampleProducts: $sampleProducts, sampleSent: $sampleSent, sampleSentAt: $sampleSentAt, sampleTrackingCode: $sampleTrackingCode, removalRequested: $removalRequested, removalRequestedAt: $removalRequestedAt, createdAt: $createdAt, reviewedAt: $reviewedAt)';
}


}

/// @nodoc
abstract mixin class $AffiliateApplicationCopyWith<$Res>  {
  factory $AffiliateApplicationCopyWith(AffiliateApplication value, $Res Function(AffiliateApplication) _then) = _$AffiliateApplicationCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'store_id') String storeId,@JsonKey(name: 'store_name') String storeName,@JsonKey(name: 'store_logo') String? storeLogo, ApplicationStatus status, String message,@JsonKey(name: 'store_response') String? storeResponse,@JsonKey(name: 'custom_commission') double? customCommission,@JsonKey(name: 'sample_requested') bool sampleRequested,@JsonKey(name: 'sample_product_ids') List<String> sampleProductIds,@JsonKey(name: 'sample_products') List<Map<String, dynamic>> sampleProducts,@JsonKey(name: 'sample_sent') bool sampleSent,@JsonKey(name: 'sample_sent_at') String? sampleSentAt,@JsonKey(name: 'sample_tracking_code') String? sampleTrackingCode,@JsonKey(name: 'removal_requested') bool removalRequested,@JsonKey(name: 'removal_requested_at') String? removalRequestedAt,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'reviewed_at') String? reviewedAt
});




}
/// @nodoc
class _$AffiliateApplicationCopyWithImpl<$Res>
    implements $AffiliateApplicationCopyWith<$Res> {
  _$AffiliateApplicationCopyWithImpl(this._self, this._then);

  final AffiliateApplication _self;
  final $Res Function(AffiliateApplication) _then;

/// Create a copy of AffiliateApplication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = null,Object? storeName = null,Object? storeLogo = freezed,Object? status = null,Object? message = null,Object? storeResponse = freezed,Object? customCommission = freezed,Object? sampleRequested = null,Object? sampleProductIds = null,Object? sampleProducts = null,Object? sampleSent = null,Object? sampleSentAt = freezed,Object? sampleTrackingCode = freezed,Object? removalRequested = null,Object? removalRequestedAt = freezed,Object? createdAt = null,Object? reviewedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,storeLogo: freezed == storeLogo ? _self.storeLogo : storeLogo // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ApplicationStatus,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,storeResponse: freezed == storeResponse ? _self.storeResponse : storeResponse // ignore: cast_nullable_to_non_nullable
as String?,customCommission: freezed == customCommission ? _self.customCommission : customCommission // ignore: cast_nullable_to_non_nullable
as double?,sampleRequested: null == sampleRequested ? _self.sampleRequested : sampleRequested // ignore: cast_nullable_to_non_nullable
as bool,sampleProductIds: null == sampleProductIds ? _self.sampleProductIds : sampleProductIds // ignore: cast_nullable_to_non_nullable
as List<String>,sampleProducts: null == sampleProducts ? _self.sampleProducts : sampleProducts // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,sampleSent: null == sampleSent ? _self.sampleSent : sampleSent // ignore: cast_nullable_to_non_nullable
as bool,sampleSentAt: freezed == sampleSentAt ? _self.sampleSentAt : sampleSentAt // ignore: cast_nullable_to_non_nullable
as String?,sampleTrackingCode: freezed == sampleTrackingCode ? _self.sampleTrackingCode : sampleTrackingCode // ignore: cast_nullable_to_non_nullable
as String?,removalRequested: null == removalRequested ? _self.removalRequested : removalRequested // ignore: cast_nullable_to_non_nullable
as bool,removalRequestedAt: freezed == removalRequestedAt ? _self.removalRequestedAt : removalRequestedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AffiliateApplication].
extension AffiliateApplicationPatterns on AffiliateApplication {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AffiliateApplication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AffiliateApplication() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AffiliateApplication value)  $default,){
final _that = this;
switch (_that) {
case _AffiliateApplication():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AffiliateApplication value)?  $default,){
final _that = this;
switch (_that) {
case _AffiliateApplication() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'store_id')  String storeId, @JsonKey(name: 'store_name')  String storeName, @JsonKey(name: 'store_logo')  String? storeLogo,  ApplicationStatus status,  String message, @JsonKey(name: 'store_response')  String? storeResponse, @JsonKey(name: 'custom_commission')  double? customCommission, @JsonKey(name: 'sample_requested')  bool sampleRequested, @JsonKey(name: 'sample_product_ids')  List<String> sampleProductIds, @JsonKey(name: 'sample_products')  List<Map<String, dynamic>> sampleProducts, @JsonKey(name: 'sample_sent')  bool sampleSent, @JsonKey(name: 'sample_sent_at')  String? sampleSentAt, @JsonKey(name: 'sample_tracking_code')  String? sampleTrackingCode, @JsonKey(name: 'removal_requested')  bool removalRequested, @JsonKey(name: 'removal_requested_at')  String? removalRequestedAt, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'reviewed_at')  String? reviewedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AffiliateApplication() when $default != null:
return $default(_that.id,_that.storeId,_that.storeName,_that.storeLogo,_that.status,_that.message,_that.storeResponse,_that.customCommission,_that.sampleRequested,_that.sampleProductIds,_that.sampleProducts,_that.sampleSent,_that.sampleSentAt,_that.sampleTrackingCode,_that.removalRequested,_that.removalRequestedAt,_that.createdAt,_that.reviewedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'store_id')  String storeId, @JsonKey(name: 'store_name')  String storeName, @JsonKey(name: 'store_logo')  String? storeLogo,  ApplicationStatus status,  String message, @JsonKey(name: 'store_response')  String? storeResponse, @JsonKey(name: 'custom_commission')  double? customCommission, @JsonKey(name: 'sample_requested')  bool sampleRequested, @JsonKey(name: 'sample_product_ids')  List<String> sampleProductIds, @JsonKey(name: 'sample_products')  List<Map<String, dynamic>> sampleProducts, @JsonKey(name: 'sample_sent')  bool sampleSent, @JsonKey(name: 'sample_sent_at')  String? sampleSentAt, @JsonKey(name: 'sample_tracking_code')  String? sampleTrackingCode, @JsonKey(name: 'removal_requested')  bool removalRequested, @JsonKey(name: 'removal_requested_at')  String? removalRequestedAt, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'reviewed_at')  String? reviewedAt)  $default,) {final _that = this;
switch (_that) {
case _AffiliateApplication():
return $default(_that.id,_that.storeId,_that.storeName,_that.storeLogo,_that.status,_that.message,_that.storeResponse,_that.customCommission,_that.sampleRequested,_that.sampleProductIds,_that.sampleProducts,_that.sampleSent,_that.sampleSentAt,_that.sampleTrackingCode,_that.removalRequested,_that.removalRequestedAt,_that.createdAt,_that.reviewedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'store_id')  String storeId, @JsonKey(name: 'store_name')  String storeName, @JsonKey(name: 'store_logo')  String? storeLogo,  ApplicationStatus status,  String message, @JsonKey(name: 'store_response')  String? storeResponse, @JsonKey(name: 'custom_commission')  double? customCommission, @JsonKey(name: 'sample_requested')  bool sampleRequested, @JsonKey(name: 'sample_product_ids')  List<String> sampleProductIds, @JsonKey(name: 'sample_products')  List<Map<String, dynamic>> sampleProducts, @JsonKey(name: 'sample_sent')  bool sampleSent, @JsonKey(name: 'sample_sent_at')  String? sampleSentAt, @JsonKey(name: 'sample_tracking_code')  String? sampleTrackingCode, @JsonKey(name: 'removal_requested')  bool removalRequested, @JsonKey(name: 'removal_requested_at')  String? removalRequestedAt, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'reviewed_at')  String? reviewedAt)?  $default,) {final _that = this;
switch (_that) {
case _AffiliateApplication() when $default != null:
return $default(_that.id,_that.storeId,_that.storeName,_that.storeLogo,_that.status,_that.message,_that.storeResponse,_that.customCommission,_that.sampleRequested,_that.sampleProductIds,_that.sampleProducts,_that.sampleSent,_that.sampleSentAt,_that.sampleTrackingCode,_that.removalRequested,_that.removalRequestedAt,_that.createdAt,_that.reviewedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AffiliateApplication implements AffiliateApplication {
  const _AffiliateApplication({required this.id, @JsonKey(name: 'store_id') required this.storeId, @JsonKey(name: 'store_name') required this.storeName, @JsonKey(name: 'store_logo') this.storeLogo, required this.status, required this.message, @JsonKey(name: 'store_response') this.storeResponse, @JsonKey(name: 'custom_commission') this.customCommission, @JsonKey(name: 'sample_requested') required this.sampleRequested, @JsonKey(name: 'sample_product_ids') required final  List<String> sampleProductIds, @JsonKey(name: 'sample_products') required final  List<Map<String, dynamic>> sampleProducts, @JsonKey(name: 'sample_sent') required this.sampleSent, @JsonKey(name: 'sample_sent_at') this.sampleSentAt, @JsonKey(name: 'sample_tracking_code') this.sampleTrackingCode, @JsonKey(name: 'removal_requested') required this.removalRequested, @JsonKey(name: 'removal_requested_at') this.removalRequestedAt, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'reviewed_at') this.reviewedAt}): _sampleProductIds = sampleProductIds,_sampleProducts = sampleProducts;
  factory _AffiliateApplication.fromJson(Map<String, dynamic> json) => _$AffiliateApplicationFromJson(json);

@override final  String id;
@override@JsonKey(name: 'store_id') final  String storeId;
@override@JsonKey(name: 'store_name') final  String storeName;
@override@JsonKey(name: 'store_logo') final  String? storeLogo;
@override final  ApplicationStatus status;
@override final  String message;
@override@JsonKey(name: 'store_response') final  String? storeResponse;
@override@JsonKey(name: 'custom_commission') final  double? customCommission;
@override@JsonKey(name: 'sample_requested') final  bool sampleRequested;
 final  List<String> _sampleProductIds;
@override@JsonKey(name: 'sample_product_ids') List<String> get sampleProductIds {
  if (_sampleProductIds is EqualUnmodifiableListView) return _sampleProductIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sampleProductIds);
}

 final  List<Map<String, dynamic>> _sampleProducts;
@override@JsonKey(name: 'sample_products') List<Map<String, dynamic>> get sampleProducts {
  if (_sampleProducts is EqualUnmodifiableListView) return _sampleProducts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sampleProducts);
}

@override@JsonKey(name: 'sample_sent') final  bool sampleSent;
@override@JsonKey(name: 'sample_sent_at') final  String? sampleSentAt;
@override@JsonKey(name: 'sample_tracking_code') final  String? sampleTrackingCode;
@override@JsonKey(name: 'removal_requested') final  bool removalRequested;
@override@JsonKey(name: 'removal_requested_at') final  String? removalRequestedAt;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'reviewed_at') final  String? reviewedAt;

/// Create a copy of AffiliateApplication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AffiliateApplicationCopyWith<_AffiliateApplication> get copyWith => __$AffiliateApplicationCopyWithImpl<_AffiliateApplication>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AffiliateApplicationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AffiliateApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.storeLogo, storeLogo) || other.storeLogo == storeLogo)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message)&&(identical(other.storeResponse, storeResponse) || other.storeResponse == storeResponse)&&(identical(other.customCommission, customCommission) || other.customCommission == customCommission)&&(identical(other.sampleRequested, sampleRequested) || other.sampleRequested == sampleRequested)&&const DeepCollectionEquality().equals(other._sampleProductIds, _sampleProductIds)&&const DeepCollectionEquality().equals(other._sampleProducts, _sampleProducts)&&(identical(other.sampleSent, sampleSent) || other.sampleSent == sampleSent)&&(identical(other.sampleSentAt, sampleSentAt) || other.sampleSentAt == sampleSentAt)&&(identical(other.sampleTrackingCode, sampleTrackingCode) || other.sampleTrackingCode == sampleTrackingCode)&&(identical(other.removalRequested, removalRequested) || other.removalRequested == removalRequested)&&(identical(other.removalRequestedAt, removalRequestedAt) || other.removalRequestedAt == removalRequestedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,storeName,storeLogo,status,message,storeResponse,customCommission,sampleRequested,const DeepCollectionEquality().hash(_sampleProductIds),const DeepCollectionEquality().hash(_sampleProducts),sampleSent,sampleSentAt,sampleTrackingCode,removalRequested,removalRequestedAt,createdAt,reviewedAt);

@override
String toString() {
  return 'AffiliateApplication(id: $id, storeId: $storeId, storeName: $storeName, storeLogo: $storeLogo, status: $status, message: $message, storeResponse: $storeResponse, customCommission: $customCommission, sampleRequested: $sampleRequested, sampleProductIds: $sampleProductIds, sampleProducts: $sampleProducts, sampleSent: $sampleSent, sampleSentAt: $sampleSentAt, sampleTrackingCode: $sampleTrackingCode, removalRequested: $removalRequested, removalRequestedAt: $removalRequestedAt, createdAt: $createdAt, reviewedAt: $reviewedAt)';
}


}

/// @nodoc
abstract mixin class _$AffiliateApplicationCopyWith<$Res> implements $AffiliateApplicationCopyWith<$Res> {
  factory _$AffiliateApplicationCopyWith(_AffiliateApplication value, $Res Function(_AffiliateApplication) _then) = __$AffiliateApplicationCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'store_id') String storeId,@JsonKey(name: 'store_name') String storeName,@JsonKey(name: 'store_logo') String? storeLogo, ApplicationStatus status, String message,@JsonKey(name: 'store_response') String? storeResponse,@JsonKey(name: 'custom_commission') double? customCommission,@JsonKey(name: 'sample_requested') bool sampleRequested,@JsonKey(name: 'sample_product_ids') List<String> sampleProductIds,@JsonKey(name: 'sample_products') List<Map<String, dynamic>> sampleProducts,@JsonKey(name: 'sample_sent') bool sampleSent,@JsonKey(name: 'sample_sent_at') String? sampleSentAt,@JsonKey(name: 'sample_tracking_code') String? sampleTrackingCode,@JsonKey(name: 'removal_requested') bool removalRequested,@JsonKey(name: 'removal_requested_at') String? removalRequestedAt,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'reviewed_at') String? reviewedAt
});




}
/// @nodoc
class __$AffiliateApplicationCopyWithImpl<$Res>
    implements _$AffiliateApplicationCopyWith<$Res> {
  __$AffiliateApplicationCopyWithImpl(this._self, this._then);

  final _AffiliateApplication _self;
  final $Res Function(_AffiliateApplication) _then;

/// Create a copy of AffiliateApplication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = null,Object? storeName = null,Object? storeLogo = freezed,Object? status = null,Object? message = null,Object? storeResponse = freezed,Object? customCommission = freezed,Object? sampleRequested = null,Object? sampleProductIds = null,Object? sampleProducts = null,Object? sampleSent = null,Object? sampleSentAt = freezed,Object? sampleTrackingCode = freezed,Object? removalRequested = null,Object? removalRequestedAt = freezed,Object? createdAt = null,Object? reviewedAt = freezed,}) {
  return _then(_AffiliateApplication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,storeLogo: freezed == storeLogo ? _self.storeLogo : storeLogo // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ApplicationStatus,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,storeResponse: freezed == storeResponse ? _self.storeResponse : storeResponse // ignore: cast_nullable_to_non_nullable
as String?,customCommission: freezed == customCommission ? _self.customCommission : customCommission // ignore: cast_nullable_to_non_nullable
as double?,sampleRequested: null == sampleRequested ? _self.sampleRequested : sampleRequested // ignore: cast_nullable_to_non_nullable
as bool,sampleProductIds: null == sampleProductIds ? _self._sampleProductIds : sampleProductIds // ignore: cast_nullable_to_non_nullable
as List<String>,sampleProducts: null == sampleProducts ? _self._sampleProducts : sampleProducts // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,sampleSent: null == sampleSent ? _self.sampleSent : sampleSent // ignore: cast_nullable_to_non_nullable
as bool,sampleSentAt: freezed == sampleSentAt ? _self.sampleSentAt : sampleSentAt // ignore: cast_nullable_to_non_nullable
as String?,sampleTrackingCode: freezed == sampleTrackingCode ? _self.sampleTrackingCode : sampleTrackingCode // ignore: cast_nullable_to_non_nullable
as String?,removalRequested: null == removalRequested ? _self.removalRequested : removalRequested // ignore: cast_nullable_to_non_nullable
as bool,removalRequestedAt: freezed == removalRequestedAt ? _self.removalRequestedAt : removalRequestedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Product {

 String get id; String get name;@JsonKey(fromJson: _priceFromJson) double get price;@JsonKey(name: 'compare_at_price', fromJson: _nullablePriceFromJson) double? get compareAtPrice; String? get description;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(fromJson: _imagesFromJson) List<String> get images;@JsonKey(name: 'category_id') String? get categoryId;@JsonKey(name: 'category_name') String? get categoryName; int get quantity; String? get sku; double? get rating;@JsonKey(name: 'rating_count') int get ratingCount;@JsonKey(name: 'total_sold') int get totalSold;@JsonKey(name: 'store_id') String? get storeId;@JsonKey(name: 'store_name') String? get storeName;@JsonKey(name: 'store_slug') String? get storeSlug;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.compareAtPrice, compareAtPrice) || other.compareAtPrice == compareAtPrice)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.totalSold, totalSold) || other.totalSold == totalSold)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.storeSlug, storeSlug) || other.storeSlug == storeSlug)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,compareAtPrice,description,imageUrl,const DeepCollectionEquality().hash(images),categoryId,categoryName,quantity,sku,rating,ratingCount,totalSold,storeId,storeName,storeSlug,createdAt);

@override
String toString() {
  return 'Product(id: $id, name: $name, price: $price, compareAtPrice: $compareAtPrice, description: $description, imageUrl: $imageUrl, images: $images, categoryId: $categoryId, categoryName: $categoryName, quantity: $quantity, sku: $sku, rating: $rating, ratingCount: $ratingCount, totalSold: $totalSold, storeId: $storeId, storeName: $storeName, storeSlug: $storeSlug, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(fromJson: _priceFromJson) double price,@JsonKey(name: 'compare_at_price', fromJson: _nullablePriceFromJson) double? compareAtPrice, String? description,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(fromJson: _imagesFromJson) List<String> images,@JsonKey(name: 'category_id') String? categoryId,@JsonKey(name: 'category_name') String? categoryName, int quantity, String? sku, double? rating,@JsonKey(name: 'rating_count') int ratingCount,@JsonKey(name: 'total_sold') int totalSold,@JsonKey(name: 'store_id') String? storeId,@JsonKey(name: 'store_name') String? storeName,@JsonKey(name: 'store_slug') String? storeSlug,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? price = null,Object? compareAtPrice = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? images = null,Object? categoryId = freezed,Object? categoryName = freezed,Object? quantity = null,Object? sku = freezed,Object? rating = freezed,Object? ratingCount = null,Object? totalSold = null,Object? storeId = freezed,Object? storeName = freezed,Object? storeSlug = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,compareAtPrice: freezed == compareAtPrice ? _self.compareAtPrice : compareAtPrice // ignore: cast_nullable_to_non_nullable
as double?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,totalSold: null == totalSold ? _self.totalSold : totalSold // ignore: cast_nullable_to_non_nullable
as int,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,storeName: freezed == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String?,storeSlug: freezed == storeSlug ? _self.storeSlug : storeSlug // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(fromJson: _priceFromJson)  double price, @JsonKey(name: 'compare_at_price', fromJson: _nullablePriceFromJson)  double? compareAtPrice,  String? description, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(fromJson: _imagesFromJson)  List<String> images, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'category_name')  String? categoryName,  int quantity,  String? sku,  double? rating, @JsonKey(name: 'rating_count')  int ratingCount, @JsonKey(name: 'total_sold')  int totalSold, @JsonKey(name: 'store_id')  String? storeId, @JsonKey(name: 'store_name')  String? storeName, @JsonKey(name: 'store_slug')  String? storeSlug, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.compareAtPrice,_that.description,_that.imageUrl,_that.images,_that.categoryId,_that.categoryName,_that.quantity,_that.sku,_that.rating,_that.ratingCount,_that.totalSold,_that.storeId,_that.storeName,_that.storeSlug,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(fromJson: _priceFromJson)  double price, @JsonKey(name: 'compare_at_price', fromJson: _nullablePriceFromJson)  double? compareAtPrice,  String? description, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(fromJson: _imagesFromJson)  List<String> images, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'category_name')  String? categoryName,  int quantity,  String? sku,  double? rating, @JsonKey(name: 'rating_count')  int ratingCount, @JsonKey(name: 'total_sold')  int totalSold, @JsonKey(name: 'store_id')  String? storeId, @JsonKey(name: 'store_name')  String? storeName, @JsonKey(name: 'store_slug')  String? storeSlug, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.name,_that.price,_that.compareAtPrice,_that.description,_that.imageUrl,_that.images,_that.categoryId,_that.categoryName,_that.quantity,_that.sku,_that.rating,_that.ratingCount,_that.totalSold,_that.storeId,_that.storeName,_that.storeSlug,_that.createdAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(fromJson: _priceFromJson)  double price, @JsonKey(name: 'compare_at_price', fromJson: _nullablePriceFromJson)  double? compareAtPrice,  String? description, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(fromJson: _imagesFromJson)  List<String> images, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'category_name')  String? categoryName,  int quantity,  String? sku,  double? rating, @JsonKey(name: 'rating_count')  int ratingCount, @JsonKey(name: 'total_sold')  int totalSold, @JsonKey(name: 'store_id')  String? storeId, @JsonKey(name: 'store_name')  String? storeName, @JsonKey(name: 'store_slug')  String? storeSlug, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.compareAtPrice,_that.description,_that.imageUrl,_that.images,_that.categoryId,_that.categoryName,_that.quantity,_that.sku,_that.rating,_that.ratingCount,_that.totalSold,_that.storeId,_that.storeName,_that.storeSlug,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product implements Product {
  const _Product({required this.id, required this.name, @JsonKey(fromJson: _priceFromJson) required this.price, @JsonKey(name: 'compare_at_price', fromJson: _nullablePriceFromJson) this.compareAtPrice, this.description, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(fromJson: _imagesFromJson) final  List<String> images = const <String>[], @JsonKey(name: 'category_id') this.categoryId, @JsonKey(name: 'category_name') this.categoryName, required this.quantity, this.sku, this.rating, @JsonKey(name: 'rating_count') this.ratingCount = 0, @JsonKey(name: 'total_sold') this.totalSold = 0, @JsonKey(name: 'store_id') this.storeId, @JsonKey(name: 'store_name') this.storeName, @JsonKey(name: 'store_slug') this.storeSlug, @JsonKey(name: 'created_at') this.createdAt}): _images = images;
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(fromJson: _priceFromJson) final  double price;
@override@JsonKey(name: 'compare_at_price', fromJson: _nullablePriceFromJson) final  double? compareAtPrice;
@override final  String? description;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
 final  List<String> _images;
@override@JsonKey(fromJson: _imagesFromJson) List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override@JsonKey(name: 'category_id') final  String? categoryId;
@override@JsonKey(name: 'category_name') final  String? categoryName;
@override final  int quantity;
@override final  String? sku;
@override final  double? rating;
@override@JsonKey(name: 'rating_count') final  int ratingCount;
@override@JsonKey(name: 'total_sold') final  int totalSold;
@override@JsonKey(name: 'store_id') final  String? storeId;
@override@JsonKey(name: 'store_name') final  String? storeName;
@override@JsonKey(name: 'store_slug') final  String? storeSlug;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.compareAtPrice, compareAtPrice) || other.compareAtPrice == compareAtPrice)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.totalSold, totalSold) || other.totalSold == totalSold)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.storeSlug, storeSlug) || other.storeSlug == storeSlug)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,compareAtPrice,description,imageUrl,const DeepCollectionEquality().hash(_images),categoryId,categoryName,quantity,sku,rating,ratingCount,totalSold,storeId,storeName,storeSlug,createdAt);

@override
String toString() {
  return 'Product(id: $id, name: $name, price: $price, compareAtPrice: $compareAtPrice, description: $description, imageUrl: $imageUrl, images: $images, categoryId: $categoryId, categoryName: $categoryName, quantity: $quantity, sku: $sku, rating: $rating, ratingCount: $ratingCount, totalSold: $totalSold, storeId: $storeId, storeName: $storeName, storeSlug: $storeSlug, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(fromJson: _priceFromJson) double price,@JsonKey(name: 'compare_at_price', fromJson: _nullablePriceFromJson) double? compareAtPrice, String? description,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(fromJson: _imagesFromJson) List<String> images,@JsonKey(name: 'category_id') String? categoryId,@JsonKey(name: 'category_name') String? categoryName, int quantity, String? sku, double? rating,@JsonKey(name: 'rating_count') int ratingCount,@JsonKey(name: 'total_sold') int totalSold,@JsonKey(name: 'store_id') String? storeId,@JsonKey(name: 'store_name') String? storeName,@JsonKey(name: 'store_slug') String? storeSlug,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? price = null,Object? compareAtPrice = freezed,Object? description = freezed,Object? imageUrl = freezed,Object? images = null,Object? categoryId = freezed,Object? categoryName = freezed,Object? quantity = null,Object? sku = freezed,Object? rating = freezed,Object? ratingCount = null,Object? totalSold = null,Object? storeId = freezed,Object? storeName = freezed,Object? storeSlug = freezed,Object? createdAt = freezed,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,compareAtPrice: freezed == compareAtPrice ? _self.compareAtPrice : compareAtPrice // ignore: cast_nullable_to_non_nullable
as double?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,totalSold: null == totalSold ? _self.totalSold : totalSold // ignore: cast_nullable_to_non_nullable
as int,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,storeName: freezed == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String?,storeSlug: freezed == storeSlug ? _self.storeSlug : storeSlug // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ShippingAddress {

 String get street; String get number; String? get complement; String get neighborhood; String get city; String get state; String get country;@JsonKey(name: 'postal_code') String get postalCode; double? get lat; double? get lng;
/// Create a copy of ShippingAddress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShippingAddressCopyWith<ShippingAddress> get copyWith => _$ShippingAddressCopyWithImpl<ShippingAddress>(this as ShippingAddress, _$identity);

  /// Serializes this ShippingAddress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShippingAddress&&(identical(other.street, street) || other.street == street)&&(identical(other.number, number) || other.number == number)&&(identical(other.complement, complement) || other.complement == complement)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.country, country) || other.country == country)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,street,number,complement,neighborhood,city,state,country,postalCode,lat,lng);

@override
String toString() {
  return 'ShippingAddress(street: $street, number: $number, complement: $complement, neighborhood: $neighborhood, city: $city, state: $state, country: $country, postalCode: $postalCode, lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class $ShippingAddressCopyWith<$Res>  {
  factory $ShippingAddressCopyWith(ShippingAddress value, $Res Function(ShippingAddress) _then) = _$ShippingAddressCopyWithImpl;
@useResult
$Res call({
 String street, String number, String? complement, String neighborhood, String city, String state, String country,@JsonKey(name: 'postal_code') String postalCode, double? lat, double? lng
});




}
/// @nodoc
class _$ShippingAddressCopyWithImpl<$Res>
    implements $ShippingAddressCopyWith<$Res> {
  _$ShippingAddressCopyWithImpl(this._self, this._then);

  final ShippingAddress _self;
  final $Res Function(ShippingAddress) _then;

/// Create a copy of ShippingAddress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? street = null,Object? number = null,Object? complement = freezed,Object? neighborhood = null,Object? city = null,Object? state = null,Object? country = null,Object? postalCode = null,Object? lat = freezed,Object? lng = freezed,}) {
  return _then(_self.copyWith(
street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,complement: freezed == complement ? _self.complement : complement // ignore: cast_nullable_to_non_nullable
as String?,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ShippingAddress].
extension ShippingAddressPatterns on ShippingAddress {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShippingAddress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShippingAddress() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShippingAddress value)  $default,){
final _that = this;
switch (_that) {
case _ShippingAddress():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShippingAddress value)?  $default,){
final _that = this;
switch (_that) {
case _ShippingAddress() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String street,  String number,  String? complement,  String neighborhood,  String city,  String state,  String country, @JsonKey(name: 'postal_code')  String postalCode,  double? lat,  double? lng)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShippingAddress() when $default != null:
return $default(_that.street,_that.number,_that.complement,_that.neighborhood,_that.city,_that.state,_that.country,_that.postalCode,_that.lat,_that.lng);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String street,  String number,  String? complement,  String neighborhood,  String city,  String state,  String country, @JsonKey(name: 'postal_code')  String postalCode,  double? lat,  double? lng)  $default,) {final _that = this;
switch (_that) {
case _ShippingAddress():
return $default(_that.street,_that.number,_that.complement,_that.neighborhood,_that.city,_that.state,_that.country,_that.postalCode,_that.lat,_that.lng);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String street,  String number,  String? complement,  String neighborhood,  String city,  String state,  String country, @JsonKey(name: 'postal_code')  String postalCode,  double? lat,  double? lng)?  $default,) {final _that = this;
switch (_that) {
case _ShippingAddress() when $default != null:
return $default(_that.street,_that.number,_that.complement,_that.neighborhood,_that.city,_that.state,_that.country,_that.postalCode,_that.lat,_that.lng);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShippingAddress implements ShippingAddress {
  const _ShippingAddress({required this.street, required this.number, this.complement, required this.neighborhood, required this.city, required this.state, this.country = 'BR', @JsonKey(name: 'postal_code') required this.postalCode, this.lat, this.lng});
  factory _ShippingAddress.fromJson(Map<String, dynamic> json) => _$ShippingAddressFromJson(json);

@override final  String street;
@override final  String number;
@override final  String? complement;
@override final  String neighborhood;
@override final  String city;
@override final  String state;
@override@JsonKey() final  String country;
@override@JsonKey(name: 'postal_code') final  String postalCode;
@override final  double? lat;
@override final  double? lng;

/// Create a copy of ShippingAddress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShippingAddressCopyWith<_ShippingAddress> get copyWith => __$ShippingAddressCopyWithImpl<_ShippingAddress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShippingAddressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShippingAddress&&(identical(other.street, street) || other.street == street)&&(identical(other.number, number) || other.number == number)&&(identical(other.complement, complement) || other.complement == complement)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.country, country) || other.country == country)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,street,number,complement,neighborhood,city,state,country,postalCode,lat,lng);

@override
String toString() {
  return 'ShippingAddress(street: $street, number: $number, complement: $complement, neighborhood: $neighborhood, city: $city, state: $state, country: $country, postalCode: $postalCode, lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class _$ShippingAddressCopyWith<$Res> implements $ShippingAddressCopyWith<$Res> {
  factory _$ShippingAddressCopyWith(_ShippingAddress value, $Res Function(_ShippingAddress) _then) = __$ShippingAddressCopyWithImpl;
@override @useResult
$Res call({
 String street, String number, String? complement, String neighborhood, String city, String state, String country,@JsonKey(name: 'postal_code') String postalCode, double? lat, double? lng
});




}
/// @nodoc
class __$ShippingAddressCopyWithImpl<$Res>
    implements _$ShippingAddressCopyWith<$Res> {
  __$ShippingAddressCopyWithImpl(this._self, this._then);

  final _ShippingAddress _self;
  final $Res Function(_ShippingAddress) _then;

/// Create a copy of ShippingAddress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? street = null,Object? number = null,Object? complement = freezed,Object? neighborhood = null,Object? city = null,Object? state = null,Object? country = null,Object? postalCode = null,Object? lat = freezed,Object? lng = freezed,}) {
  return _then(_ShippingAddress(
street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,complement: freezed == complement ? _self.complement : complement // ignore: cast_nullable_to_non_nullable
as String?,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$CartItem {

 String get id;@JsonKey(name: 'product_id') String get productId;@JsonKey(name: 'variant_id') String? get variantId;@JsonKey(name: 'store_id') String get storeId; int get quantity;@JsonKey(name: 'unit_price') double get unitPrice;@JsonKey(name: 'total_price') double get totalPrice;@JsonKey(name: 'product_name') String get productName;@JsonKey(name: 'product_image') String? get productImage;@JsonKey(name: 'variant_name') String? get variantName;// ⭐ CRÍTICO: campos de comissão do afiliado
@JsonKey(name: 'affiliate_ref_code') String? get affiliateRefCode;@JsonKey(name: 'room_id') String? get roomId;@JsonKey(name: 'comissao_rate') double? get comissaoRate;@JsonKey(name: 'comissao_amount') double? get comissaoAmount;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartItemCopyWith<CartItem> get copyWith => _$CartItemCopyWithImpl<CartItem>(this as CartItem, _$identity);

  /// Serializes this CartItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartItem&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productImage, productImage) || other.productImage == productImage)&&(identical(other.variantName, variantName) || other.variantName == variantName)&&(identical(other.affiliateRefCode, affiliateRefCode) || other.affiliateRefCode == affiliateRefCode)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.comissaoRate, comissaoRate) || other.comissaoRate == comissaoRate)&&(identical(other.comissaoAmount, comissaoAmount) || other.comissaoAmount == comissaoAmount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,variantId,storeId,quantity,unitPrice,totalPrice,productName,productImage,variantName,affiliateRefCode,roomId,comissaoRate,comissaoAmount,createdAt,updatedAt);

@override
String toString() {
  return 'CartItem(id: $id, productId: $productId, variantId: $variantId, storeId: $storeId, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, productName: $productName, productImage: $productImage, variantName: $variantName, affiliateRefCode: $affiliateRefCode, roomId: $roomId, comissaoRate: $comissaoRate, comissaoAmount: $comissaoAmount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CartItemCopyWith<$Res>  {
  factory $CartItemCopyWith(CartItem value, $Res Function(CartItem) _then) = _$CartItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'variant_id') String? variantId,@JsonKey(name: 'store_id') String storeId, int quantity,@JsonKey(name: 'unit_price') double unitPrice,@JsonKey(name: 'total_price') double totalPrice,@JsonKey(name: 'product_name') String productName,@JsonKey(name: 'product_image') String? productImage,@JsonKey(name: 'variant_name') String? variantName,@JsonKey(name: 'affiliate_ref_code') String? affiliateRefCode,@JsonKey(name: 'room_id') String? roomId,@JsonKey(name: 'comissao_rate') double? comissaoRate,@JsonKey(name: 'comissao_amount') double? comissaoAmount,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$CartItemCopyWithImpl<$Res>
    implements $CartItemCopyWith<$Res> {
  _$CartItemCopyWithImpl(this._self, this._then);

  final CartItem _self;
  final $Res Function(CartItem) _then;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? variantId = freezed,Object? storeId = null,Object? quantity = null,Object? unitPrice = null,Object? totalPrice = null,Object? productName = null,Object? productImage = freezed,Object? variantName = freezed,Object? affiliateRefCode = freezed,Object? roomId = freezed,Object? comissaoRate = freezed,Object? comissaoAmount = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,variantId: freezed == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as String?,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,productImage: freezed == productImage ? _self.productImage : productImage // ignore: cast_nullable_to_non_nullable
as String?,variantName: freezed == variantName ? _self.variantName : variantName // ignore: cast_nullable_to_non_nullable
as String?,affiliateRefCode: freezed == affiliateRefCode ? _self.affiliateRefCode : affiliateRefCode // ignore: cast_nullable_to_non_nullable
as String?,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,comissaoRate: freezed == comissaoRate ? _self.comissaoRate : comissaoRate // ignore: cast_nullable_to_non_nullable
as double?,comissaoAmount: freezed == comissaoAmount ? _self.comissaoAmount : comissaoAmount // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CartItem].
extension CartItemPatterns on CartItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartItem value)  $default,){
final _that = this;
switch (_that) {
case _CartItem():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartItem value)?  $default,){
final _that = this;
switch (_that) {
case _CartItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'variant_id')  String? variantId, @JsonKey(name: 'store_id')  String storeId,  int quantity, @JsonKey(name: 'unit_price')  double unitPrice, @JsonKey(name: 'total_price')  double totalPrice, @JsonKey(name: 'product_name')  String productName, @JsonKey(name: 'product_image')  String? productImage, @JsonKey(name: 'variant_name')  String? variantName, @JsonKey(name: 'affiliate_ref_code')  String? affiliateRefCode, @JsonKey(name: 'room_id')  String? roomId, @JsonKey(name: 'comissao_rate')  double? comissaoRate, @JsonKey(name: 'comissao_amount')  double? comissaoAmount, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartItem() when $default != null:
return $default(_that.id,_that.productId,_that.variantId,_that.storeId,_that.quantity,_that.unitPrice,_that.totalPrice,_that.productName,_that.productImage,_that.variantName,_that.affiliateRefCode,_that.roomId,_that.comissaoRate,_that.comissaoAmount,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'variant_id')  String? variantId, @JsonKey(name: 'store_id')  String storeId,  int quantity, @JsonKey(name: 'unit_price')  double unitPrice, @JsonKey(name: 'total_price')  double totalPrice, @JsonKey(name: 'product_name')  String productName, @JsonKey(name: 'product_image')  String? productImage, @JsonKey(name: 'variant_name')  String? variantName, @JsonKey(name: 'affiliate_ref_code')  String? affiliateRefCode, @JsonKey(name: 'room_id')  String? roomId, @JsonKey(name: 'comissao_rate')  double? comissaoRate, @JsonKey(name: 'comissao_amount')  double? comissaoAmount, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CartItem():
return $default(_that.id,_that.productId,_that.variantId,_that.storeId,_that.quantity,_that.unitPrice,_that.totalPrice,_that.productName,_that.productImage,_that.variantName,_that.affiliateRefCode,_that.roomId,_that.comissaoRate,_that.comissaoAmount,_that.createdAt,_that.updatedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'variant_id')  String? variantId, @JsonKey(name: 'store_id')  String storeId,  int quantity, @JsonKey(name: 'unit_price')  double unitPrice, @JsonKey(name: 'total_price')  double totalPrice, @JsonKey(name: 'product_name')  String productName, @JsonKey(name: 'product_image')  String? productImage, @JsonKey(name: 'variant_name')  String? variantName, @JsonKey(name: 'affiliate_ref_code')  String? affiliateRefCode, @JsonKey(name: 'room_id')  String? roomId, @JsonKey(name: 'comissao_rate')  double? comissaoRate, @JsonKey(name: 'comissao_amount')  double? comissaoAmount, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CartItem() when $default != null:
return $default(_that.id,_that.productId,_that.variantId,_that.storeId,_that.quantity,_that.unitPrice,_that.totalPrice,_that.productName,_that.productImage,_that.variantName,_that.affiliateRefCode,_that.roomId,_that.comissaoRate,_that.comissaoAmount,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartItem implements CartItem {
  const _CartItem({required this.id, @JsonKey(name: 'product_id') required this.productId, @JsonKey(name: 'variant_id') this.variantId, @JsonKey(name: 'store_id') required this.storeId, required this.quantity, @JsonKey(name: 'unit_price') required this.unitPrice, @JsonKey(name: 'total_price') required this.totalPrice, @JsonKey(name: 'product_name') required this.productName, @JsonKey(name: 'product_image') this.productImage, @JsonKey(name: 'variant_name') this.variantName, @JsonKey(name: 'affiliate_ref_code') this.affiliateRefCode, @JsonKey(name: 'room_id') this.roomId, @JsonKey(name: 'comissao_rate') this.comissaoRate, @JsonKey(name: 'comissao_amount') this.comissaoAmount, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);

@override final  String id;
@override@JsonKey(name: 'product_id') final  String productId;
@override@JsonKey(name: 'variant_id') final  String? variantId;
@override@JsonKey(name: 'store_id') final  String storeId;
@override final  int quantity;
@override@JsonKey(name: 'unit_price') final  double unitPrice;
@override@JsonKey(name: 'total_price') final  double totalPrice;
@override@JsonKey(name: 'product_name') final  String productName;
@override@JsonKey(name: 'product_image') final  String? productImage;
@override@JsonKey(name: 'variant_name') final  String? variantName;
// ⭐ CRÍTICO: campos de comissão do afiliado
@override@JsonKey(name: 'affiliate_ref_code') final  String? affiliateRefCode;
@override@JsonKey(name: 'room_id') final  String? roomId;
@override@JsonKey(name: 'comissao_rate') final  double? comissaoRate;
@override@JsonKey(name: 'comissao_amount') final  double? comissaoAmount;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartItemCopyWith<_CartItem> get copyWith => __$CartItemCopyWithImpl<_CartItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartItem&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productImage, productImage) || other.productImage == productImage)&&(identical(other.variantName, variantName) || other.variantName == variantName)&&(identical(other.affiliateRefCode, affiliateRefCode) || other.affiliateRefCode == affiliateRefCode)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.comissaoRate, comissaoRate) || other.comissaoRate == comissaoRate)&&(identical(other.comissaoAmount, comissaoAmount) || other.comissaoAmount == comissaoAmount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,variantId,storeId,quantity,unitPrice,totalPrice,productName,productImage,variantName,affiliateRefCode,roomId,comissaoRate,comissaoAmount,createdAt,updatedAt);

@override
String toString() {
  return 'CartItem(id: $id, productId: $productId, variantId: $variantId, storeId: $storeId, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, productName: $productName, productImage: $productImage, variantName: $variantName, affiliateRefCode: $affiliateRefCode, roomId: $roomId, comissaoRate: $comissaoRate, comissaoAmount: $comissaoAmount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CartItemCopyWith<$Res> implements $CartItemCopyWith<$Res> {
  factory _$CartItemCopyWith(_CartItem value, $Res Function(_CartItem) _then) = __$CartItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'variant_id') String? variantId,@JsonKey(name: 'store_id') String storeId, int quantity,@JsonKey(name: 'unit_price') double unitPrice,@JsonKey(name: 'total_price') double totalPrice,@JsonKey(name: 'product_name') String productName,@JsonKey(name: 'product_image') String? productImage,@JsonKey(name: 'variant_name') String? variantName,@JsonKey(name: 'affiliate_ref_code') String? affiliateRefCode,@JsonKey(name: 'room_id') String? roomId,@JsonKey(name: 'comissao_rate') double? comissaoRate,@JsonKey(name: 'comissao_amount') double? comissaoAmount,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$CartItemCopyWithImpl<$Res>
    implements _$CartItemCopyWith<$Res> {
  __$CartItemCopyWithImpl(this._self, this._then);

  final _CartItem _self;
  final $Res Function(_CartItem) _then;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? variantId = freezed,Object? storeId = null,Object? quantity = null,Object? unitPrice = null,Object? totalPrice = null,Object? productName = null,Object? productImage = freezed,Object? variantName = freezed,Object? affiliateRefCode = freezed,Object? roomId = freezed,Object? comissaoRate = freezed,Object? comissaoAmount = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_CartItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,variantId: freezed == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as String?,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,productImage: freezed == productImage ? _self.productImage : productImage // ignore: cast_nullable_to_non_nullable
as String?,variantName: freezed == variantName ? _self.variantName : variantName // ignore: cast_nullable_to_non_nullable
as String?,affiliateRefCode: freezed == affiliateRefCode ? _self.affiliateRefCode : affiliateRefCode // ignore: cast_nullable_to_non_nullable
as String?,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,comissaoRate: freezed == comissaoRate ? _self.comissaoRate : comissaoRate // ignore: cast_nullable_to_non_nullable
as double?,comissaoAmount: freezed == comissaoAmount ? _self.comissaoAmount : comissaoAmount // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Cart {

 String get id;@JsonKey(name: 'user_id') String? get userId;@JsonKey(name: 'store_id') String? get storeId; List<CartItem> get items; double get subtotal; double get tax; double get total;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt;
/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartCopyWith<Cart> get copyWith => _$CartCopyWithImpl<Cart>(this as Cart, _$identity);

  /// Serializes this Cart to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Cart&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.total, total) || other.total == total)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,storeId,const DeepCollectionEquality().hash(items),subtotal,tax,total,createdAt,updatedAt);

@override
String toString() {
  return 'Cart(id: $id, userId: $userId, storeId: $storeId, items: $items, subtotal: $subtotal, tax: $tax, total: $total, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CartCopyWith<$Res>  {
  factory $CartCopyWith(Cart value, $Res Function(Cart) _then) = _$CartCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String? userId,@JsonKey(name: 'store_id') String? storeId, List<CartItem> items, double subtotal, double tax, double total,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class _$CartCopyWithImpl<$Res>
    implements $CartCopyWith<$Res> {
  _$CartCopyWithImpl(this._self, this._then);

  final Cart _self;
  final $Res Function(Cart) _then;

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = freezed,Object? storeId = freezed,Object? items = null,Object? subtotal = null,Object? tax = null,Object? total = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CartItem>,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Cart].
extension CartPatterns on Cart {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Cart value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Cart() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Cart value)  $default,){
final _that = this;
switch (_that) {
case _Cart():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Cart value)?  $default,){
final _that = this;
switch (_that) {
case _Cart() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'store_id')  String? storeId,  List<CartItem> items,  double subtotal,  double tax,  double total, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Cart() when $default != null:
return $default(_that.id,_that.userId,_that.storeId,_that.items,_that.subtotal,_that.tax,_that.total,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'store_id')  String? storeId,  List<CartItem> items,  double subtotal,  double tax,  double total, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Cart():
return $default(_that.id,_that.userId,_that.storeId,_that.items,_that.subtotal,_that.tax,_that.total,_that.createdAt,_that.updatedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'store_id')  String? storeId,  List<CartItem> items,  double subtotal,  double tax,  double total, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Cart() when $default != null:
return $default(_that.id,_that.userId,_that.storeId,_that.items,_that.subtotal,_that.tax,_that.total,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Cart implements Cart {
  const _Cart({required this.id, @JsonKey(name: 'user_id') this.userId, @JsonKey(name: 'store_id') this.storeId, required final  List<CartItem> items, required this.subtotal, required this.tax, required this.total, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt}): _items = items;
  factory _Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String? userId;
@override@JsonKey(name: 'store_id') final  String? storeId;
 final  List<CartItem> _items;
@override List<CartItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  double subtotal;
@override final  double tax;
@override final  double total;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartCopyWith<_Cart> get copyWith => __$CartCopyWithImpl<_Cart>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Cart&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.total, total) || other.total == total)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,storeId,const DeepCollectionEquality().hash(_items),subtotal,tax,total,createdAt,updatedAt);

@override
String toString() {
  return 'Cart(id: $id, userId: $userId, storeId: $storeId, items: $items, subtotal: $subtotal, tax: $tax, total: $total, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CartCopyWith<$Res> implements $CartCopyWith<$Res> {
  factory _$CartCopyWith(_Cart value, $Res Function(_Cart) _then) = __$CartCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String? userId,@JsonKey(name: 'store_id') String? storeId, List<CartItem> items, double subtotal, double tax, double total,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class __$CartCopyWithImpl<$Res>
    implements _$CartCopyWith<$Res> {
  __$CartCopyWithImpl(this._self, this._then);

  final _Cart _self;
  final $Res Function(_Cart) _then;

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = freezed,Object? storeId = freezed,Object? items = null,Object? subtotal = null,Object? tax = null,Object? total = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Cart(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CartItem>,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$OrderItem {

 String get id;@JsonKey(name: 'product_id') String get productId;@JsonKey(name: 'variant_id') String? get variantId;@JsonKey(name: 'product_name') String get productName;@JsonKey(name: 'variant_name') String? get variantName; String? get sku;@JsonKey(name: 'image_url') String? get imageUrl; int get quantity;@JsonKey(name: 'unit_price') double get unitPrice;@JsonKey(name: 'total_price') double get totalPrice;// ⭐ CRÍTICO: comissão do afiliado
@JsonKey(name: 'affiliate_commission_rate') double? get affiliateCommissionRate;@JsonKey(name: 'affiliate_commission_amount') double? get affiliateCommissionAmount;@JsonKey(name: 'fulfilled_quantity') int get fulfilledQuantity;
/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemCopyWith<OrderItem> get copyWith => _$OrderItemCopyWithImpl<OrderItem>(this as OrderItem, _$identity);

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.variantName, variantName) || other.variantName == variantName)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.affiliateCommissionRate, affiliateCommissionRate) || other.affiliateCommissionRate == affiliateCommissionRate)&&(identical(other.affiliateCommissionAmount, affiliateCommissionAmount) || other.affiliateCommissionAmount == affiliateCommissionAmount)&&(identical(other.fulfilledQuantity, fulfilledQuantity) || other.fulfilledQuantity == fulfilledQuantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,variantId,productName,variantName,sku,imageUrl,quantity,unitPrice,totalPrice,affiliateCommissionRate,affiliateCommissionAmount,fulfilledQuantity);

@override
String toString() {
  return 'OrderItem(id: $id, productId: $productId, variantId: $variantId, productName: $productName, variantName: $variantName, sku: $sku, imageUrl: $imageUrl, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, affiliateCommissionRate: $affiliateCommissionRate, affiliateCommissionAmount: $affiliateCommissionAmount, fulfilledQuantity: $fulfilledQuantity)';
}


}

/// @nodoc
abstract mixin class $OrderItemCopyWith<$Res>  {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) _then) = _$OrderItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'variant_id') String? variantId,@JsonKey(name: 'product_name') String productName,@JsonKey(name: 'variant_name') String? variantName, String? sku,@JsonKey(name: 'image_url') String? imageUrl, int quantity,@JsonKey(name: 'unit_price') double unitPrice,@JsonKey(name: 'total_price') double totalPrice,@JsonKey(name: 'affiliate_commission_rate') double? affiliateCommissionRate,@JsonKey(name: 'affiliate_commission_amount') double? affiliateCommissionAmount,@JsonKey(name: 'fulfilled_quantity') int fulfilledQuantity
});




}
/// @nodoc
class _$OrderItemCopyWithImpl<$Res>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._self, this._then);

  final OrderItem _self;
  final $Res Function(OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? variantId = freezed,Object? productName = null,Object? variantName = freezed,Object? sku = freezed,Object? imageUrl = freezed,Object? quantity = null,Object? unitPrice = null,Object? totalPrice = null,Object? affiliateCommissionRate = freezed,Object? affiliateCommissionAmount = freezed,Object? fulfilledQuantity = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,variantId: freezed == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as String?,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,variantName: freezed == variantName ? _self.variantName : variantName // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,affiliateCommissionRate: freezed == affiliateCommissionRate ? _self.affiliateCommissionRate : affiliateCommissionRate // ignore: cast_nullable_to_non_nullable
as double?,affiliateCommissionAmount: freezed == affiliateCommissionAmount ? _self.affiliateCommissionAmount : affiliateCommissionAmount // ignore: cast_nullable_to_non_nullable
as double?,fulfilledQuantity: null == fulfilledQuantity ? _self.fulfilledQuantity : fulfilledQuantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderItem].
extension OrderItemPatterns on OrderItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItem value)  $default,){
final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'variant_id')  String? variantId, @JsonKey(name: 'product_name')  String productName, @JsonKey(name: 'variant_name')  String? variantName,  String? sku, @JsonKey(name: 'image_url')  String? imageUrl,  int quantity, @JsonKey(name: 'unit_price')  double unitPrice, @JsonKey(name: 'total_price')  double totalPrice, @JsonKey(name: 'affiliate_commission_rate')  double? affiliateCommissionRate, @JsonKey(name: 'affiliate_commission_amount')  double? affiliateCommissionAmount, @JsonKey(name: 'fulfilled_quantity')  int fulfilledQuantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.id,_that.productId,_that.variantId,_that.productName,_that.variantName,_that.sku,_that.imageUrl,_that.quantity,_that.unitPrice,_that.totalPrice,_that.affiliateCommissionRate,_that.affiliateCommissionAmount,_that.fulfilledQuantity);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'variant_id')  String? variantId, @JsonKey(name: 'product_name')  String productName, @JsonKey(name: 'variant_name')  String? variantName,  String? sku, @JsonKey(name: 'image_url')  String? imageUrl,  int quantity, @JsonKey(name: 'unit_price')  double unitPrice, @JsonKey(name: 'total_price')  double totalPrice, @JsonKey(name: 'affiliate_commission_rate')  double? affiliateCommissionRate, @JsonKey(name: 'affiliate_commission_amount')  double? affiliateCommissionAmount, @JsonKey(name: 'fulfilled_quantity')  int fulfilledQuantity)  $default,) {final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that.id,_that.productId,_that.variantId,_that.productName,_that.variantName,_that.sku,_that.imageUrl,_that.quantity,_that.unitPrice,_that.totalPrice,_that.affiliateCommissionRate,_that.affiliateCommissionAmount,_that.fulfilledQuantity);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'variant_id')  String? variantId, @JsonKey(name: 'product_name')  String productName, @JsonKey(name: 'variant_name')  String? variantName,  String? sku, @JsonKey(name: 'image_url')  String? imageUrl,  int quantity, @JsonKey(name: 'unit_price')  double unitPrice, @JsonKey(name: 'total_price')  double totalPrice, @JsonKey(name: 'affiliate_commission_rate')  double? affiliateCommissionRate, @JsonKey(name: 'affiliate_commission_amount')  double? affiliateCommissionAmount, @JsonKey(name: 'fulfilled_quantity')  int fulfilledQuantity)?  $default,) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.id,_that.productId,_that.variantId,_that.productName,_that.variantName,_that.sku,_that.imageUrl,_that.quantity,_that.unitPrice,_that.totalPrice,_that.affiliateCommissionRate,_that.affiliateCommissionAmount,_that.fulfilledQuantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderItem implements OrderItem {
  const _OrderItem({required this.id, @JsonKey(name: 'product_id') required this.productId, @JsonKey(name: 'variant_id') this.variantId, @JsonKey(name: 'product_name') required this.productName, @JsonKey(name: 'variant_name') this.variantName, this.sku, @JsonKey(name: 'image_url') this.imageUrl, required this.quantity, @JsonKey(name: 'unit_price') required this.unitPrice, @JsonKey(name: 'total_price') required this.totalPrice, @JsonKey(name: 'affiliate_commission_rate') this.affiliateCommissionRate, @JsonKey(name: 'affiliate_commission_amount') this.affiliateCommissionAmount, @JsonKey(name: 'fulfilled_quantity') this.fulfilledQuantity = 0});
  factory _OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);

@override final  String id;
@override@JsonKey(name: 'product_id') final  String productId;
@override@JsonKey(name: 'variant_id') final  String? variantId;
@override@JsonKey(name: 'product_name') final  String productName;
@override@JsonKey(name: 'variant_name') final  String? variantName;
@override final  String? sku;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override final  int quantity;
@override@JsonKey(name: 'unit_price') final  double unitPrice;
@override@JsonKey(name: 'total_price') final  double totalPrice;
// ⭐ CRÍTICO: comissão do afiliado
@override@JsonKey(name: 'affiliate_commission_rate') final  double? affiliateCommissionRate;
@override@JsonKey(name: 'affiliate_commission_amount') final  double? affiliateCommissionAmount;
@override@JsonKey(name: 'fulfilled_quantity') final  int fulfilledQuantity;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemCopyWith<_OrderItem> get copyWith => __$OrderItemCopyWithImpl<_OrderItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.variantId, variantId) || other.variantId == variantId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.variantName, variantName) || other.variantName == variantName)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.affiliateCommissionRate, affiliateCommissionRate) || other.affiliateCommissionRate == affiliateCommissionRate)&&(identical(other.affiliateCommissionAmount, affiliateCommissionAmount) || other.affiliateCommissionAmount == affiliateCommissionAmount)&&(identical(other.fulfilledQuantity, fulfilledQuantity) || other.fulfilledQuantity == fulfilledQuantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,variantId,productName,variantName,sku,imageUrl,quantity,unitPrice,totalPrice,affiliateCommissionRate,affiliateCommissionAmount,fulfilledQuantity);

@override
String toString() {
  return 'OrderItem(id: $id, productId: $productId, variantId: $variantId, productName: $productName, variantName: $variantName, sku: $sku, imageUrl: $imageUrl, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, affiliateCommissionRate: $affiliateCommissionRate, affiliateCommissionAmount: $affiliateCommissionAmount, fulfilledQuantity: $fulfilledQuantity)';
}


}

/// @nodoc
abstract mixin class _$OrderItemCopyWith<$Res> implements $OrderItemCopyWith<$Res> {
  factory _$OrderItemCopyWith(_OrderItem value, $Res Function(_OrderItem) _then) = __$OrderItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'variant_id') String? variantId,@JsonKey(name: 'product_name') String productName,@JsonKey(name: 'variant_name') String? variantName, String? sku,@JsonKey(name: 'image_url') String? imageUrl, int quantity,@JsonKey(name: 'unit_price') double unitPrice,@JsonKey(name: 'total_price') double totalPrice,@JsonKey(name: 'affiliate_commission_rate') double? affiliateCommissionRate,@JsonKey(name: 'affiliate_commission_amount') double? affiliateCommissionAmount,@JsonKey(name: 'fulfilled_quantity') int fulfilledQuantity
});




}
/// @nodoc
class __$OrderItemCopyWithImpl<$Res>
    implements _$OrderItemCopyWith<$Res> {
  __$OrderItemCopyWithImpl(this._self, this._then);

  final _OrderItem _self;
  final $Res Function(_OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? variantId = freezed,Object? productName = null,Object? variantName = freezed,Object? sku = freezed,Object? imageUrl = freezed,Object? quantity = null,Object? unitPrice = null,Object? totalPrice = null,Object? affiliateCommissionRate = freezed,Object? affiliateCommissionAmount = freezed,Object? fulfilledQuantity = null,}) {
  return _then(_OrderItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,variantId: freezed == variantId ? _self.variantId : variantId // ignore: cast_nullable_to_non_nullable
as String?,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,variantName: freezed == variantName ? _self.variantName : variantName // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,affiliateCommissionRate: freezed == affiliateCommissionRate ? _self.affiliateCommissionRate : affiliateCommissionRate // ignore: cast_nullable_to_non_nullable
as double?,affiliateCommissionAmount: freezed == affiliateCommissionAmount ? _self.affiliateCommissionAmount : affiliateCommissionAmount // ignore: cast_nullable_to_non_nullable
as double?,fulfilledQuantity: null == fulfilledQuantity ? _self.fulfilledQuantity : fulfilledQuantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Order {

 String get id; String get number;@JsonKey(name: 'user_id') String? get userId;@JsonKey(name: 'store_id') String? get storeId; List<OrderItem> get items;// ⭐ CRÍTICO: rastreamento de comissão
@JsonKey(name: 'affiliate_id') String? get affiliateId;@JsonKey(name: 'affiliate_commission_amount') double? get affiliateCommissionAmount; double get subtotal; double get tax; double get shipping; double get total; OrderStatus get status;@JsonKey(name: 'payment_status') PaymentStatus get paymentStatus;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.affiliateId, affiliateId) || other.affiliateId == affiliateId)&&(identical(other.affiliateCommissionAmount, affiliateCommissionAmount) || other.affiliateCommissionAmount == affiliateCommissionAmount)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.shipping, shipping) || other.shipping == shipping)&&(identical(other.total, total) || other.total == total)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,userId,storeId,const DeepCollectionEquality().hash(items),affiliateId,affiliateCommissionAmount,subtotal,tax,shipping,total,status,paymentStatus,createdAt,updatedAt);

@override
String toString() {
  return 'Order(id: $id, number: $number, userId: $userId, storeId: $storeId, items: $items, affiliateId: $affiliateId, affiliateCommissionAmount: $affiliateCommissionAmount, subtotal: $subtotal, tax: $tax, shipping: $shipping, total: $total, status: $status, paymentStatus: $paymentStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String id, String number,@JsonKey(name: 'user_id') String? userId,@JsonKey(name: 'store_id') String? storeId, List<OrderItem> items,@JsonKey(name: 'affiliate_id') String? affiliateId,@JsonKey(name: 'affiliate_commission_amount') double? affiliateCommissionAmount, double subtotal, double tax, double shipping, double total, OrderStatus status,@JsonKey(name: 'payment_status') PaymentStatus paymentStatus,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? userId = freezed,Object? storeId = freezed,Object? items = null,Object? affiliateId = freezed,Object? affiliateCommissionAmount = freezed,Object? subtotal = null,Object? tax = null,Object? shipping = null,Object? total = null,Object? status = null,Object? paymentStatus = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,affiliateId: freezed == affiliateId ? _self.affiliateId : affiliateId // ignore: cast_nullable_to_non_nullable
as String?,affiliateCommissionAmount: freezed == affiliateCommissionAmount ? _self.affiliateCommissionAmount : affiliateCommissionAmount // ignore: cast_nullable_to_non_nullable
as double?,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double,shipping: null == shipping ? _self.shipping : shipping // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String number, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'store_id')  String? storeId,  List<OrderItem> items, @JsonKey(name: 'affiliate_id')  String? affiliateId, @JsonKey(name: 'affiliate_commission_amount')  double? affiliateCommissionAmount,  double subtotal,  double tax,  double shipping,  double total,  OrderStatus status, @JsonKey(name: 'payment_status')  PaymentStatus paymentStatus, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.number,_that.userId,_that.storeId,_that.items,_that.affiliateId,_that.affiliateCommissionAmount,_that.subtotal,_that.tax,_that.shipping,_that.total,_that.status,_that.paymentStatus,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String number, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'store_id')  String? storeId,  List<OrderItem> items, @JsonKey(name: 'affiliate_id')  String? affiliateId, @JsonKey(name: 'affiliate_commission_amount')  double? affiliateCommissionAmount,  double subtotal,  double tax,  double shipping,  double total,  OrderStatus status, @JsonKey(name: 'payment_status')  PaymentStatus paymentStatus, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.number,_that.userId,_that.storeId,_that.items,_that.affiliateId,_that.affiliateCommissionAmount,_that.subtotal,_that.tax,_that.shipping,_that.total,_that.status,_that.paymentStatus,_that.createdAt,_that.updatedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String number, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'store_id')  String? storeId,  List<OrderItem> items, @JsonKey(name: 'affiliate_id')  String? affiliateId, @JsonKey(name: 'affiliate_commission_amount')  double? affiliateCommissionAmount,  double subtotal,  double tax,  double shipping,  double total,  OrderStatus status, @JsonKey(name: 'payment_status')  PaymentStatus paymentStatus, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.number,_that.userId,_that.storeId,_that.items,_that.affiliateId,_that.affiliateCommissionAmount,_that.subtotal,_that.tax,_that.shipping,_that.total,_that.status,_that.paymentStatus,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order implements Order {
  const _Order({required this.id, required this.number, @JsonKey(name: 'user_id') this.userId, @JsonKey(name: 'store_id') this.storeId, required final  List<OrderItem> items, @JsonKey(name: 'affiliate_id') this.affiliateId, @JsonKey(name: 'affiliate_commission_amount') this.affiliateCommissionAmount, required this.subtotal, required this.tax, required this.shipping, required this.total, required this.status, @JsonKey(name: 'payment_status') required this.paymentStatus, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt}): _items = items;
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override final  String id;
@override final  String number;
@override@JsonKey(name: 'user_id') final  String? userId;
@override@JsonKey(name: 'store_id') final  String? storeId;
 final  List<OrderItem> _items;
@override List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

// ⭐ CRÍTICO: rastreamento de comissão
@override@JsonKey(name: 'affiliate_id') final  String? affiliateId;
@override@JsonKey(name: 'affiliate_commission_amount') final  double? affiliateCommissionAmount;
@override final  double subtotal;
@override final  double tax;
@override final  double shipping;
@override final  double total;
@override final  OrderStatus status;
@override@JsonKey(name: 'payment_status') final  PaymentStatus paymentStatus;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.affiliateId, affiliateId) || other.affiliateId == affiliateId)&&(identical(other.affiliateCommissionAmount, affiliateCommissionAmount) || other.affiliateCommissionAmount == affiliateCommissionAmount)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.shipping, shipping) || other.shipping == shipping)&&(identical(other.total, total) || other.total == total)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,number,userId,storeId,const DeepCollectionEquality().hash(_items),affiliateId,affiliateCommissionAmount,subtotal,tax,shipping,total,status,paymentStatus,createdAt,updatedAt);

@override
String toString() {
  return 'Order(id: $id, number: $number, userId: $userId, storeId: $storeId, items: $items, affiliateId: $affiliateId, affiliateCommissionAmount: $affiliateCommissionAmount, subtotal: $subtotal, tax: $tax, shipping: $shipping, total: $total, status: $status, paymentStatus: $paymentStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String number,@JsonKey(name: 'user_id') String? userId,@JsonKey(name: 'store_id') String? storeId, List<OrderItem> items,@JsonKey(name: 'affiliate_id') String? affiliateId,@JsonKey(name: 'affiliate_commission_amount') double? affiliateCommissionAmount, double subtotal, double tax, double shipping, double total, OrderStatus status,@JsonKey(name: 'payment_status') PaymentStatus paymentStatus,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? userId = freezed,Object? storeId = freezed,Object? items = null,Object? affiliateId = freezed,Object? affiliateCommissionAmount = freezed,Object? subtotal = null,Object? tax = null,Object? shipping = null,Object? total = null,Object? status = null,Object? paymentStatus = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,storeId: freezed == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,affiliateId: freezed == affiliateId ? _self.affiliateId : affiliateId // ignore: cast_nullable_to_non_nullable
as String?,affiliateCommissionAmount: freezed == affiliateCommissionAmount ? _self.affiliateCommissionAmount : affiliateCommissionAmount // ignore: cast_nullable_to_non_nullable
as double?,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double,shipping: null == shipping ? _self.shipping : shipping // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PaymentIntent {

 String get id;@JsonKey(name: 'order_id') String? get orderId; double get amount; String get method; PaymentStatus get status;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt; Map<String, dynamic>? get metadata;
/// Create a copy of PaymentIntent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentIntentCopyWith<PaymentIntent> get copyWith => _$PaymentIntentCopyWithImpl<PaymentIntent>(this as PaymentIntent, _$identity);

  /// Serializes this PaymentIntent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentIntent&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.method, method) || other.method == method)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,amount,method,status,createdAt,updatedAt,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'PaymentIntent(id: $id, orderId: $orderId, amount: $amount, method: $method, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $PaymentIntentCopyWith<$Res>  {
  factory $PaymentIntentCopyWith(PaymentIntent value, $Res Function(PaymentIntent) _then) = _$PaymentIntentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'order_id') String? orderId, double amount, String method, PaymentStatus status,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$PaymentIntentCopyWithImpl<$Res>
    implements $PaymentIntentCopyWith<$Res> {
  _$PaymentIntentCopyWithImpl(this._self, this._then);

  final PaymentIntent _self;
  final $Res Function(PaymentIntent) _then;

/// Create a copy of PaymentIntent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderId = freezed,Object? amount = null,Object? method = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentIntent].
extension PaymentIntentPatterns on PaymentIntent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentIntent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentIntent() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentIntent value)  $default,){
final _that = this;
switch (_that) {
case _PaymentIntent():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentIntent value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentIntent() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'order_id')  String? orderId,  double amount,  String method,  PaymentStatus status, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentIntent() when $default != null:
return $default(_that.id,_that.orderId,_that.amount,_that.method,_that.status,_that.createdAt,_that.updatedAt,_that.metadata);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'order_id')  String? orderId,  double amount,  String method,  PaymentStatus status, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _PaymentIntent():
return $default(_that.id,_that.orderId,_that.amount,_that.method,_that.status,_that.createdAt,_that.updatedAt,_that.metadata);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'order_id')  String? orderId,  double amount,  String method,  PaymentStatus status, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _PaymentIntent() when $default != null:
return $default(_that.id,_that.orderId,_that.amount,_that.method,_that.status,_that.createdAt,_that.updatedAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentIntent implements PaymentIntent {
  const _PaymentIntent({required this.id, @JsonKey(name: 'order_id') this.orderId, required this.amount, required this.method, required this.status, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _PaymentIntent.fromJson(Map<String, dynamic> json) => _$PaymentIntentFromJson(json);

@override final  String id;
@override@JsonKey(name: 'order_id') final  String? orderId;
@override final  double amount;
@override final  String method;
@override final  PaymentStatus status;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of PaymentIntent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentIntentCopyWith<_PaymentIntent> get copyWith => __$PaymentIntentCopyWithImpl<_PaymentIntent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentIntentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentIntent&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.method, method) || other.method == method)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,amount,method,status,createdAt,updatedAt,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'PaymentIntent(id: $id, orderId: $orderId, amount: $amount, method: $method, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$PaymentIntentCopyWith<$Res> implements $PaymentIntentCopyWith<$Res> {
  factory _$PaymentIntentCopyWith(_PaymentIntent value, $Res Function(_PaymentIntent) _then) = __$PaymentIntentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'order_id') String? orderId, double amount, String method, PaymentStatus status,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$PaymentIntentCopyWithImpl<$Res>
    implements _$PaymentIntentCopyWith<$Res> {
  __$PaymentIntentCopyWithImpl(this._self, this._then);

  final _PaymentIntent _self;
  final $Res Function(_PaymentIntent) _then;

/// Create a copy of PaymentIntent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderId = freezed,Object? amount = null,Object? method = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? metadata = freezed,}) {
  return _then(_PaymentIntent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$CartItemRequest {

@JsonKey(name: 'product_id') String get productId; int get quantity;@JsonKey(name: 'affiliate_ref_code') String? get affiliateRefCode;@JsonKey(name: 'room_id') String? get roomId;
/// Create a copy of CartItemRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartItemRequestCopyWith<CartItemRequest> get copyWith => _$CartItemRequestCopyWithImpl<CartItemRequest>(this as CartItemRequest, _$identity);

  /// Serializes this CartItemRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartItemRequest&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.affiliateRefCode, affiliateRefCode) || other.affiliateRefCode == affiliateRefCode)&&(identical(other.roomId, roomId) || other.roomId == roomId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,quantity,affiliateRefCode,roomId);

@override
String toString() {
  return 'CartItemRequest(productId: $productId, quantity: $quantity, affiliateRefCode: $affiliateRefCode, roomId: $roomId)';
}


}

/// @nodoc
abstract mixin class $CartItemRequestCopyWith<$Res>  {
  factory $CartItemRequestCopyWith(CartItemRequest value, $Res Function(CartItemRequest) _then) = _$CartItemRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'product_id') String productId, int quantity,@JsonKey(name: 'affiliate_ref_code') String? affiliateRefCode,@JsonKey(name: 'room_id') String? roomId
});




}
/// @nodoc
class _$CartItemRequestCopyWithImpl<$Res>
    implements $CartItemRequestCopyWith<$Res> {
  _$CartItemRequestCopyWithImpl(this._self, this._then);

  final CartItemRequest _self;
  final $Res Function(CartItemRequest) _then;

/// Create a copy of CartItemRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? quantity = null,Object? affiliateRefCode = freezed,Object? roomId = freezed,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,affiliateRefCode: freezed == affiliateRefCode ? _self.affiliateRefCode : affiliateRefCode // ignore: cast_nullable_to_non_nullable
as String?,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CartItemRequest].
extension CartItemRequestPatterns on CartItemRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartItemRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartItemRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartItemRequest value)  $default,){
final _that = this;
switch (_that) {
case _CartItemRequest():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartItemRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CartItemRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'product_id')  String productId,  int quantity, @JsonKey(name: 'affiliate_ref_code')  String? affiliateRefCode, @JsonKey(name: 'room_id')  String? roomId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartItemRequest() when $default != null:
return $default(_that.productId,_that.quantity,_that.affiliateRefCode,_that.roomId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'product_id')  String productId,  int quantity, @JsonKey(name: 'affiliate_ref_code')  String? affiliateRefCode, @JsonKey(name: 'room_id')  String? roomId)  $default,) {final _that = this;
switch (_that) {
case _CartItemRequest():
return $default(_that.productId,_that.quantity,_that.affiliateRefCode,_that.roomId);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'product_id')  String productId,  int quantity, @JsonKey(name: 'affiliate_ref_code')  String? affiliateRefCode, @JsonKey(name: 'room_id')  String? roomId)?  $default,) {final _that = this;
switch (_that) {
case _CartItemRequest() when $default != null:
return $default(_that.productId,_that.quantity,_that.affiliateRefCode,_that.roomId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartItemRequest implements CartItemRequest {
  const _CartItemRequest({@JsonKey(name: 'product_id') required this.productId, required this.quantity, @JsonKey(name: 'affiliate_ref_code') this.affiliateRefCode, @JsonKey(name: 'room_id') this.roomId});
  factory _CartItemRequest.fromJson(Map<String, dynamic> json) => _$CartItemRequestFromJson(json);

@override@JsonKey(name: 'product_id') final  String productId;
@override final  int quantity;
@override@JsonKey(name: 'affiliate_ref_code') final  String? affiliateRefCode;
@override@JsonKey(name: 'room_id') final  String? roomId;

/// Create a copy of CartItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartItemRequestCopyWith<_CartItemRequest> get copyWith => __$CartItemRequestCopyWithImpl<_CartItemRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartItemRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartItemRequest&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.affiliateRefCode, affiliateRefCode) || other.affiliateRefCode == affiliateRefCode)&&(identical(other.roomId, roomId) || other.roomId == roomId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,quantity,affiliateRefCode,roomId);

@override
String toString() {
  return 'CartItemRequest(productId: $productId, quantity: $quantity, affiliateRefCode: $affiliateRefCode, roomId: $roomId)';
}


}

/// @nodoc
abstract mixin class _$CartItemRequestCopyWith<$Res> implements $CartItemRequestCopyWith<$Res> {
  factory _$CartItemRequestCopyWith(_CartItemRequest value, $Res Function(_CartItemRequest) _then) = __$CartItemRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'product_id') String productId, int quantity,@JsonKey(name: 'affiliate_ref_code') String? affiliateRefCode,@JsonKey(name: 'room_id') String? roomId
});




}
/// @nodoc
class __$CartItemRequestCopyWithImpl<$Res>
    implements _$CartItemRequestCopyWith<$Res> {
  __$CartItemRequestCopyWithImpl(this._self, this._then);

  final _CartItemRequest _self;
  final $Res Function(_CartItemRequest) _then;

/// Create a copy of CartItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? quantity = null,Object? affiliateRefCode = freezed,Object? roomId = freezed,}) {
  return _then(_CartItemRequest(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,affiliateRefCode: freezed == affiliateRefCode ? _self.affiliateRefCode : affiliateRefCode // ignore: cast_nullable_to_non_nullable
as String?,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CartItemUpdateRequest {

 int get quantity;
/// Create a copy of CartItemUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartItemUpdateRequestCopyWith<CartItemUpdateRequest> get copyWith => _$CartItemUpdateRequestCopyWithImpl<CartItemUpdateRequest>(this as CartItemUpdateRequest, _$identity);

  /// Serializes this CartItemUpdateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartItemUpdateRequest&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,quantity);

@override
String toString() {
  return 'CartItemUpdateRequest(quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $CartItemUpdateRequestCopyWith<$Res>  {
  factory $CartItemUpdateRequestCopyWith(CartItemUpdateRequest value, $Res Function(CartItemUpdateRequest) _then) = _$CartItemUpdateRequestCopyWithImpl;
@useResult
$Res call({
 int quantity
});




}
/// @nodoc
class _$CartItemUpdateRequestCopyWithImpl<$Res>
    implements $CartItemUpdateRequestCopyWith<$Res> {
  _$CartItemUpdateRequestCopyWithImpl(this._self, this._then);

  final CartItemUpdateRequest _self;
  final $Res Function(CartItemUpdateRequest) _then;

/// Create a copy of CartItemUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quantity = null,}) {
  return _then(_self.copyWith(
quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CartItemUpdateRequest].
extension CartItemUpdateRequestPatterns on CartItemUpdateRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartItemUpdateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartItemUpdateRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartItemUpdateRequest value)  $default,){
final _that = this;
switch (_that) {
case _CartItemUpdateRequest():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartItemUpdateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CartItemUpdateRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartItemUpdateRequest() when $default != null:
return $default(_that.quantity);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int quantity)  $default,) {final _that = this;
switch (_that) {
case _CartItemUpdateRequest():
return $default(_that.quantity);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int quantity)?  $default,) {final _that = this;
switch (_that) {
case _CartItemUpdateRequest() when $default != null:
return $default(_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartItemUpdateRequest implements CartItemUpdateRequest {
  const _CartItemUpdateRequest({required this.quantity});
  factory _CartItemUpdateRequest.fromJson(Map<String, dynamic> json) => _$CartItemUpdateRequestFromJson(json);

@override final  int quantity;

/// Create a copy of CartItemUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartItemUpdateRequestCopyWith<_CartItemUpdateRequest> get copyWith => __$CartItemUpdateRequestCopyWithImpl<_CartItemUpdateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartItemUpdateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartItemUpdateRequest&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,quantity);

@override
String toString() {
  return 'CartItemUpdateRequest(quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$CartItemUpdateRequestCopyWith<$Res> implements $CartItemUpdateRequestCopyWith<$Res> {
  factory _$CartItemUpdateRequestCopyWith(_CartItemUpdateRequest value, $Res Function(_CartItemUpdateRequest) _then) = __$CartItemUpdateRequestCopyWithImpl;
@override @useResult
$Res call({
 int quantity
});




}
/// @nodoc
class __$CartItemUpdateRequestCopyWithImpl<$Res>
    implements _$CartItemUpdateRequestCopyWith<$Res> {
  __$CartItemUpdateRequestCopyWithImpl(this._self, this._then);

  final _CartItemUpdateRequest _self;
  final $Res Function(_CartItemUpdateRequest) _then;

/// Create a copy of CartItemUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? quantity = null,}) {
  return _then(_CartItemUpdateRequest(
quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CheckoutRequest {

@JsonKey(name: 'shipping_address') ShippingAddress get shippingAddress;@JsonKey(name: 'billing_address') ShippingAddress? get billingAddress;@JsonKey(name: 'customer_name') String get customerName;@JsonKey(name: 'customer_email') String get customerEmail;@JsonKey(name: 'customer_phone') String? get customerPhone;@JsonKey(name: 'customer_document') String? get customerDocument;@JsonKey(name: 'customer_fiscal_data') Map<String, dynamic>? get customerFiscalData;@JsonKey(name: 'shipping_method') String get shippingMethod;@JsonKey(name: 'payment_method') String get paymentMethod;@JsonKey(name: 'coupon_code') String? get couponCode;@JsonKey(name: 'customer_note') String? get customerNote;@JsonKey(name: 'session_id') String? get sessionId;// ⭐ CRÍTICO: afiliado que referiu
@JsonKey(name: 'affiliate_id') String? get affiliateId;
/// Create a copy of CheckoutRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutRequestCopyWith<CheckoutRequest> get copyWith => _$CheckoutRequestCopyWithImpl<CheckoutRequest>(this as CheckoutRequest, _$identity);

  /// Serializes this CheckoutRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutRequest&&(identical(other.shippingAddress, shippingAddress) || other.shippingAddress == shippingAddress)&&(identical(other.billingAddress, billingAddress) || other.billingAddress == billingAddress)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.customerDocument, customerDocument) || other.customerDocument == customerDocument)&&const DeepCollectionEquality().equals(other.customerFiscalData, customerFiscalData)&&(identical(other.shippingMethod, shippingMethod) || other.shippingMethod == shippingMethod)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.couponCode, couponCode) || other.couponCode == couponCode)&&(identical(other.customerNote, customerNote) || other.customerNote == customerNote)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.affiliateId, affiliateId) || other.affiliateId == affiliateId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shippingAddress,billingAddress,customerName,customerEmail,customerPhone,customerDocument,const DeepCollectionEquality().hash(customerFiscalData),shippingMethod,paymentMethod,couponCode,customerNote,sessionId,affiliateId);

@override
String toString() {
  return 'CheckoutRequest(shippingAddress: $shippingAddress, billingAddress: $billingAddress, customerName: $customerName, customerEmail: $customerEmail, customerPhone: $customerPhone, customerDocument: $customerDocument, customerFiscalData: $customerFiscalData, shippingMethod: $shippingMethod, paymentMethod: $paymentMethod, couponCode: $couponCode, customerNote: $customerNote, sessionId: $sessionId, affiliateId: $affiliateId)';
}


}

/// @nodoc
abstract mixin class $CheckoutRequestCopyWith<$Res>  {
  factory $CheckoutRequestCopyWith(CheckoutRequest value, $Res Function(CheckoutRequest) _then) = _$CheckoutRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'shipping_address') ShippingAddress shippingAddress,@JsonKey(name: 'billing_address') ShippingAddress? billingAddress,@JsonKey(name: 'customer_name') String customerName,@JsonKey(name: 'customer_email') String customerEmail,@JsonKey(name: 'customer_phone') String? customerPhone,@JsonKey(name: 'customer_document') String? customerDocument,@JsonKey(name: 'customer_fiscal_data') Map<String, dynamic>? customerFiscalData,@JsonKey(name: 'shipping_method') String shippingMethod,@JsonKey(name: 'payment_method') String paymentMethod,@JsonKey(name: 'coupon_code') String? couponCode,@JsonKey(name: 'customer_note') String? customerNote,@JsonKey(name: 'session_id') String? sessionId,@JsonKey(name: 'affiliate_id') String? affiliateId
});


$ShippingAddressCopyWith<$Res> get shippingAddress;$ShippingAddressCopyWith<$Res>? get billingAddress;

}
/// @nodoc
class _$CheckoutRequestCopyWithImpl<$Res>
    implements $CheckoutRequestCopyWith<$Res> {
  _$CheckoutRequestCopyWithImpl(this._self, this._then);

  final CheckoutRequest _self;
  final $Res Function(CheckoutRequest) _then;

/// Create a copy of CheckoutRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shippingAddress = null,Object? billingAddress = freezed,Object? customerName = null,Object? customerEmail = null,Object? customerPhone = freezed,Object? customerDocument = freezed,Object? customerFiscalData = freezed,Object? shippingMethod = null,Object? paymentMethod = null,Object? couponCode = freezed,Object? customerNote = freezed,Object? sessionId = freezed,Object? affiliateId = freezed,}) {
  return _then(_self.copyWith(
shippingAddress: null == shippingAddress ? _self.shippingAddress : shippingAddress // ignore: cast_nullable_to_non_nullable
as ShippingAddress,billingAddress: freezed == billingAddress ? _self.billingAddress : billingAddress // ignore: cast_nullable_to_non_nullable
as ShippingAddress?,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerEmail: null == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,customerDocument: freezed == customerDocument ? _self.customerDocument : customerDocument // ignore: cast_nullable_to_non_nullable
as String?,customerFiscalData: freezed == customerFiscalData ? _self.customerFiscalData : customerFiscalData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,shippingMethod: null == shippingMethod ? _self.shippingMethod : shippingMethod // ignore: cast_nullable_to_non_nullable
as String,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,couponCode: freezed == couponCode ? _self.couponCode : couponCode // ignore: cast_nullable_to_non_nullable
as String?,customerNote: freezed == customerNote ? _self.customerNote : customerNote // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,affiliateId: freezed == affiliateId ? _self.affiliateId : affiliateId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CheckoutRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShippingAddressCopyWith<$Res> get shippingAddress {
  
  return $ShippingAddressCopyWith<$Res>(_self.shippingAddress, (value) {
    return _then(_self.copyWith(shippingAddress: value));
  });
}/// Create a copy of CheckoutRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShippingAddressCopyWith<$Res>? get billingAddress {
    if (_self.billingAddress == null) {
    return null;
  }

  return $ShippingAddressCopyWith<$Res>(_self.billingAddress!, (value) {
    return _then(_self.copyWith(billingAddress: value));
  });
}
}


/// Adds pattern-matching-related methods to [CheckoutRequest].
extension CheckoutRequestPatterns on CheckoutRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckoutRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckoutRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckoutRequest value)  $default,){
final _that = this;
switch (_that) {
case _CheckoutRequest():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckoutRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CheckoutRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'shipping_address')  ShippingAddress shippingAddress, @JsonKey(name: 'billing_address')  ShippingAddress? billingAddress, @JsonKey(name: 'customer_name')  String customerName, @JsonKey(name: 'customer_email')  String customerEmail, @JsonKey(name: 'customer_phone')  String? customerPhone, @JsonKey(name: 'customer_document')  String? customerDocument, @JsonKey(name: 'customer_fiscal_data')  Map<String, dynamic>? customerFiscalData, @JsonKey(name: 'shipping_method')  String shippingMethod, @JsonKey(name: 'payment_method')  String paymentMethod, @JsonKey(name: 'coupon_code')  String? couponCode, @JsonKey(name: 'customer_note')  String? customerNote, @JsonKey(name: 'session_id')  String? sessionId, @JsonKey(name: 'affiliate_id')  String? affiliateId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckoutRequest() when $default != null:
return $default(_that.shippingAddress,_that.billingAddress,_that.customerName,_that.customerEmail,_that.customerPhone,_that.customerDocument,_that.customerFiscalData,_that.shippingMethod,_that.paymentMethod,_that.couponCode,_that.customerNote,_that.sessionId,_that.affiliateId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'shipping_address')  ShippingAddress shippingAddress, @JsonKey(name: 'billing_address')  ShippingAddress? billingAddress, @JsonKey(name: 'customer_name')  String customerName, @JsonKey(name: 'customer_email')  String customerEmail, @JsonKey(name: 'customer_phone')  String? customerPhone, @JsonKey(name: 'customer_document')  String? customerDocument, @JsonKey(name: 'customer_fiscal_data')  Map<String, dynamic>? customerFiscalData, @JsonKey(name: 'shipping_method')  String shippingMethod, @JsonKey(name: 'payment_method')  String paymentMethod, @JsonKey(name: 'coupon_code')  String? couponCode, @JsonKey(name: 'customer_note')  String? customerNote, @JsonKey(name: 'session_id')  String? sessionId, @JsonKey(name: 'affiliate_id')  String? affiliateId)  $default,) {final _that = this;
switch (_that) {
case _CheckoutRequest():
return $default(_that.shippingAddress,_that.billingAddress,_that.customerName,_that.customerEmail,_that.customerPhone,_that.customerDocument,_that.customerFiscalData,_that.shippingMethod,_that.paymentMethod,_that.couponCode,_that.customerNote,_that.sessionId,_that.affiliateId);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'shipping_address')  ShippingAddress shippingAddress, @JsonKey(name: 'billing_address')  ShippingAddress? billingAddress, @JsonKey(name: 'customer_name')  String customerName, @JsonKey(name: 'customer_email')  String customerEmail, @JsonKey(name: 'customer_phone')  String? customerPhone, @JsonKey(name: 'customer_document')  String? customerDocument, @JsonKey(name: 'customer_fiscal_data')  Map<String, dynamic>? customerFiscalData, @JsonKey(name: 'shipping_method')  String shippingMethod, @JsonKey(name: 'payment_method')  String paymentMethod, @JsonKey(name: 'coupon_code')  String? couponCode, @JsonKey(name: 'customer_note')  String? customerNote, @JsonKey(name: 'session_id')  String? sessionId, @JsonKey(name: 'affiliate_id')  String? affiliateId)?  $default,) {final _that = this;
switch (_that) {
case _CheckoutRequest() when $default != null:
return $default(_that.shippingAddress,_that.billingAddress,_that.customerName,_that.customerEmail,_that.customerPhone,_that.customerDocument,_that.customerFiscalData,_that.shippingMethod,_that.paymentMethod,_that.couponCode,_that.customerNote,_that.sessionId,_that.affiliateId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckoutRequest implements CheckoutRequest {
  const _CheckoutRequest({@JsonKey(name: 'shipping_address') required this.shippingAddress, @JsonKey(name: 'billing_address') this.billingAddress, @JsonKey(name: 'customer_name') required this.customerName, @JsonKey(name: 'customer_email') required this.customerEmail, @JsonKey(name: 'customer_phone') this.customerPhone, @JsonKey(name: 'customer_document') this.customerDocument, @JsonKey(name: 'customer_fiscal_data') final  Map<String, dynamic>? customerFiscalData, @JsonKey(name: 'shipping_method') required this.shippingMethod, @JsonKey(name: 'payment_method') required this.paymentMethod, @JsonKey(name: 'coupon_code') this.couponCode, @JsonKey(name: 'customer_note') this.customerNote, @JsonKey(name: 'session_id') this.sessionId, @JsonKey(name: 'affiliate_id') this.affiliateId}): _customerFiscalData = customerFiscalData;
  factory _CheckoutRequest.fromJson(Map<String, dynamic> json) => _$CheckoutRequestFromJson(json);

@override@JsonKey(name: 'shipping_address') final  ShippingAddress shippingAddress;
@override@JsonKey(name: 'billing_address') final  ShippingAddress? billingAddress;
@override@JsonKey(name: 'customer_name') final  String customerName;
@override@JsonKey(name: 'customer_email') final  String customerEmail;
@override@JsonKey(name: 'customer_phone') final  String? customerPhone;
@override@JsonKey(name: 'customer_document') final  String? customerDocument;
 final  Map<String, dynamic>? _customerFiscalData;
@override@JsonKey(name: 'customer_fiscal_data') Map<String, dynamic>? get customerFiscalData {
  final value = _customerFiscalData;
  if (value == null) return null;
  if (_customerFiscalData is EqualUnmodifiableMapView) return _customerFiscalData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'shipping_method') final  String shippingMethod;
@override@JsonKey(name: 'payment_method') final  String paymentMethod;
@override@JsonKey(name: 'coupon_code') final  String? couponCode;
@override@JsonKey(name: 'customer_note') final  String? customerNote;
@override@JsonKey(name: 'session_id') final  String? sessionId;
// ⭐ CRÍTICO: afiliado que referiu
@override@JsonKey(name: 'affiliate_id') final  String? affiliateId;

/// Create a copy of CheckoutRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutRequestCopyWith<_CheckoutRequest> get copyWith => __$CheckoutRequestCopyWithImpl<_CheckoutRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckoutRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckoutRequest&&(identical(other.shippingAddress, shippingAddress) || other.shippingAddress == shippingAddress)&&(identical(other.billingAddress, billingAddress) || other.billingAddress == billingAddress)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.customerDocument, customerDocument) || other.customerDocument == customerDocument)&&const DeepCollectionEquality().equals(other._customerFiscalData, _customerFiscalData)&&(identical(other.shippingMethod, shippingMethod) || other.shippingMethod == shippingMethod)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.couponCode, couponCode) || other.couponCode == couponCode)&&(identical(other.customerNote, customerNote) || other.customerNote == customerNote)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.affiliateId, affiliateId) || other.affiliateId == affiliateId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,shippingAddress,billingAddress,customerName,customerEmail,customerPhone,customerDocument,const DeepCollectionEquality().hash(_customerFiscalData),shippingMethod,paymentMethod,couponCode,customerNote,sessionId,affiliateId);

@override
String toString() {
  return 'CheckoutRequest(shippingAddress: $shippingAddress, billingAddress: $billingAddress, customerName: $customerName, customerEmail: $customerEmail, customerPhone: $customerPhone, customerDocument: $customerDocument, customerFiscalData: $customerFiscalData, shippingMethod: $shippingMethod, paymentMethod: $paymentMethod, couponCode: $couponCode, customerNote: $customerNote, sessionId: $sessionId, affiliateId: $affiliateId)';
}


}

/// @nodoc
abstract mixin class _$CheckoutRequestCopyWith<$Res> implements $CheckoutRequestCopyWith<$Res> {
  factory _$CheckoutRequestCopyWith(_CheckoutRequest value, $Res Function(_CheckoutRequest) _then) = __$CheckoutRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'shipping_address') ShippingAddress shippingAddress,@JsonKey(name: 'billing_address') ShippingAddress? billingAddress,@JsonKey(name: 'customer_name') String customerName,@JsonKey(name: 'customer_email') String customerEmail,@JsonKey(name: 'customer_phone') String? customerPhone,@JsonKey(name: 'customer_document') String? customerDocument,@JsonKey(name: 'customer_fiscal_data') Map<String, dynamic>? customerFiscalData,@JsonKey(name: 'shipping_method') String shippingMethod,@JsonKey(name: 'payment_method') String paymentMethod,@JsonKey(name: 'coupon_code') String? couponCode,@JsonKey(name: 'customer_note') String? customerNote,@JsonKey(name: 'session_id') String? sessionId,@JsonKey(name: 'affiliate_id') String? affiliateId
});


@override $ShippingAddressCopyWith<$Res> get shippingAddress;@override $ShippingAddressCopyWith<$Res>? get billingAddress;

}
/// @nodoc
class __$CheckoutRequestCopyWithImpl<$Res>
    implements _$CheckoutRequestCopyWith<$Res> {
  __$CheckoutRequestCopyWithImpl(this._self, this._then);

  final _CheckoutRequest _self;
  final $Res Function(_CheckoutRequest) _then;

/// Create a copy of CheckoutRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shippingAddress = null,Object? billingAddress = freezed,Object? customerName = null,Object? customerEmail = null,Object? customerPhone = freezed,Object? customerDocument = freezed,Object? customerFiscalData = freezed,Object? shippingMethod = null,Object? paymentMethod = null,Object? couponCode = freezed,Object? customerNote = freezed,Object? sessionId = freezed,Object? affiliateId = freezed,}) {
  return _then(_CheckoutRequest(
shippingAddress: null == shippingAddress ? _self.shippingAddress : shippingAddress // ignore: cast_nullable_to_non_nullable
as ShippingAddress,billingAddress: freezed == billingAddress ? _self.billingAddress : billingAddress // ignore: cast_nullable_to_non_nullable
as ShippingAddress?,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerEmail: null == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,customerDocument: freezed == customerDocument ? _self.customerDocument : customerDocument // ignore: cast_nullable_to_non_nullable
as String?,customerFiscalData: freezed == customerFiscalData ? _self._customerFiscalData : customerFiscalData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,shippingMethod: null == shippingMethod ? _self.shippingMethod : shippingMethod // ignore: cast_nullable_to_non_nullable
as String,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,couponCode: freezed == couponCode ? _self.couponCode : couponCode // ignore: cast_nullable_to_non_nullable
as String?,customerNote: freezed == customerNote ? _self.customerNote : customerNote // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,affiliateId: freezed == affiliateId ? _self.affiliateId : affiliateId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CheckoutRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShippingAddressCopyWith<$Res> get shippingAddress {
  
  return $ShippingAddressCopyWith<$Res>(_self.shippingAddress, (value) {
    return _then(_self.copyWith(shippingAddress: value));
  });
}/// Create a copy of CheckoutRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShippingAddressCopyWith<$Res>? get billingAddress {
    if (_self.billingAddress == null) {
    return null;
  }

  return $ShippingAddressCopyWith<$Res>(_self.billingAddress!, (value) {
    return _then(_self.copyWith(billingAddress: value));
  });
}
}


/// @nodoc
mixin _$PaymentRequest {

@JsonKey(name: 'order_id') String get orderId; double get amount; String get method; Map<String, dynamic>? get metadata;
/// Create a copy of PaymentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentRequestCopyWith<PaymentRequest> get copyWith => _$PaymentRequestCopyWithImpl<PaymentRequest>(this as PaymentRequest, _$identity);

  /// Serializes this PaymentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentRequest&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.method, method) || other.method == method)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderId,amount,method,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'PaymentRequest(orderId: $orderId, amount: $amount, method: $method, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $PaymentRequestCopyWith<$Res>  {
  factory $PaymentRequestCopyWith(PaymentRequest value, $Res Function(PaymentRequest) _then) = _$PaymentRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'order_id') String orderId, double amount, String method, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$PaymentRequestCopyWithImpl<$Res>
    implements $PaymentRequestCopyWith<$Res> {
  _$PaymentRequestCopyWithImpl(this._self, this._then);

  final PaymentRequest _self;
  final $Res Function(PaymentRequest) _then;

/// Create a copy of PaymentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderId = null,Object? amount = null,Object? method = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentRequest].
extension PaymentRequestPatterns on PaymentRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentRequest value)  $default,){
final _that = this;
switch (_that) {
case _PaymentRequest():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'order_id')  String orderId,  double amount,  String method,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentRequest() when $default != null:
return $default(_that.orderId,_that.amount,_that.method,_that.metadata);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'order_id')  String orderId,  double amount,  String method,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _PaymentRequest():
return $default(_that.orderId,_that.amount,_that.method,_that.metadata);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'order_id')  String orderId,  double amount,  String method,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _PaymentRequest() when $default != null:
return $default(_that.orderId,_that.amount,_that.method,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentRequest implements PaymentRequest {
  const _PaymentRequest({@JsonKey(name: 'order_id') required this.orderId, required this.amount, required this.method, final  Map<String, dynamic>? metadata}): _metadata = metadata;
  factory _PaymentRequest.fromJson(Map<String, dynamic> json) => _$PaymentRequestFromJson(json);

@override@JsonKey(name: 'order_id') final  String orderId;
@override final  double amount;
@override final  String method;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of PaymentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentRequestCopyWith<_PaymentRequest> get copyWith => __$PaymentRequestCopyWithImpl<_PaymentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentRequest&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.method, method) || other.method == method)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderId,amount,method,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'PaymentRequest(orderId: $orderId, amount: $amount, method: $method, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$PaymentRequestCopyWith<$Res> implements $PaymentRequestCopyWith<$Res> {
  factory _$PaymentRequestCopyWith(_PaymentRequest value, $Res Function(_PaymentRequest) _then) = __$PaymentRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'order_id') String orderId, double amount, String method, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$PaymentRequestCopyWithImpl<$Res>
    implements _$PaymentRequestCopyWith<$Res> {
  __$PaymentRequestCopyWithImpl(this._self, this._then);

  final _PaymentRequest _self;
  final $Res Function(_PaymentRequest) _then;

/// Create a copy of PaymentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderId = null,Object? amount = null,Object? method = null,Object? metadata = freezed,}) {
  return _then(_PaymentRequest(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
