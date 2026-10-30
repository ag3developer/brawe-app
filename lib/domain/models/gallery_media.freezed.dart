// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gallery_media.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GalleryMedia {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'media_type') String get mediaType;// 'photo' | 'video'
 int get position; String get url;@JsonKey(name: 'thumbnail_url') String? get thumbnailUrl;/// Versão leve do vídeo (HLS do Bunny), quando já foi convertido.
@JsonKey(name: 'hls_url') String? get hlsUrl; String? get caption; int? get width; int? get height;@JsonKey(name: 'duration_seconds') int? get durationSeconds;@JsonKey(name: 'file_size') int? get fileSize;@JsonKey(name: 'mime_type') String? get mimeType;@JsonKey(name: 'views_count') int get viewsCount;@JsonKey(name: 'likes_count') int get likesCount;@JsonKey(name: 'is_liked') bool get isLiked;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of GalleryMedia
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GalleryMediaCopyWith<GalleryMedia> get copyWith => _$GalleryMediaCopyWithImpl<GalleryMedia>(this as GalleryMedia, _$identity);

  /// Serializes this GalleryMedia to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GalleryMedia&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.position, position) || other.position == position)&&(identical(other.url, url) || other.url == url)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.hlsUrl, hlsUrl) || other.hlsUrl == hlsUrl)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,mediaType,position,url,thumbnailUrl,hlsUrl,caption,width,height,durationSeconds,fileSize,mimeType,viewsCount,likesCount,isLiked,createdAt);

@override
String toString() {
  return 'GalleryMedia(id: $id, userId: $userId, mediaType: $mediaType, position: $position, url: $url, thumbnailUrl: $thumbnailUrl, hlsUrl: $hlsUrl, caption: $caption, width: $width, height: $height, durationSeconds: $durationSeconds, fileSize: $fileSize, mimeType: $mimeType, viewsCount: $viewsCount, likesCount: $likesCount, isLiked: $isLiked, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GalleryMediaCopyWith<$Res>  {
  factory $GalleryMediaCopyWith(GalleryMedia value, $Res Function(GalleryMedia) _then) = _$GalleryMediaCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'media_type') String mediaType, int position, String url,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'hls_url') String? hlsUrl, String? caption, int? width, int? height,@JsonKey(name: 'duration_seconds') int? durationSeconds,@JsonKey(name: 'file_size') int? fileSize,@JsonKey(name: 'mime_type') String? mimeType,@JsonKey(name: 'views_count') int viewsCount,@JsonKey(name: 'likes_count') int likesCount,@JsonKey(name: 'is_liked') bool isLiked,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$GalleryMediaCopyWithImpl<$Res>
    implements $GalleryMediaCopyWith<$Res> {
  _$GalleryMediaCopyWithImpl(this._self, this._then);

  final GalleryMedia _self;
  final $Res Function(GalleryMedia) _then;

/// Create a copy of GalleryMedia
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? mediaType = null,Object? position = null,Object? url = null,Object? thumbnailUrl = freezed,Object? hlsUrl = freezed,Object? caption = freezed,Object? width = freezed,Object? height = freezed,Object? durationSeconds = freezed,Object? fileSize = freezed,Object? mimeType = freezed,Object? viewsCount = null,Object? likesCount = null,Object? isLiked = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,hlsUrl: freezed == hlsUrl ? _self.hlsUrl : hlsUrl // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GalleryMedia].
extension GalleryMediaPatterns on GalleryMedia {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GalleryMedia value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GalleryMedia() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GalleryMedia value)  $default,){
final _that = this;
switch (_that) {
case _GalleryMedia():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GalleryMedia value)?  $default,){
final _that = this;
switch (_that) {
case _GalleryMedia() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'media_type')  String mediaType,  int position,  String url, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'hls_url')  String? hlsUrl,  String? caption,  int? width,  int? height, @JsonKey(name: 'duration_seconds')  int? durationSeconds, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'mime_type')  String? mimeType, @JsonKey(name: 'views_count')  int viewsCount, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'is_liked')  bool isLiked, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GalleryMedia() when $default != null:
return $default(_that.id,_that.userId,_that.mediaType,_that.position,_that.url,_that.thumbnailUrl,_that.hlsUrl,_that.caption,_that.width,_that.height,_that.durationSeconds,_that.fileSize,_that.mimeType,_that.viewsCount,_that.likesCount,_that.isLiked,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'media_type')  String mediaType,  int position,  String url, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'hls_url')  String? hlsUrl,  String? caption,  int? width,  int? height, @JsonKey(name: 'duration_seconds')  int? durationSeconds, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'mime_type')  String? mimeType, @JsonKey(name: 'views_count')  int viewsCount, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'is_liked')  bool isLiked, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _GalleryMedia():
return $default(_that.id,_that.userId,_that.mediaType,_that.position,_that.url,_that.thumbnailUrl,_that.hlsUrl,_that.caption,_that.width,_that.height,_that.durationSeconds,_that.fileSize,_that.mimeType,_that.viewsCount,_that.likesCount,_that.isLiked,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'media_type')  String mediaType,  int position,  String url, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'hls_url')  String? hlsUrl,  String? caption,  int? width,  int? height, @JsonKey(name: 'duration_seconds')  int? durationSeconds, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'mime_type')  String? mimeType, @JsonKey(name: 'views_count')  int viewsCount, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'is_liked')  bool isLiked, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GalleryMedia() when $default != null:
return $default(_that.id,_that.userId,_that.mediaType,_that.position,_that.url,_that.thumbnailUrl,_that.hlsUrl,_that.caption,_that.width,_that.height,_that.durationSeconds,_that.fileSize,_that.mimeType,_that.viewsCount,_that.likesCount,_that.isLiked,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GalleryMedia implements GalleryMedia {
  const _GalleryMedia({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'media_type') required this.mediaType, this.position = 0, required this.url, @JsonKey(name: 'thumbnail_url') this.thumbnailUrl, @JsonKey(name: 'hls_url') this.hlsUrl, this.caption, this.width, this.height, @JsonKey(name: 'duration_seconds') this.durationSeconds, @JsonKey(name: 'file_size') this.fileSize, @JsonKey(name: 'mime_type') this.mimeType, @JsonKey(name: 'views_count') this.viewsCount = 0, @JsonKey(name: 'likes_count') this.likesCount = 0, @JsonKey(name: 'is_liked') this.isLiked = false, @JsonKey(name: 'created_at') this.createdAt});
  factory _GalleryMedia.fromJson(Map<String, dynamic> json) => _$GalleryMediaFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'media_type') final  String mediaType;
// 'photo' | 'video'
@override@JsonKey() final  int position;
@override final  String url;
@override@JsonKey(name: 'thumbnail_url') final  String? thumbnailUrl;
/// Versão leve do vídeo (HLS do Bunny), quando já foi convertido.
@override@JsonKey(name: 'hls_url') final  String? hlsUrl;
@override final  String? caption;
@override final  int? width;
@override final  int? height;
@override@JsonKey(name: 'duration_seconds') final  int? durationSeconds;
@override@JsonKey(name: 'file_size') final  int? fileSize;
@override@JsonKey(name: 'mime_type') final  String? mimeType;
@override@JsonKey(name: 'views_count') final  int viewsCount;
@override@JsonKey(name: 'likes_count') final  int likesCount;
@override@JsonKey(name: 'is_liked') final  bool isLiked;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of GalleryMedia
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GalleryMediaCopyWith<_GalleryMedia> get copyWith => __$GalleryMediaCopyWithImpl<_GalleryMedia>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GalleryMediaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GalleryMedia&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.position, position) || other.position == position)&&(identical(other.url, url) || other.url == url)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.hlsUrl, hlsUrl) || other.hlsUrl == hlsUrl)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,mediaType,position,url,thumbnailUrl,hlsUrl,caption,width,height,durationSeconds,fileSize,mimeType,viewsCount,likesCount,isLiked,createdAt);

@override
String toString() {
  return 'GalleryMedia(id: $id, userId: $userId, mediaType: $mediaType, position: $position, url: $url, thumbnailUrl: $thumbnailUrl, hlsUrl: $hlsUrl, caption: $caption, width: $width, height: $height, durationSeconds: $durationSeconds, fileSize: $fileSize, mimeType: $mimeType, viewsCount: $viewsCount, likesCount: $likesCount, isLiked: $isLiked, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GalleryMediaCopyWith<$Res> implements $GalleryMediaCopyWith<$Res> {
  factory _$GalleryMediaCopyWith(_GalleryMedia value, $Res Function(_GalleryMedia) _then) = __$GalleryMediaCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'media_type') String mediaType, int position, String url,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'hls_url') String? hlsUrl, String? caption, int? width, int? height,@JsonKey(name: 'duration_seconds') int? durationSeconds,@JsonKey(name: 'file_size') int? fileSize,@JsonKey(name: 'mime_type') String? mimeType,@JsonKey(name: 'views_count') int viewsCount,@JsonKey(name: 'likes_count') int likesCount,@JsonKey(name: 'is_liked') bool isLiked,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$GalleryMediaCopyWithImpl<$Res>
    implements _$GalleryMediaCopyWith<$Res> {
  __$GalleryMediaCopyWithImpl(this._self, this._then);

  final _GalleryMedia _self;
  final $Res Function(_GalleryMedia) _then;

/// Create a copy of GalleryMedia
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? mediaType = null,Object? position = null,Object? url = null,Object? thumbnailUrl = freezed,Object? hlsUrl = freezed,Object? caption = freezed,Object? width = freezed,Object? height = freezed,Object? durationSeconds = freezed,Object? fileSize = freezed,Object? mimeType = freezed,Object? viewsCount = null,Object? likesCount = null,Object? isLiked = null,Object? createdAt = freezed,}) {
  return _then(_GalleryMedia(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,hlsUrl: freezed == hlsUrl ? _self.hlsUrl : hlsUrl // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$GalleryLimits {

@JsonKey(name: 'max_photos') int get maxPhotos;@JsonKey(name: 'max_videos') int get maxVideos;@JsonKey(name: 'photos_remaining') int get photosRemaining;@JsonKey(name: 'videos_remaining') int get videosRemaining;
/// Create a copy of GalleryLimits
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GalleryLimitsCopyWith<GalleryLimits> get copyWith => _$GalleryLimitsCopyWithImpl<GalleryLimits>(this as GalleryLimits, _$identity);

  /// Serializes this GalleryLimits to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GalleryLimits&&(identical(other.maxPhotos, maxPhotos) || other.maxPhotos == maxPhotos)&&(identical(other.maxVideos, maxVideos) || other.maxVideos == maxVideos)&&(identical(other.photosRemaining, photosRemaining) || other.photosRemaining == photosRemaining)&&(identical(other.videosRemaining, videosRemaining) || other.videosRemaining == videosRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maxPhotos,maxVideos,photosRemaining,videosRemaining);

@override
String toString() {
  return 'GalleryLimits(maxPhotos: $maxPhotos, maxVideos: $maxVideos, photosRemaining: $photosRemaining, videosRemaining: $videosRemaining)';
}


}

/// @nodoc
abstract mixin class $GalleryLimitsCopyWith<$Res>  {
  factory $GalleryLimitsCopyWith(GalleryLimits value, $Res Function(GalleryLimits) _then) = _$GalleryLimitsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'max_photos') int maxPhotos,@JsonKey(name: 'max_videos') int maxVideos,@JsonKey(name: 'photos_remaining') int photosRemaining,@JsonKey(name: 'videos_remaining') int videosRemaining
});




}
/// @nodoc
class _$GalleryLimitsCopyWithImpl<$Res>
    implements $GalleryLimitsCopyWith<$Res> {
  _$GalleryLimitsCopyWithImpl(this._self, this._then);

  final GalleryLimits _self;
  final $Res Function(GalleryLimits) _then;

/// Create a copy of GalleryLimits
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maxPhotos = null,Object? maxVideos = null,Object? photosRemaining = null,Object? videosRemaining = null,}) {
  return _then(_self.copyWith(
maxPhotos: null == maxPhotos ? _self.maxPhotos : maxPhotos // ignore: cast_nullable_to_non_nullable
as int,maxVideos: null == maxVideos ? _self.maxVideos : maxVideos // ignore: cast_nullable_to_non_nullable
as int,photosRemaining: null == photosRemaining ? _self.photosRemaining : photosRemaining // ignore: cast_nullable_to_non_nullable
as int,videosRemaining: null == videosRemaining ? _self.videosRemaining : videosRemaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GalleryLimits].
extension GalleryLimitsPatterns on GalleryLimits {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GalleryLimits value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GalleryLimits() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GalleryLimits value)  $default,){
final _that = this;
switch (_that) {
case _GalleryLimits():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GalleryLimits value)?  $default,){
final _that = this;
switch (_that) {
case _GalleryLimits() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'max_photos')  int maxPhotos, @JsonKey(name: 'max_videos')  int maxVideos, @JsonKey(name: 'photos_remaining')  int photosRemaining, @JsonKey(name: 'videos_remaining')  int videosRemaining)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GalleryLimits() when $default != null:
return $default(_that.maxPhotos,_that.maxVideos,_that.photosRemaining,_that.videosRemaining);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'max_photos')  int maxPhotos, @JsonKey(name: 'max_videos')  int maxVideos, @JsonKey(name: 'photos_remaining')  int photosRemaining, @JsonKey(name: 'videos_remaining')  int videosRemaining)  $default,) {final _that = this;
switch (_that) {
case _GalleryLimits():
return $default(_that.maxPhotos,_that.maxVideos,_that.photosRemaining,_that.videosRemaining);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'max_photos')  int maxPhotos, @JsonKey(name: 'max_videos')  int maxVideos, @JsonKey(name: 'photos_remaining')  int photosRemaining, @JsonKey(name: 'videos_remaining')  int videosRemaining)?  $default,) {final _that = this;
switch (_that) {
case _GalleryLimits() when $default != null:
return $default(_that.maxPhotos,_that.maxVideos,_that.photosRemaining,_that.videosRemaining);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GalleryLimits implements GalleryLimits {
  const _GalleryLimits({@JsonKey(name: 'max_photos') this.maxPhotos = 6, @JsonKey(name: 'max_videos') this.maxVideos = 3, @JsonKey(name: 'photos_remaining') this.photosRemaining = 6, @JsonKey(name: 'videos_remaining') this.videosRemaining = 3});
  factory _GalleryLimits.fromJson(Map<String, dynamic> json) => _$GalleryLimitsFromJson(json);

@override@JsonKey(name: 'max_photos') final  int maxPhotos;
@override@JsonKey(name: 'max_videos') final  int maxVideos;
@override@JsonKey(name: 'photos_remaining') final  int photosRemaining;
@override@JsonKey(name: 'videos_remaining') final  int videosRemaining;

/// Create a copy of GalleryLimits
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GalleryLimitsCopyWith<_GalleryLimits> get copyWith => __$GalleryLimitsCopyWithImpl<_GalleryLimits>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GalleryLimitsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GalleryLimits&&(identical(other.maxPhotos, maxPhotos) || other.maxPhotos == maxPhotos)&&(identical(other.maxVideos, maxVideos) || other.maxVideos == maxVideos)&&(identical(other.photosRemaining, photosRemaining) || other.photosRemaining == photosRemaining)&&(identical(other.videosRemaining, videosRemaining) || other.videosRemaining == videosRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maxPhotos,maxVideos,photosRemaining,videosRemaining);

@override
String toString() {
  return 'GalleryLimits(maxPhotos: $maxPhotos, maxVideos: $maxVideos, photosRemaining: $photosRemaining, videosRemaining: $videosRemaining)';
}


}

/// @nodoc
abstract mixin class _$GalleryLimitsCopyWith<$Res> implements $GalleryLimitsCopyWith<$Res> {
  factory _$GalleryLimitsCopyWith(_GalleryLimits value, $Res Function(_GalleryLimits) _then) = __$GalleryLimitsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'max_photos') int maxPhotos,@JsonKey(name: 'max_videos') int maxVideos,@JsonKey(name: 'photos_remaining') int photosRemaining,@JsonKey(name: 'videos_remaining') int videosRemaining
});




}
/// @nodoc
class __$GalleryLimitsCopyWithImpl<$Res>
    implements _$GalleryLimitsCopyWith<$Res> {
  __$GalleryLimitsCopyWithImpl(this._self, this._then);

  final _GalleryLimits _self;
  final $Res Function(_GalleryLimits) _then;

/// Create a copy of GalleryLimits
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maxPhotos = null,Object? maxVideos = null,Object? photosRemaining = null,Object? videosRemaining = null,}) {
  return _then(_GalleryLimits(
maxPhotos: null == maxPhotos ? _self.maxPhotos : maxPhotos // ignore: cast_nullable_to_non_nullable
as int,maxVideos: null == maxVideos ? _self.maxVideos : maxVideos // ignore: cast_nullable_to_non_nullable
as int,photosRemaining: null == photosRemaining ? _self.photosRemaining : photosRemaining // ignore: cast_nullable_to_non_nullable
as int,videosRemaining: null == videosRemaining ? _self.videosRemaining : videosRemaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GalleryData {

 List<GalleryMedia> get photos; List<GalleryMedia> get videos; GalleryLimits? get limits;
/// Create a copy of GalleryData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GalleryDataCopyWith<GalleryData> get copyWith => _$GalleryDataCopyWithImpl<GalleryData>(this as GalleryData, _$identity);

  /// Serializes this GalleryData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GalleryData&&const DeepCollectionEquality().equals(other.photos, photos)&&const DeepCollectionEquality().equals(other.videos, videos)&&(identical(other.limits, limits) || other.limits == limits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(photos),const DeepCollectionEquality().hash(videos),limits);

@override
String toString() {
  return 'GalleryData(photos: $photos, videos: $videos, limits: $limits)';
}


}

/// @nodoc
abstract mixin class $GalleryDataCopyWith<$Res>  {
  factory $GalleryDataCopyWith(GalleryData value, $Res Function(GalleryData) _then) = _$GalleryDataCopyWithImpl;
@useResult
$Res call({
 List<GalleryMedia> photos, List<GalleryMedia> videos, GalleryLimits? limits
});


$GalleryLimitsCopyWith<$Res>? get limits;

}
/// @nodoc
class _$GalleryDataCopyWithImpl<$Res>
    implements $GalleryDataCopyWith<$Res> {
  _$GalleryDataCopyWithImpl(this._self, this._then);

  final GalleryData _self;
  final $Res Function(GalleryData) _then;

/// Create a copy of GalleryData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? photos = null,Object? videos = null,Object? limits = freezed,}) {
  return _then(_self.copyWith(
photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<GalleryMedia>,videos: null == videos ? _self.videos : videos // ignore: cast_nullable_to_non_nullable
as List<GalleryMedia>,limits: freezed == limits ? _self.limits : limits // ignore: cast_nullable_to_non_nullable
as GalleryLimits?,
  ));
}
/// Create a copy of GalleryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GalleryLimitsCopyWith<$Res>? get limits {
    if (_self.limits == null) {
    return null;
  }

  return $GalleryLimitsCopyWith<$Res>(_self.limits!, (value) {
    return _then(_self.copyWith(limits: value));
  });
}
}


/// Adds pattern-matching-related methods to [GalleryData].
extension GalleryDataPatterns on GalleryData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GalleryData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GalleryData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GalleryData value)  $default,){
final _that = this;
switch (_that) {
case _GalleryData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GalleryData value)?  $default,){
final _that = this;
switch (_that) {
case _GalleryData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GalleryMedia> photos,  List<GalleryMedia> videos,  GalleryLimits? limits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GalleryData() when $default != null:
return $default(_that.photos,_that.videos,_that.limits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GalleryMedia> photos,  List<GalleryMedia> videos,  GalleryLimits? limits)  $default,) {final _that = this;
switch (_that) {
case _GalleryData():
return $default(_that.photos,_that.videos,_that.limits);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GalleryMedia> photos,  List<GalleryMedia> videos,  GalleryLimits? limits)?  $default,) {final _that = this;
switch (_that) {
case _GalleryData() when $default != null:
return $default(_that.photos,_that.videos,_that.limits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GalleryData implements GalleryData {
  const _GalleryData({final  List<GalleryMedia> photos = const <GalleryMedia>[], final  List<GalleryMedia> videos = const <GalleryMedia>[], this.limits}): _photos = photos,_videos = videos;
  factory _GalleryData.fromJson(Map<String, dynamic> json) => _$GalleryDataFromJson(json);

 final  List<GalleryMedia> _photos;
@override@JsonKey() List<GalleryMedia> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

 final  List<GalleryMedia> _videos;
@override@JsonKey() List<GalleryMedia> get videos {
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videos);
}

@override final  GalleryLimits? limits;

/// Create a copy of GalleryData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GalleryDataCopyWith<_GalleryData> get copyWith => __$GalleryDataCopyWithImpl<_GalleryData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GalleryDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GalleryData&&const DeepCollectionEquality().equals(other._photos, _photos)&&const DeepCollectionEquality().equals(other._videos, _videos)&&(identical(other.limits, limits) || other.limits == limits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_photos),const DeepCollectionEquality().hash(_videos),limits);

@override
String toString() {
  return 'GalleryData(photos: $photos, videos: $videos, limits: $limits)';
}


}

/// @nodoc
abstract mixin class _$GalleryDataCopyWith<$Res> implements $GalleryDataCopyWith<$Res> {
  factory _$GalleryDataCopyWith(_GalleryData value, $Res Function(_GalleryData) _then) = __$GalleryDataCopyWithImpl;
@override @useResult
$Res call({
 List<GalleryMedia> photos, List<GalleryMedia> videos, GalleryLimits? limits
});


@override $GalleryLimitsCopyWith<$Res>? get limits;

}
/// @nodoc
class __$GalleryDataCopyWithImpl<$Res>
    implements _$GalleryDataCopyWith<$Res> {
  __$GalleryDataCopyWithImpl(this._self, this._then);

  final _GalleryData _self;
  final $Res Function(_GalleryData) _then;

/// Create a copy of GalleryData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? photos = null,Object? videos = null,Object? limits = freezed,}) {
  return _then(_GalleryData(
photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<GalleryMedia>,videos: null == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<GalleryMedia>,limits: freezed == limits ? _self.limits : limits // ignore: cast_nullable_to_non_nullable
as GalleryLimits?,
  ));
}

/// Create a copy of GalleryData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GalleryLimitsCopyWith<$Res>? get limits {
    if (_self.limits == null) {
    return null;
  }

  return $GalleryLimitsCopyWith<$Res>(_self.limits!, (value) {
    return _then(_self.copyWith(limits: value));
  });
}
}

// dart format on
