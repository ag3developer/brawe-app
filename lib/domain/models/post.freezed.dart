// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Post {

 String get id; String get content; String? get imageUrl; int get likesCount; int get commentsCount; int get repostsCount; int get viewsCount; DateTime get createdAt; PostAuthor get author; bool get userLiked;@JsonKey(name: 'user_reaction_type') String? get userReactionType; bool get userReposted; bool get userFollowingAuthor;// Quando o item aparece no feed por causa de um repost de alguém,
// [repostedBy] traz o autor do repost. Frontend mostra "X repostou".
 PostAuthor? get repostedBy; DateTime? get repostCreatedAt;// Brawe Sound: música anexada ao post (opcional).
 SoundPreview? get sound;// Volume da música anexada (0.0-1.0) ESPECÍFICO deste post — a mesma
// faixa pode tocar com volumes diferentes em conteúdos diferentes.
@JsonKey(name: 'sound_volume') double get soundVolume;// Volume do áudio ORIGINAL do vídeo (0.0-1.0) quando há música
// anexada — permite ao autor abaixar/mutar o som próprio do vídeo
// pra não competir com a música do Brawe Sounds. Sem música anexada,
// este valor é ignorado (áudio original toca no volume nativo).
@JsonKey(name: 'original_audio_volume') double get originalAudioVolume;
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCopyWith<Post> get copyWith => _$PostCopyWithImpl<Post>(this as Post, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Post&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&(identical(other.repostsCount, repostsCount) || other.repostsCount == repostsCount)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.author, author) || other.author == author)&&(identical(other.userLiked, userLiked) || other.userLiked == userLiked)&&(identical(other.userReactionType, userReactionType) || other.userReactionType == userReactionType)&&(identical(other.userReposted, userReposted) || other.userReposted == userReposted)&&(identical(other.userFollowingAuthor, userFollowingAuthor) || other.userFollowingAuthor == userFollowingAuthor)&&(identical(other.repostedBy, repostedBy) || other.repostedBy == repostedBy)&&(identical(other.repostCreatedAt, repostCreatedAt) || other.repostCreatedAt == repostCreatedAt)&&(identical(other.sound, sound) || other.sound == sound)&&(identical(other.soundVolume, soundVolume) || other.soundVolume == soundVolume)&&(identical(other.originalAudioVolume, originalAudioVolume) || other.originalAudioVolume == originalAudioVolume));
}


@override
int get hashCode => Object.hash(runtimeType,id,content,imageUrl,likesCount,commentsCount,repostsCount,viewsCount,createdAt,author,userLiked,userReactionType,userReposted,userFollowingAuthor,repostedBy,repostCreatedAt,sound,soundVolume,originalAudioVolume);

@override
String toString() {
  return 'Post(id: $id, content: $content, imageUrl: $imageUrl, likesCount: $likesCount, commentsCount: $commentsCount, repostsCount: $repostsCount, viewsCount: $viewsCount, createdAt: $createdAt, author: $author, userLiked: $userLiked, userReactionType: $userReactionType, userReposted: $userReposted, userFollowingAuthor: $userFollowingAuthor, repostedBy: $repostedBy, repostCreatedAt: $repostCreatedAt, sound: $sound, soundVolume: $soundVolume, originalAudioVolume: $originalAudioVolume)';
}


}

/// @nodoc
abstract mixin class $PostCopyWith<$Res>  {
  factory $PostCopyWith(Post value, $Res Function(Post) _then) = _$PostCopyWithImpl;
@useResult
$Res call({
 String id, String content, String? imageUrl, int likesCount, int commentsCount, int repostsCount, int viewsCount, DateTime createdAt, PostAuthor author, bool userLiked,@JsonKey(name: 'user_reaction_type') String? userReactionType, bool userReposted, bool userFollowingAuthor, PostAuthor? repostedBy, DateTime? repostCreatedAt, SoundPreview? sound,@JsonKey(name: 'sound_volume') double soundVolume,@JsonKey(name: 'original_audio_volume') double originalAudioVolume
});


$PostAuthorCopyWith<$Res> get author;$PostAuthorCopyWith<$Res>? get repostedBy;$SoundPreviewCopyWith<$Res>? get sound;

}
/// @nodoc
class _$PostCopyWithImpl<$Res>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._self, this._then);

  final Post _self;
  final $Res Function(Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? imageUrl = freezed,Object? likesCount = null,Object? commentsCount = null,Object? repostsCount = null,Object? viewsCount = null,Object? createdAt = null,Object? author = null,Object? userLiked = null,Object? userReactionType = freezed,Object? userReposted = null,Object? userFollowingAuthor = null,Object? repostedBy = freezed,Object? repostCreatedAt = freezed,Object? sound = freezed,Object? soundVolume = null,Object? originalAudioVolume = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,repostsCount: null == repostsCount ? _self.repostsCount : repostsCount // ignore: cast_nullable_to_non_nullable
as int,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as PostAuthor,userLiked: null == userLiked ? _self.userLiked : userLiked // ignore: cast_nullable_to_non_nullable
as bool,userReactionType: freezed == userReactionType ? _self.userReactionType : userReactionType // ignore: cast_nullable_to_non_nullable
as String?,userReposted: null == userReposted ? _self.userReposted : userReposted // ignore: cast_nullable_to_non_nullable
as bool,userFollowingAuthor: null == userFollowingAuthor ? _self.userFollowingAuthor : userFollowingAuthor // ignore: cast_nullable_to_non_nullable
as bool,repostedBy: freezed == repostedBy ? _self.repostedBy : repostedBy // ignore: cast_nullable_to_non_nullable
as PostAuthor?,repostCreatedAt: freezed == repostCreatedAt ? _self.repostCreatedAt : repostCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sound: freezed == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as SoundPreview?,soundVolume: null == soundVolume ? _self.soundVolume : soundVolume // ignore: cast_nullable_to_non_nullable
as double,originalAudioVolume: null == originalAudioVolume ? _self.originalAudioVolume : originalAudioVolume // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostAuthorCopyWith<$Res> get author {
  
  return $PostAuthorCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostAuthorCopyWith<$Res>? get repostedBy {
    if (_self.repostedBy == null) {
    return null;
  }

  return $PostAuthorCopyWith<$Res>(_self.repostedBy!, (value) {
    return _then(_self.copyWith(repostedBy: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SoundPreviewCopyWith<$Res>? get sound {
    if (_self.sound == null) {
    return null;
  }

  return $SoundPreviewCopyWith<$Res>(_self.sound!, (value) {
    return _then(_self.copyWith(sound: value));
  });
}
}


/// Adds pattern-matching-related methods to [Post].
extension PostPatterns on Post {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Post value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Post value)  $default,){
final _that = this;
switch (_that) {
case _Post():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Post value)?  $default,){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String content,  String? imageUrl,  int likesCount,  int commentsCount,  int repostsCount,  int viewsCount,  DateTime createdAt,  PostAuthor author,  bool userLiked, @JsonKey(name: 'user_reaction_type')  String? userReactionType,  bool userReposted,  bool userFollowingAuthor,  PostAuthor? repostedBy,  DateTime? repostCreatedAt,  SoundPreview? sound, @JsonKey(name: 'sound_volume')  double soundVolume, @JsonKey(name: 'original_audio_volume')  double originalAudioVolume)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.content,_that.imageUrl,_that.likesCount,_that.commentsCount,_that.repostsCount,_that.viewsCount,_that.createdAt,_that.author,_that.userLiked,_that.userReactionType,_that.userReposted,_that.userFollowingAuthor,_that.repostedBy,_that.repostCreatedAt,_that.sound,_that.soundVolume,_that.originalAudioVolume);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String content,  String? imageUrl,  int likesCount,  int commentsCount,  int repostsCount,  int viewsCount,  DateTime createdAt,  PostAuthor author,  bool userLiked, @JsonKey(name: 'user_reaction_type')  String? userReactionType,  bool userReposted,  bool userFollowingAuthor,  PostAuthor? repostedBy,  DateTime? repostCreatedAt,  SoundPreview? sound, @JsonKey(name: 'sound_volume')  double soundVolume, @JsonKey(name: 'original_audio_volume')  double originalAudioVolume)  $default,) {final _that = this;
switch (_that) {
case _Post():
return $default(_that.id,_that.content,_that.imageUrl,_that.likesCount,_that.commentsCount,_that.repostsCount,_that.viewsCount,_that.createdAt,_that.author,_that.userLiked,_that.userReactionType,_that.userReposted,_that.userFollowingAuthor,_that.repostedBy,_that.repostCreatedAt,_that.sound,_that.soundVolume,_that.originalAudioVolume);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String content,  String? imageUrl,  int likesCount,  int commentsCount,  int repostsCount,  int viewsCount,  DateTime createdAt,  PostAuthor author,  bool userLiked, @JsonKey(name: 'user_reaction_type')  String? userReactionType,  bool userReposted,  bool userFollowingAuthor,  PostAuthor? repostedBy,  DateTime? repostCreatedAt,  SoundPreview? sound, @JsonKey(name: 'sound_volume')  double soundVolume, @JsonKey(name: 'original_audio_volume')  double originalAudioVolume)?  $default,) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.content,_that.imageUrl,_that.likesCount,_that.commentsCount,_that.repostsCount,_that.viewsCount,_that.createdAt,_that.author,_that.userLiked,_that.userReactionType,_that.userReposted,_that.userFollowingAuthor,_that.repostedBy,_that.repostCreatedAt,_that.sound,_that.soundVolume,_that.originalAudioVolume);case _:
  return null;

}
}

}

/// @nodoc


class _Post implements Post {
  const _Post({required this.id, required this.content, this.imageUrl, required this.likesCount, required this.commentsCount, required this.repostsCount, required this.viewsCount, required this.createdAt, required this.author, this.userLiked = false, @JsonKey(name: 'user_reaction_type') this.userReactionType, this.userReposted = false, this.userFollowingAuthor = false, this.repostedBy, this.repostCreatedAt, this.sound, @JsonKey(name: 'sound_volume') this.soundVolume = 1.0, @JsonKey(name: 'original_audio_volume') this.originalAudioVolume = 1.0});
  

@override final  String id;
@override final  String content;
@override final  String? imageUrl;
@override final  int likesCount;
@override final  int commentsCount;
@override final  int repostsCount;
@override final  int viewsCount;
@override final  DateTime createdAt;
@override final  PostAuthor author;
@override@JsonKey() final  bool userLiked;
@override@JsonKey(name: 'user_reaction_type') final  String? userReactionType;
@override@JsonKey() final  bool userReposted;
@override@JsonKey() final  bool userFollowingAuthor;
// Quando o item aparece no feed por causa de um repost de alguém,
// [repostedBy] traz o autor do repost. Frontend mostra "X repostou".
@override final  PostAuthor? repostedBy;
@override final  DateTime? repostCreatedAt;
// Brawe Sound: música anexada ao post (opcional).
@override final  SoundPreview? sound;
// Volume da música anexada (0.0-1.0) ESPECÍFICO deste post — a mesma
// faixa pode tocar com volumes diferentes em conteúdos diferentes.
@override@JsonKey(name: 'sound_volume') final  double soundVolume;
// Volume do áudio ORIGINAL do vídeo (0.0-1.0) quando há música
// anexada — permite ao autor abaixar/mutar o som próprio do vídeo
// pra não competir com a música do Brawe Sounds. Sem música anexada,
// este valor é ignorado (áudio original toca no volume nativo).
@override@JsonKey(name: 'original_audio_volume') final  double originalAudioVolume;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCopyWith<_Post> get copyWith => __$PostCopyWithImpl<_Post>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Post&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&(identical(other.repostsCount, repostsCount) || other.repostsCount == repostsCount)&&(identical(other.viewsCount, viewsCount) || other.viewsCount == viewsCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.author, author) || other.author == author)&&(identical(other.userLiked, userLiked) || other.userLiked == userLiked)&&(identical(other.userReactionType, userReactionType) || other.userReactionType == userReactionType)&&(identical(other.userReposted, userReposted) || other.userReposted == userReposted)&&(identical(other.userFollowingAuthor, userFollowingAuthor) || other.userFollowingAuthor == userFollowingAuthor)&&(identical(other.repostedBy, repostedBy) || other.repostedBy == repostedBy)&&(identical(other.repostCreatedAt, repostCreatedAt) || other.repostCreatedAt == repostCreatedAt)&&(identical(other.sound, sound) || other.sound == sound)&&(identical(other.soundVolume, soundVolume) || other.soundVolume == soundVolume)&&(identical(other.originalAudioVolume, originalAudioVolume) || other.originalAudioVolume == originalAudioVolume));
}


@override
int get hashCode => Object.hash(runtimeType,id,content,imageUrl,likesCount,commentsCount,repostsCount,viewsCount,createdAt,author,userLiked,userReactionType,userReposted,userFollowingAuthor,repostedBy,repostCreatedAt,sound,soundVolume,originalAudioVolume);

@override
String toString() {
  return 'Post(id: $id, content: $content, imageUrl: $imageUrl, likesCount: $likesCount, commentsCount: $commentsCount, repostsCount: $repostsCount, viewsCount: $viewsCount, createdAt: $createdAt, author: $author, userLiked: $userLiked, userReactionType: $userReactionType, userReposted: $userReposted, userFollowingAuthor: $userFollowingAuthor, repostedBy: $repostedBy, repostCreatedAt: $repostCreatedAt, sound: $sound, soundVolume: $soundVolume, originalAudioVolume: $originalAudioVolume)';
}


}

/// @nodoc
abstract mixin class _$PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$PostCopyWith(_Post value, $Res Function(_Post) _then) = __$PostCopyWithImpl;
@override @useResult
$Res call({
 String id, String content, String? imageUrl, int likesCount, int commentsCount, int repostsCount, int viewsCount, DateTime createdAt, PostAuthor author, bool userLiked,@JsonKey(name: 'user_reaction_type') String? userReactionType, bool userReposted, bool userFollowingAuthor, PostAuthor? repostedBy, DateTime? repostCreatedAt, SoundPreview? sound,@JsonKey(name: 'sound_volume') double soundVolume,@JsonKey(name: 'original_audio_volume') double originalAudioVolume
});


@override $PostAuthorCopyWith<$Res> get author;@override $PostAuthorCopyWith<$Res>? get repostedBy;@override $SoundPreviewCopyWith<$Res>? get sound;

}
/// @nodoc
class __$PostCopyWithImpl<$Res>
    implements _$PostCopyWith<$Res> {
  __$PostCopyWithImpl(this._self, this._then);

  final _Post _self;
  final $Res Function(_Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? imageUrl = freezed,Object? likesCount = null,Object? commentsCount = null,Object? repostsCount = null,Object? viewsCount = null,Object? createdAt = null,Object? author = null,Object? userLiked = null,Object? userReactionType = freezed,Object? userReposted = null,Object? userFollowingAuthor = null,Object? repostedBy = freezed,Object? repostCreatedAt = freezed,Object? sound = freezed,Object? soundVolume = null,Object? originalAudioVolume = null,}) {
  return _then(_Post(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,repostsCount: null == repostsCount ? _self.repostsCount : repostsCount // ignore: cast_nullable_to_non_nullable
as int,viewsCount: null == viewsCount ? _self.viewsCount : viewsCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as PostAuthor,userLiked: null == userLiked ? _self.userLiked : userLiked // ignore: cast_nullable_to_non_nullable
as bool,userReactionType: freezed == userReactionType ? _self.userReactionType : userReactionType // ignore: cast_nullable_to_non_nullable
as String?,userReposted: null == userReposted ? _self.userReposted : userReposted // ignore: cast_nullable_to_non_nullable
as bool,userFollowingAuthor: null == userFollowingAuthor ? _self.userFollowingAuthor : userFollowingAuthor // ignore: cast_nullable_to_non_nullable
as bool,repostedBy: freezed == repostedBy ? _self.repostedBy : repostedBy // ignore: cast_nullable_to_non_nullable
as PostAuthor?,repostCreatedAt: freezed == repostCreatedAt ? _self.repostCreatedAt : repostCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sound: freezed == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as SoundPreview?,soundVolume: null == soundVolume ? _self.soundVolume : soundVolume // ignore: cast_nullable_to_non_nullable
as double,originalAudioVolume: null == originalAudioVolume ? _self.originalAudioVolume : originalAudioVolume // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostAuthorCopyWith<$Res> get author {
  
  return $PostAuthorCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostAuthorCopyWith<$Res>? get repostedBy {
    if (_self.repostedBy == null) {
    return null;
  }

  return $PostAuthorCopyWith<$Res>(_self.repostedBy!, (value) {
    return _then(_self.copyWith(repostedBy: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SoundPreviewCopyWith<$Res>? get sound {
    if (_self.sound == null) {
    return null;
  }

  return $SoundPreviewCopyWith<$Res>(_self.sound!, (value) {
    return _then(_self.copyWith(sound: value));
  });
}
}

/// @nodoc
mixin _$PostAuthor {

 String get id; String get name; String get username; String? get avatarUrl; bool get isVerified;
/// Create a copy of PostAuthor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostAuthorCopyWith<PostAuthor> get copyWith => _$PostAuthorCopyWithImpl<PostAuthor>(this as PostAuthor, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostAuthor&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,username,avatarUrl,isVerified);

@override
String toString() {
  return 'PostAuthor(id: $id, name: $name, username: $username, avatarUrl: $avatarUrl, isVerified: $isVerified)';
}


}

/// @nodoc
abstract mixin class $PostAuthorCopyWith<$Res>  {
  factory $PostAuthorCopyWith(PostAuthor value, $Res Function(PostAuthor) _then) = _$PostAuthorCopyWithImpl;
@useResult
$Res call({
 String id, String name, String username, String? avatarUrl, bool isVerified
});




}
/// @nodoc
class _$PostAuthorCopyWithImpl<$Res>
    implements $PostAuthorCopyWith<$Res> {
  _$PostAuthorCopyWithImpl(this._self, this._then);

  final PostAuthor _self;
  final $Res Function(PostAuthor) _then;

/// Create a copy of PostAuthor
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


/// Adds pattern-matching-related methods to [PostAuthor].
extension PostAuthorPatterns on PostAuthor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostAuthor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostAuthor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostAuthor value)  $default,){
final _that = this;
switch (_that) {
case _PostAuthor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostAuthor value)?  $default,){
final _that = this;
switch (_that) {
case _PostAuthor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String username,  String? avatarUrl,  bool isVerified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostAuthor() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String username,  String? avatarUrl,  bool isVerified)  $default,) {final _that = this;
switch (_that) {
case _PostAuthor():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String username,  String? avatarUrl,  bool isVerified)?  $default,) {final _that = this;
switch (_that) {
case _PostAuthor() when $default != null:
return $default(_that.id,_that.name,_that.username,_that.avatarUrl,_that.isVerified);case _:
  return null;

}
}

}

/// @nodoc


class _PostAuthor implements PostAuthor {
  const _PostAuthor({required this.id, required this.name, required this.username, this.avatarUrl, this.isVerified = false});
  

@override final  String id;
@override final  String name;
@override final  String username;
@override final  String? avatarUrl;
@override@JsonKey() final  bool isVerified;

/// Create a copy of PostAuthor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostAuthorCopyWith<_PostAuthor> get copyWith => __$PostAuthorCopyWithImpl<_PostAuthor>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostAuthor&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,username,avatarUrl,isVerified);

@override
String toString() {
  return 'PostAuthor(id: $id, name: $name, username: $username, avatarUrl: $avatarUrl, isVerified: $isVerified)';
}


}

/// @nodoc
abstract mixin class _$PostAuthorCopyWith<$Res> implements $PostAuthorCopyWith<$Res> {
  factory _$PostAuthorCopyWith(_PostAuthor value, $Res Function(_PostAuthor) _then) = __$PostAuthorCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String username, String? avatarUrl, bool isVerified
});




}
/// @nodoc
class __$PostAuthorCopyWithImpl<$Res>
    implements _$PostAuthorCopyWith<$Res> {
  __$PostAuthorCopyWithImpl(this._self, this._then);

  final _PostAuthor _self;
  final $Res Function(_PostAuthor) _then;

/// Create a copy of PostAuthor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? username = null,Object? avatarUrl = freezed,Object? isVerified = null,}) {
  return _then(_PostAuthor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
