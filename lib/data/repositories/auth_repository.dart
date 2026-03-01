import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/failure.dart';
import '../../domain/models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(authServiceProvider),
    ref.watch(storageServiceProvider),
  );
}

class AuthRepository {
  final AuthService _authService;
  final StorageService _storageService;

  AuthRepository(this._authService, this._storageService);

  Future<User> login(String email, String password) async {
    try {
      final data = await _authService.login(email, password);

      final userData = data['user'] as Map<String, dynamic>;
      final user = User.fromJson(userData);

      final token = data['access_token'] as String?;
      if (token != null) {
        await _storageService.saveToken(token);
        await _storageService.saveUser(user);
      }

      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const Failure.unauthorized();
      }
      if (e.response?.statusCode == 422) {
        throw Failure.validation(e.response?.data?['message']?.toString());
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const Failure.network();
      }
      throw const Failure.server();
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<User> registerAffiliate({
    required String email,
    required String password,
    required String name,
    String? sponsorCode,
  }) async {
    try {
      final data = await _authService.registerAffiliate(
        email: email,
        password: password,
        name: name,
        sponsorCode: sponsorCode,
      );

      final userData = data['user'] as Map<String, dynamic>;
      final user = User.fromJson(userData);

      final token = data['access_token'] as String?;
      if (token != null) {
        await _storageService.saveToken(token);
        await _storageService.saveUser(user);
      }

      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final details = e.response?.data?['detail'] as List?;
        final message = details?.isNotEmpty == true
            ? details!.first['msg']?.toString()
            : 'Validation error';
        throw Failure.validation(message);
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const Failure.network();
      }
      throw const Failure.server();
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<User?> getSession() async {
    final user = await _storageService.getUser();
    final token = await _storageService.getToken();

    if (token != null) {
      // If we have a token, we should try to refresh the user from the API
      try {
        final apiUser = await getCurrentUser();
        await _storageService.saveUser(apiUser);
        return apiUser;
      } catch (_) {
        // If API call fails, fallback to local storage
        return user;
      }
    }
    return user;
  }

  Future<User> getCurrentUser() async {
    try {
      final userData = await _authService.getCurrentUser();
      return User.fromJson(userData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const Failure.unauthorized();
      }
      throw const Failure.server();
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
  }
}
