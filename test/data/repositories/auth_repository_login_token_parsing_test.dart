import 'package:brawe_app/data/repositories/auth_repository.dart';
import 'package:brawe_app/data/services/auth_service.dart';
import 'package:brawe_app/data/services/storage_service.dart';
import 'package:brawe_app/domain/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRepository login token parsing', () {
    test('persists token from token key', () async {
      final storage = _FakeStorageService();
      final repository = AuthRepository(
        _FakeAuthService(
          loginPayload: _loginPayload(
            extra: {'token': 'Bearer token-from-key'},
          ),
        ),
        storage,
      );

      await repository.login('john@example.com', 'password123');

      expect(storage.savedToken, 'token-from-key');
      expect(storage.savedUser?.email, 'john@example.com');
    });

    test('persists token from nested data key', () async {
      final storage = _FakeStorageService();
      final repository = AuthRepository(
        _FakeAuthService(
          loginPayload: _loginPayload(
            extra: {
              'data': {'access_token': '"nested-token"'},
            },
          ),
        ),
        storage,
      );

      await repository.login('john@example.com', 'password123');

      expect(storage.savedToken, 'nested-token');
      expect(storage.savedUser?.email, 'john@example.com');
    });
  });
}

Map<String, dynamic> _loginPayload({required Map<String, dynamic> extra}) => {
  'user': {
    'id': 'user-1',
    'email': 'john@example.com',
    'name': 'John',
    'user_type': 'affiliate',
    'display_id': 'B-001',
    'first_name': 'John',
    'last_name': 'Doe',
    'created_at': '2026-03-10T00:00:00Z',
  },
  ...extra,
};

class _FakeAuthService extends AuthService {
  _FakeAuthService({required this.loginPayload}) : super(Dio());

  final Map<String, dynamic> loginPayload;

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    return loginPayload;
  }
}

class _FakeStorageService extends StorageService {
  _FakeStorageService() : super(const FlutterSecureStorage());

  String? savedToken;
  User? savedUser;

  @override
  Future<void> saveToken(String token) async {
    savedToken = _normalizeForTest(token);
  }

  @override
  Future<void> saveUser(User user) async {
    savedUser = user;
  }

  String _normalizeForTest(String token) {
    var normalized = token.trim();
    if (normalized.startsWith('"') && normalized.endsWith('"')) {
      normalized = normalized.substring(1, normalized.length - 1);
    }
    if (normalized.toLowerCase().startsWith('bearer ')) {
      normalized = normalized.substring(7).trim();
    }
    return normalized;
  }
}
