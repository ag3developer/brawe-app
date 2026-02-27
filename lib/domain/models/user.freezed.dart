// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 String get id; String get email; String get name;@JsonKey(name: 'user_type') String get userType;@JsonKey(name: 'display_id') String get displayId;@JsonKey(name: 'first_name') String get firstName;@JsonKey(name: 'last_name') String get lastName;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'is_affiliate') bool get isAffiliate;@JsonKey(name: 'is_advertiser') bool get isAdvertiser;@JsonKey(name: 'is_seller') bool get isSeller;@JsonKey(name: 'is_creator') bool get isCreator;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.userType, userType) || other.userType == userType)&&(identical(other.displayId, displayId) || other.displayId == displayId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isAffiliate, isAffiliate) || other.isAffiliate == isAffiliate)&&(identical(other.isAdvertiser, isAdvertiser) || other.isAdvertiser == isAdvertiser)&&(identical(other.isSeller, isSeller) || other.isSeller == isSeller)&&(identical(other.isCreator, isCreator) || other.isCreator == isCreator)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,name,userType,displayId,firstName,lastName,avatarUrl,isActive,isAffiliate,isAdvertiser,isSeller,isCreator,createdAt);

@override
String toString() {
  return 'User(id: $id, email: $email, name: $name, userType: $userType, displayId: $displayId, firstName: $firstName, lastName: $lastName, avatarUrl: $avatarUrl, isActive: $isActive, isAffiliate: $isAffiliate, isAdvertiser: $isAdvertiser, isSeller: $isSeller, isCreator: $isCreator, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String email, String name,@JsonKey(name: 'user_type') String userType,@JsonKey(name: 'display_id') String displayId,@JsonKey(name: 'first_name') String firstName,@JsonKey(name: 'last_name') String lastName,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_affiliate') bool isAffiliate,@JsonKey(name: 'is_advertiser') bool isAdvertiser,@JsonKey(name: 'is_seller') bool isSeller,@JsonKey(name: 'is_creator') bool isCreator,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? name = null,Object? userType = null,Object? displayId = null,Object? firstName = null,Object? lastName = null,Object? avatarUrl = freezed,Object? isActive = null,Object? isAffiliate = null,Object? isAdvertiser = null,Object? isSeller = null,Object? isCreator = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,userType: null == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as String,displayId: null == displayId ? _self.displayId : displayId // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isAffiliate: null == isAffiliate ? _self.isAffiliate : isAffiliate // ignore: cast_nullable_to_non_nullable
as bool,isAdvertiser: null == isAdvertiser ? _self.isAdvertiser : isAdvertiser // ignore: cast_nullable_to_non_nullable
as bool,isSeller: null == isSeller ? _self.isSeller : isSeller // ignore: cast_nullable_to_non_nullable
as bool,isCreator: null == isCreator ? _self.isCreator : isCreator // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String name, @JsonKey(name: 'user_type')  String userType, @JsonKey(name: 'display_id')  String displayId, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_affiliate')  bool isAffiliate, @JsonKey(name: 'is_advertiser')  bool isAdvertiser, @JsonKey(name: 'is_seller')  bool isSeller, @JsonKey(name: 'is_creator')  bool isCreator, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.name,_that.userType,_that.displayId,_that.firstName,_that.lastName,_that.avatarUrl,_that.isActive,_that.isAffiliate,_that.isAdvertiser,_that.isSeller,_that.isCreator,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String name, @JsonKey(name: 'user_type')  String userType, @JsonKey(name: 'display_id')  String displayId, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_affiliate')  bool isAffiliate, @JsonKey(name: 'is_advertiser')  bool isAdvertiser, @JsonKey(name: 'is_seller')  bool isSeller, @JsonKey(name: 'is_creator')  bool isCreator, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.email,_that.name,_that.userType,_that.displayId,_that.firstName,_that.lastName,_that.avatarUrl,_that.isActive,_that.isAffiliate,_that.isAdvertiser,_that.isSeller,_that.isCreator,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String name, @JsonKey(name: 'user_type')  String userType, @JsonKey(name: 'display_id')  String displayId, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_affiliate')  bool isAffiliate, @JsonKey(name: 'is_advertiser')  bool isAdvertiser, @JsonKey(name: 'is_seller')  bool isSeller, @JsonKey(name: 'is_creator')  bool isCreator, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.name,_that.userType,_that.displayId,_that.firstName,_that.lastName,_that.avatarUrl,_that.isActive,_that.isAffiliate,_that.isAdvertiser,_that.isSeller,_that.isCreator,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
   _User({required this.id, required this.email, required this.name, @JsonKey(name: 'user_type') required this.userType, @JsonKey(name: 'display_id') required this.displayId, @JsonKey(name: 'first_name') required this.firstName, @JsonKey(name: 'last_name') required this.lastName, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'is_affiliate') this.isAffiliate = false, @JsonKey(name: 'is_advertiser') this.isAdvertiser = false, @JsonKey(name: 'is_seller') this.isSeller = false, @JsonKey(name: 'is_creator') this.isCreator = false, @JsonKey(name: 'created_at') required this.createdAt});
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String id;
@override final  String email;
@override final  String name;
@override@JsonKey(name: 'user_type') final  String userType;
@override@JsonKey(name: 'display_id') final  String displayId;
@override@JsonKey(name: 'first_name') final  String firstName;
@override@JsonKey(name: 'last_name') final  String lastName;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'is_affiliate') final  bool isAffiliate;
@override@JsonKey(name: 'is_advertiser') final  bool isAdvertiser;
@override@JsonKey(name: 'is_seller') final  bool isSeller;
@override@JsonKey(name: 'is_creator') final  bool isCreator;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.userType, userType) || other.userType == userType)&&(identical(other.displayId, displayId) || other.displayId == displayId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isAffiliate, isAffiliate) || other.isAffiliate == isAffiliate)&&(identical(other.isAdvertiser, isAdvertiser) || other.isAdvertiser == isAdvertiser)&&(identical(other.isSeller, isSeller) || other.isSeller == isSeller)&&(identical(other.isCreator, isCreator) || other.isCreator == isCreator)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,name,userType,displayId,firstName,lastName,avatarUrl,isActive,isAffiliate,isAdvertiser,isSeller,isCreator,createdAt);

@override
String toString() {
  return 'User(id: $id, email: $email, name: $name, userType: $userType, displayId: $displayId, firstName: $firstName, lastName: $lastName, avatarUrl: $avatarUrl, isActive: $isActive, isAffiliate: $isAffiliate, isAdvertiser: $isAdvertiser, isSeller: $isSeller, isCreator: $isCreator, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String name,@JsonKey(name: 'user_type') String userType,@JsonKey(name: 'display_id') String displayId,@JsonKey(name: 'first_name') String firstName,@JsonKey(name: 'last_name') String lastName,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_affiliate') bool isAffiliate,@JsonKey(name: 'is_advertiser') bool isAdvertiser,@JsonKey(name: 'is_seller') bool isSeller,@JsonKey(name: 'is_creator') bool isCreator,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? name = null,Object? userType = null,Object? displayId = null,Object? firstName = null,Object? lastName = null,Object? avatarUrl = freezed,Object? isActive = null,Object? isAffiliate = null,Object? isAdvertiser = null,Object? isSeller = null,Object? isCreator = null,Object? createdAt = null,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,userType: null == userType ? _self.userType : userType // ignore: cast_nullable_to_non_nullable
as String,displayId: null == displayId ? _self.displayId : displayId // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isAffiliate: null == isAffiliate ? _self.isAffiliate : isAffiliate // ignore: cast_nullable_to_non_nullable
as bool,isAdvertiser: null == isAdvertiser ? _self.isAdvertiser : isAdvertiser // ignore: cast_nullable_to_non_nullable
as bool,isSeller: null == isSeller ? _self.isSeller : isSeller // ignore: cast_nullable_to_non_nullable
as bool,isCreator: null == isCreator ? _self.isCreator : isCreator // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
