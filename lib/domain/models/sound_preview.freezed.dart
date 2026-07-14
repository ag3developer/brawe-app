// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sound_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SoundPreview {

 String get id; String get title;@JsonKey(name: 'artist_name') String get artistName;@JsonKey(name: 'artist_avatar_url') String? get artistAvatarUrl;@JsonKey(name: 'cover_url') String? get coverUrl;@JsonKey(name: 'audio_url') String get audioUrl;@JsonKey(name: 'duration_ms') int get durationMs;@JsonKey(name: 'trim_start_ms') int get trimStartMs;@JsonKey(name: 'trim_end_ms') int? get trimEndMs;
/// Create a copy of SoundPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SoundPreviewCopyWith<SoundPreview> get copyWith => _$SoundPreviewCopyWithImpl<SoundPreview>(this as SoundPreview, _$identity);

  /// Serializes this SoundPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SoundPreview&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artistName, artistName) || other.artistName == artistName)&&(identical(other.artistAvatarUrl, artistAvatarUrl) || other.artistAvatarUrl == artistAvatarUrl)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.trimStartMs, trimStartMs) || other.trimStartMs == trimStartMs)&&(identical(other.trimEndMs, trimEndMs) || other.trimEndMs == trimEndMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,artistName,artistAvatarUrl,coverUrl,audioUrl,durationMs,trimStartMs,trimEndMs);

@override
String toString() {
  return 'SoundPreview(id: $id, title: $title, artistName: $artistName, artistAvatarUrl: $artistAvatarUrl, coverUrl: $coverUrl, audioUrl: $audioUrl, durationMs: $durationMs, trimStartMs: $trimStartMs, trimEndMs: $trimEndMs)';
}


}

/// @nodoc
abstract mixin class $SoundPreviewCopyWith<$Res>  {
  factory $SoundPreviewCopyWith(SoundPreview value, $Res Function(SoundPreview) _then) = _$SoundPreviewCopyWithImpl;
@useResult
$Res call({
 String id, String title,@JsonKey(name: 'artist_name') String artistName,@JsonKey(name: 'artist_avatar_url') String? artistAvatarUrl,@JsonKey(name: 'cover_url') String? coverUrl,@JsonKey(name: 'audio_url') String audioUrl,@JsonKey(name: 'duration_ms') int durationMs,@JsonKey(name: 'trim_start_ms') int trimStartMs,@JsonKey(name: 'trim_end_ms') int? trimEndMs
});




}
/// @nodoc
class _$SoundPreviewCopyWithImpl<$Res>
    implements $SoundPreviewCopyWith<$Res> {
  _$SoundPreviewCopyWithImpl(this._self, this._then);

  final SoundPreview _self;
  final $Res Function(SoundPreview) _then;

/// Create a copy of SoundPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? artistName = null,Object? artistAvatarUrl = freezed,Object? coverUrl = freezed,Object? audioUrl = null,Object? durationMs = null,Object? trimStartMs = null,Object? trimEndMs = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artistName: null == artistName ? _self.artistName : artistName // ignore: cast_nullable_to_non_nullable
as String,artistAvatarUrl: freezed == artistAvatarUrl ? _self.artistAvatarUrl : artistAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,trimStartMs: null == trimStartMs ? _self.trimStartMs : trimStartMs // ignore: cast_nullable_to_non_nullable
as int,trimEndMs: freezed == trimEndMs ? _self.trimEndMs : trimEndMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SoundPreview].
extension SoundPreviewPatterns on SoundPreview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SoundPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SoundPreview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SoundPreview value)  $default,){
final _that = this;
switch (_that) {
case _SoundPreview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SoundPreview value)?  $default,){
final _that = this;
switch (_that) {
case _SoundPreview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'artist_name')  String artistName, @JsonKey(name: 'artist_avatar_url')  String? artistAvatarUrl, @JsonKey(name: 'cover_url')  String? coverUrl, @JsonKey(name: 'audio_url')  String audioUrl, @JsonKey(name: 'duration_ms')  int durationMs, @JsonKey(name: 'trim_start_ms')  int trimStartMs, @JsonKey(name: 'trim_end_ms')  int? trimEndMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SoundPreview() when $default != null:
return $default(_that.id,_that.title,_that.artistName,_that.artistAvatarUrl,_that.coverUrl,_that.audioUrl,_that.durationMs,_that.trimStartMs,_that.trimEndMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'artist_name')  String artistName, @JsonKey(name: 'artist_avatar_url')  String? artistAvatarUrl, @JsonKey(name: 'cover_url')  String? coverUrl, @JsonKey(name: 'audio_url')  String audioUrl, @JsonKey(name: 'duration_ms')  int durationMs, @JsonKey(name: 'trim_start_ms')  int trimStartMs, @JsonKey(name: 'trim_end_ms')  int? trimEndMs)  $default,) {final _that = this;
switch (_that) {
case _SoundPreview():
return $default(_that.id,_that.title,_that.artistName,_that.artistAvatarUrl,_that.coverUrl,_that.audioUrl,_that.durationMs,_that.trimStartMs,_that.trimEndMs);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title, @JsonKey(name: 'artist_name')  String artistName, @JsonKey(name: 'artist_avatar_url')  String? artistAvatarUrl, @JsonKey(name: 'cover_url')  String? coverUrl, @JsonKey(name: 'audio_url')  String audioUrl, @JsonKey(name: 'duration_ms')  int durationMs, @JsonKey(name: 'trim_start_ms')  int trimStartMs, @JsonKey(name: 'trim_end_ms')  int? trimEndMs)?  $default,) {final _that = this;
switch (_that) {
case _SoundPreview() when $default != null:
return $default(_that.id,_that.title,_that.artistName,_that.artistAvatarUrl,_that.coverUrl,_that.audioUrl,_that.durationMs,_that.trimStartMs,_that.trimEndMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SoundPreview implements SoundPreview {
  const _SoundPreview({required this.id, required this.title, @JsonKey(name: 'artist_name') required this.artistName, @JsonKey(name: 'artist_avatar_url') this.artistAvatarUrl, @JsonKey(name: 'cover_url') this.coverUrl, @JsonKey(name: 'audio_url') required this.audioUrl, @JsonKey(name: 'duration_ms') this.durationMs = 0, @JsonKey(name: 'trim_start_ms') this.trimStartMs = 0, @JsonKey(name: 'trim_end_ms') this.trimEndMs});
  factory _SoundPreview.fromJson(Map<String, dynamic> json) => _$SoundPreviewFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey(name: 'artist_name') final  String artistName;
@override@JsonKey(name: 'artist_avatar_url') final  String? artistAvatarUrl;
@override@JsonKey(name: 'cover_url') final  String? coverUrl;
@override@JsonKey(name: 'audio_url') final  String audioUrl;
@override@JsonKey(name: 'duration_ms') final  int durationMs;
@override@JsonKey(name: 'trim_start_ms') final  int trimStartMs;
@override@JsonKey(name: 'trim_end_ms') final  int? trimEndMs;

/// Create a copy of SoundPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SoundPreviewCopyWith<_SoundPreview> get copyWith => __$SoundPreviewCopyWithImpl<_SoundPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SoundPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SoundPreview&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artistName, artistName) || other.artistName == artistName)&&(identical(other.artistAvatarUrl, artistAvatarUrl) || other.artistAvatarUrl == artistAvatarUrl)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.trimStartMs, trimStartMs) || other.trimStartMs == trimStartMs)&&(identical(other.trimEndMs, trimEndMs) || other.trimEndMs == trimEndMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,artistName,artistAvatarUrl,coverUrl,audioUrl,durationMs,trimStartMs,trimEndMs);

@override
String toString() {
  return 'SoundPreview(id: $id, title: $title, artistName: $artistName, artistAvatarUrl: $artistAvatarUrl, coverUrl: $coverUrl, audioUrl: $audioUrl, durationMs: $durationMs, trimStartMs: $trimStartMs, trimEndMs: $trimEndMs)';
}


}

/// @nodoc
abstract mixin class _$SoundPreviewCopyWith<$Res> implements $SoundPreviewCopyWith<$Res> {
  factory _$SoundPreviewCopyWith(_SoundPreview value, $Res Function(_SoundPreview) _then) = __$SoundPreviewCopyWithImpl;
@override @useResult
$Res call({
 String id, String title,@JsonKey(name: 'artist_name') String artistName,@JsonKey(name: 'artist_avatar_url') String? artistAvatarUrl,@JsonKey(name: 'cover_url') String? coverUrl,@JsonKey(name: 'audio_url') String audioUrl,@JsonKey(name: 'duration_ms') int durationMs,@JsonKey(name: 'trim_start_ms') int trimStartMs,@JsonKey(name: 'trim_end_ms') int? trimEndMs
});




}
/// @nodoc
class __$SoundPreviewCopyWithImpl<$Res>
    implements _$SoundPreviewCopyWith<$Res> {
  __$SoundPreviewCopyWithImpl(this._self, this._then);

  final _SoundPreview _self;
  final $Res Function(_SoundPreview) _then;

/// Create a copy of SoundPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? artistName = null,Object? artistAvatarUrl = freezed,Object? coverUrl = freezed,Object? audioUrl = null,Object? durationMs = null,Object? trimStartMs = null,Object? trimEndMs = freezed,}) {
  return _then(_SoundPreview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artistName: null == artistName ? _self.artistName : artistName // ignore: cast_nullable_to_non_nullable
as String,artistAvatarUrl: freezed == artistAvatarUrl ? _self.artistAvatarUrl : artistAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,trimStartMs: null == trimStartMs ? _self.trimStartMs : trimStartMs // ignore: cast_nullable_to_non_nullable
as int,trimEndMs: freezed == trimEndMs ? _self.trimEndMs : trimEndMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
