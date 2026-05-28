// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthorResponseDto {

 String get id; String get name; String get username;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'is_verified') bool get isVerified;
/// Create a copy of AuthorResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthorResponseDtoCopyWith<AuthorResponseDto> get copyWith => _$AuthorResponseDtoCopyWithImpl<AuthorResponseDto>(this as AuthorResponseDto, _$identity);

  /// Serializes this AuthorResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthorResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,username,avatarUrl,isVerified);

@override
String toString() {
  return 'AuthorResponseDto(id: $id, name: $name, username: $username, avatarUrl: $avatarUrl, isVerified: $isVerified)';
}


}

/// @nodoc
abstract mixin class $AuthorResponseDtoCopyWith<$Res>  {
  factory $AuthorResponseDtoCopyWith(AuthorResponseDto value, $Res Function(AuthorResponseDto) _then) = _$AuthorResponseDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String username,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'is_verified') bool isVerified
});




}
/// @nodoc
class _$AuthorResponseDtoCopyWithImpl<$Res>
    implements $AuthorResponseDtoCopyWith<$Res> {
  _$AuthorResponseDtoCopyWithImpl(this._self, this._then);

  final AuthorResponseDto _self;
  final $Res Function(AuthorResponseDto) _then;

/// Create a copy of AuthorResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? username = null,Object? avatarUrl = freezed,Object? isVerified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthorResponseDto].
extension AuthorResponseDtoPatterns on AuthorResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthorResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthorResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthorResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _AuthorResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthorResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _AuthorResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String username, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_verified')  bool isVerified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthorResponseDto() when $default != null:
return $default(_that.id,_that.name,_that.username,_that.avatarUrl,_that.isVerified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String username, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_verified')  bool isVerified)  $default,) {final _that = this;
switch (_that) {
case _AuthorResponseDto():
return $default(_that.id,_that.name,_that.username,_that.avatarUrl,_that.isVerified);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String username, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_verified')  bool isVerified)?  $default,) {final _that = this;
switch (_that) {
case _AuthorResponseDto() when $default != null:
return $default(_that.id,_that.name,_that.username,_that.avatarUrl,_that.isVerified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthorResponseDto implements AuthorResponseDto {
  const _AuthorResponseDto({required this.id, required this.name, required this.username, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'is_verified') this.isVerified = false});
  factory _AuthorResponseDto.fromJson(Map<String, dynamic> json) => _$AuthorResponseDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String username;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'is_verified') final  bool isVerified;

/// Create a copy of AuthorResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthorResponseDtoCopyWith<_AuthorResponseDto> get copyWith => __$AuthorResponseDtoCopyWithImpl<_AuthorResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthorResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthorResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,username,avatarUrl,isVerified);

@override
String toString() {
  return 'AuthorResponseDto(id: $id, name: $name, username: $username, avatarUrl: $avatarUrl, isVerified: $isVerified)';
}


}

/// @nodoc
abstract mixin class _$AuthorResponseDtoCopyWith<$Res> implements $AuthorResponseDtoCopyWith<$Res> {
  factory _$AuthorResponseDtoCopyWith(_AuthorResponseDto value, $Res Function(_AuthorResponseDto) _then) = __$AuthorResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String username,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'is_verified') bool isVerified
});




}
/// @nodoc
class __$AuthorResponseDtoCopyWithImpl<$Res>
    implements _$AuthorResponseDtoCopyWith<$Res> {
  __$AuthorResponseDtoCopyWithImpl(this._self, this._then);

  final _AuthorResponseDto _self;
  final $Res Function(_AuthorResponseDto) _then;

/// Create a copy of AuthorResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? username = null,Object? avatarUrl = freezed,Object? isVerified = null,}) {
  return _then(_AuthorResponseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PostResponseDto {

 String get id; String get content;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'likes_count') int get likesCount;@JsonKey(name: 'comments_count') int get commentsCount;@JsonKey(name: 'reposts_count') int get repostsCount;@JsonKey(name: 'views_count') int get viewsCount;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt; AuthorResponseDto get author;@JsonKey(name: 'user_liked') bool get userLiked;@JsonKey(name: 'user_reposted') bool get userReposted;@JsonKey(name: 'user_following_author') bool get userFollowingAuthor;@JsonKey(name: 'reposted_by') AuthorResponseDto? get repostedBy;@JsonKey(name: 'repost_created_at') String? get repostCreatedAt;
/// Create a copy of PostResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostResponseDtoCopyWith<PostResponseDto> get copyWith => _$PostResponseDtoCopyWithImpl<PostResponseDto>(this as PostResponseDto, _$identity);

  /// Serializes this PostResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&(identical(other.repostsCount, repostsCount) || other.repostsCount == repostsCount)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.author, author) || other.author == author)&&(identical(other.userLiked, userLiked) || other.userLiked == userLiked)&&(identical(other.userReposted, userReposted) || other.userReposted == userReposted)&&(identical(other.userFollowingAuthor, userFollowingAuthor) || other.userFollowingAuthor == userFollowingAuthor)&&(identical(other.repostedBy, repostedBy) || other.repostedBy == repostedBy)&&(identical(other.repostCreatedAt, repostCreatedAt) || other.repostCreatedAt == repostCreatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,imageUrl,likesCount,commentsCount,repostsCount,viewsCount,createdAt,updatedAt,author,userLiked,userReposted,userFollowingAuthor,repostedBy,repostCreatedAt);

@override
String toString() {
  return 'PostResponseDto(id: $id, content: $content, imageUrl: $imageUrl, likesCount: $likesCount, commentsCount: $commentsCount, repostsCount: $repostsCount, viewsCount: $viewsCount, createdAt: $createdAt, updatedAt: $updatedAt, author: $author, userLiked: $userLiked, userReposted: $userReposted, userFollowingAuthor: $userFollowingAuthor, repostedBy: $repostedBy, repostCreatedAt: $repostCreatedAt)';
}


}

/// @nodoc
abstract mixin class $PostResponseDtoCopyWith<$Res>  {
  factory $PostResponseDtoCopyWith(PostResponseDto value, $Res Function(PostResponseDto) _then) = _$PostResponseDtoCopyWithImpl;
@useResult
$Res call({
 String id, String content,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'likes_count') int likesCount,@JsonKey(name: 'comments_count') int commentsCount,@JsonKey(name: 'reposts_count') int repostsCount,@JsonKey(name: 'views_count') int viewsCount,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, AuthorResponseDto author,@JsonKey(name: 'user_liked') bool userLiked,@JsonKey(name: 'user_reposted') bool userReposted,@JsonKey(name: 'user_following_author') bool userFollowingAuthor,@JsonKey(name: 'reposted_by') AuthorResponseDto? repostedBy,@JsonKey(name: 'repost_created_at') String? repostCreatedAt
});


$AuthorResponseDtoCopyWith<$Res> get author;$AuthorResponseDtoCopyWith<$Res>? get repostedBy;

}
/// @nodoc
class _$PostResponseDtoCopyWithImpl<$Res>
    implements $PostResponseDtoCopyWith<$Res> {
  _$PostResponseDtoCopyWithImpl(this._self, this._then);

  final PostResponseDto _self;
  final $Res Function(PostResponseDto) _then;

/// Create a copy of PostResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? imageUrl = freezed,Object? likesCount = null,Object? commentsCount = null,Object? repostsCount = null,Object? viewsCount = null,Object? createdAt = null,Object? updatedAt = null,Object? author = null,Object? userLiked = null,Object? userReposted = null,Object? userFollowingAuthor = null,Object? repostedBy = freezed,Object? repostCreatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,repostsCount: null == repostsCount ? _self.repostsCount : repostsCount // ignore: cast_nullable_to_non_nullable
as int,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as AuthorResponseDto,userLiked: null == userLiked ? _self.userLiked : userLiked // ignore: cast_nullable_to_non_nullable
as bool,userReposted: null == userReposted ? _self.userReposted : userReposted // ignore: cast_nullable_to_non_nullable
as bool,userFollowingAuthor: null == userFollowingAuthor ? _self.userFollowingAuthor : userFollowingAuthor // ignore: cast_nullable_to_non_nullable
as bool,repostedBy: freezed == repostedBy ? _self.repostedBy : repostedBy // ignore: cast_nullable_to_non_nullable
as AuthorResponseDto?,repostCreatedAt: freezed == repostCreatedAt ? _self.repostCreatedAt : repostCreatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PostResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorResponseDtoCopyWith<$Res> get author {
  
  return $AuthorResponseDtoCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of PostResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorResponseDtoCopyWith<$Res>? get repostedBy {
    if (_self.repostedBy == null) {
    return null;
  }

  return $AuthorResponseDtoCopyWith<$Res>(_self.repostedBy!, (value) {
    return _then(_self.copyWith(repostedBy: value));
  });
}
}


/// Adds pattern-matching-related methods to [PostResponseDto].
extension PostResponseDtoPatterns on PostResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _PostResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _PostResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String content, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'comments_count')  int commentsCount, @JsonKey(name: 'reposts_count')  int repostsCount, @JsonKey(name: 'views_count')  int viewsCount, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  AuthorResponseDto author, @JsonKey(name: 'user_liked')  bool userLiked, @JsonKey(name: 'user_reposted')  bool userReposted, @JsonKey(name: 'user_following_author')  bool userFollowingAuthor, @JsonKey(name: 'reposted_by')  AuthorResponseDto? repostedBy, @JsonKey(name: 'repost_created_at')  String? repostCreatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostResponseDto() when $default != null:
return $default(_that.id,_that.content,_that.imageUrl,_that.likesCount,_that.commentsCount,_that.repostsCount,_that.viewsCount,_that.createdAt,_that.updatedAt,_that.author,_that.userLiked,_that.userReposted,_that.userFollowingAuthor,_that.repostedBy,_that.repostCreatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String content, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'comments_count')  int commentsCount, @JsonKey(name: 'reposts_count')  int repostsCount, @JsonKey(name: 'views_count')  int viewsCount, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  AuthorResponseDto author, @JsonKey(name: 'user_liked')  bool userLiked, @JsonKey(name: 'user_reposted')  bool userReposted, @JsonKey(name: 'user_following_author')  bool userFollowingAuthor, @JsonKey(name: 'reposted_by')  AuthorResponseDto? repostedBy, @JsonKey(name: 'repost_created_at')  String? repostCreatedAt)  $default,) {final _that = this;
switch (_that) {
case _PostResponseDto():
return $default(_that.id,_that.content,_that.imageUrl,_that.likesCount,_that.commentsCount,_that.repostsCount,_that.viewsCount,_that.createdAt,_that.updatedAt,_that.author,_that.userLiked,_that.userReposted,_that.userFollowingAuthor,_that.repostedBy,_that.repostCreatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String content, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'likes_count')  int likesCount, @JsonKey(name: 'comments_count')  int commentsCount, @JsonKey(name: 'reposts_count')  int repostsCount, @JsonKey(name: 'views_count')  int viewsCount, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  AuthorResponseDto author, @JsonKey(name: 'user_liked')  bool userLiked, @JsonKey(name: 'user_reposted')  bool userReposted, @JsonKey(name: 'user_following_author')  bool userFollowingAuthor, @JsonKey(name: 'reposted_by')  AuthorResponseDto? repostedBy, @JsonKey(name: 'repost_created_at')  String? repostCreatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PostResponseDto() when $default != null:
return $default(_that.id,_that.content,_that.imageUrl,_that.likesCount,_that.commentsCount,_that.repostsCount,_that.viewsCount,_that.createdAt,_that.updatedAt,_that.author,_that.userLiked,_that.userReposted,_that.userFollowingAuthor,_that.repostedBy,_that.repostCreatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostResponseDto implements PostResponseDto {
  const _PostResponseDto({required this.id, required this.content, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'likes_count') required this.likesCount, @JsonKey(name: 'comments_count') required this.commentsCount, @JsonKey(name: 'reposts_count') required this.repostsCount, @JsonKey(name: 'views_count') required this.viewsCount, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, required this.author, @JsonKey(name: 'user_liked') this.userLiked = false, @JsonKey(name: 'user_reposted') this.userReposted = false, @JsonKey(name: 'user_following_author') this.userFollowingAuthor = false, @JsonKey(name: 'reposted_by') this.repostedBy, @JsonKey(name: 'repost_created_at') this.repostCreatedAt});
  factory _PostResponseDto.fromJson(Map<String, dynamic> json) => _$PostResponseDtoFromJson(json);

@override final  String id;
@override final  String content;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override@JsonKey(name: 'likes_count') final  int likesCount;
@override@JsonKey(name: 'comments_count') final  int commentsCount;
@override@JsonKey(name: 'reposts_count') final  int repostsCount;
@override@JsonKey(name: 'views_count') final  int viewsCount;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;
@override final  AuthorResponseDto author;
@override@JsonKey(name: 'user_liked') final  bool userLiked;
@override@JsonKey(name: 'user_reposted') final  bool userReposted;
@override@JsonKey(name: 'user_following_author') final  bool userFollowingAuthor;
@override@JsonKey(name: 'reposted_by') final  AuthorResponseDto? repostedBy;
@override@JsonKey(name: 'repost_created_at') final  String? repostCreatedAt;

/// Create a copy of PostResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostResponseDtoCopyWith<_PostResponseDto> get copyWith => __$PostResponseDtoCopyWithImpl<_PostResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&(identical(other.repostsCount, repostsCount) || other.repostsCount == repostsCount)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.author, author) || other.author == author)&&(identical(other.userLiked, userLiked) || other.userLiked == userLiked)&&(identical(other.userReposted, userReposted) || other.userReposted == userReposted)&&(identical(other.userFollowingAuthor, userFollowingAuthor) || other.userFollowingAuthor == userFollowingAuthor)&&(identical(other.repostedBy, repostedBy) || other.repostedBy == repostedBy)&&(identical(other.repostCreatedAt, repostCreatedAt) || other.repostCreatedAt == repostCreatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,imageUrl,likesCount,commentsCount,repostsCount,viewsCount,createdAt,updatedAt,author,userLiked,userReposted,userFollowingAuthor,repostedBy,repostCreatedAt);

@override
String toString() {
  return 'PostResponseDto(id: $id, content: $content, imageUrl: $imageUrl, likesCount: $likesCount, commentsCount: $commentsCount, repostsCount: $repostsCount, viewsCount: $viewsCount, createdAt: $createdAt, updatedAt: $updatedAt, author: $author, userLiked: $userLiked, userReposted: $userReposted, userFollowingAuthor: $userFollowingAuthor, repostedBy: $repostedBy, repostCreatedAt: $repostCreatedAt)';
}


}

/// @nodoc
abstract mixin class _$PostResponseDtoCopyWith<$Res> implements $PostResponseDtoCopyWith<$Res> {
  factory _$PostResponseDtoCopyWith(_PostResponseDto value, $Res Function(_PostResponseDto) _then) = __$PostResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String content,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'likes_count') int likesCount,@JsonKey(name: 'comments_count') int commentsCount,@JsonKey(name: 'reposts_count') int repostsCount,@JsonKey(name: 'views_count') int viewsCount,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, AuthorResponseDto author,@JsonKey(name: 'user_liked') bool userLiked,@JsonKey(name: 'user_reposted') bool userReposted,@JsonKey(name: 'user_following_author') bool userFollowingAuthor,@JsonKey(name: 'reposted_by') AuthorResponseDto? repostedBy,@JsonKey(name: 'repost_created_at') String? repostCreatedAt
});


@override $AuthorResponseDtoCopyWith<$Res> get author;@override $AuthorResponseDtoCopyWith<$Res>? get repostedBy;

}
/// @nodoc
class __$PostResponseDtoCopyWithImpl<$Res>
    implements _$PostResponseDtoCopyWith<$Res> {
  __$PostResponseDtoCopyWithImpl(this._self, this._then);

  final _PostResponseDto _self;
  final $Res Function(_PostResponseDto) _then;

/// Create a copy of PostResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? imageUrl = freezed,Object? likesCount = null,Object? commentsCount = null,Object? repostsCount = null,Object? viewsCount = null,Object? createdAt = null,Object? updatedAt = null,Object? author = null,Object? userLiked = null,Object? userReposted = null,Object? userFollowingAuthor = null,Object? repostedBy = freezed,Object? repostCreatedAt = freezed,}) {
  return _then(_PostResponseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,repostsCount: null == repostsCount ? _self.repostsCount : repostsCount // ignore: cast_nullable_to_non_nullable
as int,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as AuthorResponseDto,userLiked: null == userLiked ? _self.userLiked : userLiked // ignore: cast_nullable_to_non_nullable
as bool,userReposted: null == userReposted ? _self.userReposted : userReposted // ignore: cast_nullable_to_non_nullable
as bool,userFollowingAuthor: null == userFollowingAuthor ? _self.userFollowingAuthor : userFollowingAuthor // ignore: cast_nullable_to_non_nullable
as bool,repostedBy: freezed == repostedBy ? _self.repostedBy : repostedBy // ignore: cast_nullable_to_non_nullable
as AuthorResponseDto?,repostCreatedAt: freezed == repostCreatedAt ? _self.repostCreatedAt : repostCreatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PostResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorResponseDtoCopyWith<$Res> get author {
  
  return $AuthorResponseDtoCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of PostResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorResponseDtoCopyWith<$Res>? get repostedBy {
    if (_self.repostedBy == null) {
    return null;
  }

  return $AuthorResponseDtoCopyWith<$Res>(_self.repostedBy!, (value) {
    return _then(_self.copyWith(repostedBy: value));
  });
}
}


/// @nodoc
mixin _$PostFeedResponseDto {

 List<PostResponseDto> get posts; int get total; int get limit; int get offset;
/// Create a copy of PostFeedResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostFeedResponseDtoCopyWith<PostFeedResponseDto> get copyWith => _$PostFeedResponseDtoCopyWithImpl<PostFeedResponseDto>(this as PostFeedResponseDto, _$identity);

  /// Serializes this PostFeedResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostFeedResponseDto&&const DeepCollectionEquality().equals(other.posts, posts)&&(identical(other.total, total) || other.total == total)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.offset, offset) || other.offset == offset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(posts),total,limit,offset);

@override
String toString() {
  return 'PostFeedResponseDto(posts: $posts, total: $total, limit: $limit, offset: $offset)';
}


}

/// @nodoc
abstract mixin class $PostFeedResponseDtoCopyWith<$Res>  {
  factory $PostFeedResponseDtoCopyWith(PostFeedResponseDto value, $Res Function(PostFeedResponseDto) _then) = _$PostFeedResponseDtoCopyWithImpl;
@useResult
$Res call({
 List<PostResponseDto> posts, int total, int limit, int offset
});




}
/// @nodoc
class _$PostFeedResponseDtoCopyWithImpl<$Res>
    implements $PostFeedResponseDtoCopyWith<$Res> {
  _$PostFeedResponseDtoCopyWithImpl(this._self, this._then);

  final PostFeedResponseDto _self;
  final $Res Function(PostFeedResponseDto) _then;

/// Create a copy of PostFeedResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? posts = null,Object? total = null,Object? limit = null,Object? offset = null,}) {
  return _then(_self.copyWith(
posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<PostResponseDto>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PostFeedResponseDto].
extension PostFeedResponseDtoPatterns on PostFeedResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostFeedResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostFeedResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostFeedResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _PostFeedResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostFeedResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _PostFeedResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PostResponseDto> posts,  int total,  int limit,  int offset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostFeedResponseDto() when $default != null:
return $default(_that.posts,_that.total,_that.limit,_that.offset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PostResponseDto> posts,  int total,  int limit,  int offset)  $default,) {final _that = this;
switch (_that) {
case _PostFeedResponseDto():
return $default(_that.posts,_that.total,_that.limit,_that.offset);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PostResponseDto> posts,  int total,  int limit,  int offset)?  $default,) {final _that = this;
switch (_that) {
case _PostFeedResponseDto() when $default != null:
return $default(_that.posts,_that.total,_that.limit,_that.offset);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostFeedResponseDto implements PostFeedResponseDto {
  const _PostFeedResponseDto({required final  List<PostResponseDto> posts, required this.total, required this.limit, required this.offset}): _posts = posts;
  factory _PostFeedResponseDto.fromJson(Map<String, dynamic> json) => _$PostFeedResponseDtoFromJson(json);

 final  List<PostResponseDto> _posts;
@override List<PostResponseDto> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

@override final  int total;
@override final  int limit;
@override final  int offset;

/// Create a copy of PostFeedResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostFeedResponseDtoCopyWith<_PostFeedResponseDto> get copyWith => __$PostFeedResponseDtoCopyWithImpl<_PostFeedResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostFeedResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostFeedResponseDto&&const DeepCollectionEquality().equals(other._posts, _posts)&&(identical(other.total, total) || other.total == total)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.offset, offset) || other.offset == offset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_posts),total,limit,offset);

@override
String toString() {
  return 'PostFeedResponseDto(posts: $posts, total: $total, limit: $limit, offset: $offset)';
}


}

/// @nodoc
abstract mixin class _$PostFeedResponseDtoCopyWith<$Res> implements $PostFeedResponseDtoCopyWith<$Res> {
  factory _$PostFeedResponseDtoCopyWith(_PostFeedResponseDto value, $Res Function(_PostFeedResponseDto) _then) = __$PostFeedResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 List<PostResponseDto> posts, int total, int limit, int offset
});




}
/// @nodoc
class __$PostFeedResponseDtoCopyWithImpl<$Res>
    implements _$PostFeedResponseDtoCopyWith<$Res> {
  __$PostFeedResponseDtoCopyWithImpl(this._self, this._then);

  final _PostFeedResponseDto _self;
  final $Res Function(_PostFeedResponseDto) _then;

/// Create a copy of PostFeedResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? posts = null,Object? total = null,Object? limit = null,Object? offset = null,}) {
  return _then(_PostFeedResponseDto(
posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<PostResponseDto>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
