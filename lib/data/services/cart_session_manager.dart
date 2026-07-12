import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Gerencia a persistência da sessão do carrinho entre restarts
class CartSessionManager {
  static const String _sessionIdKey = 'cart_session_id';
  static const String _sessionCreatedKey = 'cart_session_created_at';

  late final SharedPreferences _prefs;

  CartSessionManager(this._prefs);

  /// Inicializa o manager (pode ser chamado via factory)
  static Future<CartSessionManager> create() async {
    final prefs = await SharedPreferences.getInstance();
    return CartSessionManager(prefs);
  }

  /// Obtém o ID da sessão existente ou cria um novo
  ///
  /// Comportamento:
  /// - Se existe sessão salva: retorna o ID salvo
  /// - Se não existe: cria novo UUID e salva
  /// - Sessões expiram após 30 dias
  Future<String> getOrCreateSessionId() async {
    String? existingSessionId = _prefs.getString(_sessionIdKey);

    // Se existe ID, verificar se não expirou (30 dias)
    if (existingSessionId != null) {
      final createdAtStr = _prefs.getString(_sessionCreatedKey);
      if (createdAtStr != null) {
        final createdAt = DateTime.parse(createdAtStr);
        final daysSinceCreation = DateTime.now().difference(createdAt).inDays;

        // Se menos de 30 dias, usar ID existente
        if (daysSinceCreation < 30) {
          return existingSessionId;
        }
      }
    }

    // Criar nova sessão
    final newSessionId = const Uuid().v4();
    await _prefs.setString(_sessionIdKey, newSessionId);
    await _prefs.setString(
      _sessionCreatedKey,
      DateTime.now().toIso8601String(),
    );

    return newSessionId;
  }

  /// Obtém o ID da sessão atual (sem criar se não existir)
  String? getCurrentSessionId() {
    return _prefs.getString(_sessionIdKey);
  }

  /// Cria uma nova sessão (útil para logout)
  Future<String> createNewSession() async {
    final newSessionId = const Uuid().v4();
    await _prefs.setString(_sessionIdKey, newSessionId);
    await _prefs.setString(
      _sessionCreatedKey,
      DateTime.now().toIso8601String(),
    );
    return newSessionId;
  }

  /// Limpa a sessão (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_sessionIdKey);
    await _prefs.remove(_sessionCreatedKey);
  }

  /// Obtém a data de criação da sessão atual
  DateTime? getSessionCreatedAt() {
    final createdAtStr = _prefs.getString(_sessionCreatedKey);
    return createdAtStr != null ? DateTime.parse(createdAtStr) : null;
  }

  /// Verifica se a sessão atual é válida (menos de 30 dias)
  bool isSessionValid() {
    final createdAt = getSessionCreatedAt();
    if (createdAt == null) return false;

    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreation < 30;
  }
}
