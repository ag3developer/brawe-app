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

  Future<User?> getSession() async {
    return await _storageService.getUser();
  }

  Future<void> logout() async {
    await _storageService.clearAll();
  }
}
