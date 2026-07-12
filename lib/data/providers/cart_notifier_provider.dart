import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/marketplace_models.dart';
import '../repositories/marketplace_repository.dart';
import '../services/cart_session_manager.dart';
import 'marketplace_providers.dart';

// ============================================================================
// CART SESSION MANAGER PROVIDER
// ============================================================================

/// Provider para CartSessionManager (gerencia persistência de sessão)
final cartSessionManagerProvider = FutureProvider<CartSessionManager>((
  ref,
) async {
  return CartSessionManager.create();
});

// ============================================================================
// SESSION ID (anonymous cart support with persistence)
// ============================================================================

/// Anonymous session id manager.
///
/// Agora persiste através de restarts usando `shared_preferences`.
/// Sessões expiram após 30 dias de inatividade.
class CartSession {
  CartSession._();

  static String? _sessionId;
  static CartSessionManager? _manager;

  /// Inicializa o manager com dados persistidos
  static Future<void> initialize(CartSessionManager manager) async {
    _manager = manager;
    _sessionId = await manager.getOrCreateSessionId();
  }

  /// Returns the current anonymous session id, using persisted value or generating one.
  ///
  /// IMPORTANTE: Chamar `initialize()` uma vez na app startup para garantir
  /// que a sessão seja carregada do disco.
  /// Se não inicializado, gera um ID temporário em-memória.
  static String get id {
    if (_sessionId == null) {
      // Fallback: gerar ID temporário em-memória
      // (não é persistido, mas permite usar carrinho mesmo se inicialização falhou)
      _sessionId =
          'anon_${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}';
    }
    return _sessionId!;
  }

  /// Força criar uma nova sessão (útil para logout)
  static Future<void> createNew() async {
    if (_manager == null) {
      throw Exception('CartSession não foi inicializado!');
    }
    _sessionId = await _manager!.createNewSession();
  }

  /// Limpa a sessão (logout)
  static Future<void> clear() async {
    if (_manager == null) {
      throw Exception('CartSession não foi inicializado!');
    }
    await _manager!.clearSession();
    _sessionId = null;
  }
}

// ============================================================================
// CART STATE
// ============================================================================

class CartState {
  final Cart? cart;
  final bool isLoading;
  final String? error;

  const CartState({this.cart, this.isLoading = false, this.error});

  CartState copyWith({
    Cart? cart,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  List<CartItem> get items => cart?.items ?? const [];

  bool get isEmpty => items.isEmpty;

  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get subtotal => cart?.subtotal ?? 0;

  double get shipping => cart?.shipping ?? 0;

  double get discount => cart?.discount ?? 0;

  double get total => cart?.total ?? 0;
}

// ============================================================================
// CART NOTIFIER
// ============================================================================

class CartNotifier extends Notifier<CartState> {
  MarketplaceRepository get _repo => ref.watch(marketplaceRepositoryProvider);

  @override
  CartState build() {
    // Kick off initial load without blocking synchronous `build()`.
    Future.microtask(() => loadCart());
    return const CartState(isLoading: true);
  }

  Future<void> loadCart({String? sessionId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final cartSessionId = sessionId ?? CartSession.id;
      debugPrint('🛒 Loading cart with session: $cartSessionId');
      final result = await _repo.getCart(sessionId: cartSessionId);
      final cart = result as Cart;
      debugPrint('✅ Cart loaded: ${cart.items.length} items');
      state = state.copyWith(cart: cart, isLoading: false, clearError: true);
    } catch (e) {
      debugPrint('❌ Error loading cart: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addItem(CartItemRequest request, {String? sessionId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final cartSessionId = sessionId ?? CartSession.id;
      debugPrint(
        '🛒 Adding item: product=${request.productId}, qty=${request.quantity}, session=$cartSessionId',
      );
      await _repo.addToCart(request, sessionId: cartSessionId);
      debugPrint('✅ Item added, reloading cart...');
      await loadCart(sessionId: sessionId);
      debugPrint('✅ Cart reloaded after adding item');
      return true;
    } catch (e) {
      debugPrint('❌ Error adding item: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateQuantity(String cartItemId, int quantity) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.updateCartItem(
        cartItemId,
        CartItemUpdateRequest(quantity: quantity),
      );
      await loadCart();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> removeItem(String cartItemId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.removeFromCart(cartItemId);
      await loadCart();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> clear() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.clearCart();
      await loadCart();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final cartNotifierProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);

/// Convenience: item count for badges (e.g., AppBar cart icon).
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartNotifierProvider).itemCount;
});
