import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/user.dart';

part 'storage_service.g.dart';

@riverpod
StorageService storageService(Ref ref) {
  return StorageService(const FlutterSecureStorage());
}

class StorageService {
  final FlutterSecureStorage _storage;

  StorageService(this._storage);

  Future<void> saveToken(String token) async {
    final normalized = _normalizeToken(token);
    if (normalized == null) {
      await _storage.delete(key: AppConstants.tokenKey);
      return;
    }
    await _storage.write(key: AppConstants.tokenKey, value: normalized);
  }

  Future<String?> getToken() async {
    final raw = await _storage.read(key: AppConstants.tokenKey);
    return _normalizeToken(raw);
  }

  Future<void> saveUser(User user) async {
    await _storage.write(key: AppConstants.userKey, value: jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final userJson = await _storage.read(key: AppConstants.userKey);
    if (userJson == null) return null;
    try {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  String? _normalizeToken(String? token) {
    if (token == null) {
      return null;
    }

    var normalized = token.trim();
    if (normalized.isEmpty) {
      return null;
    }

    if (normalized.startsWith('"') && normalized.endsWith('"')) {
      normalized = normalized.substring(1, normalized.length - 1).trim();
    }

    final lower = normalized.toLowerCase();
    if (lower.startsWith('bearer ')) {
      normalized = normalized.substring(7).trim();
    }

    return normalized.isEmpty ? null : normalized;
  }
}
