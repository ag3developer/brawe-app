import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/marketplace_models.dart';
import '../repositories/marketplace_repository.dart';
import 'marketplace_providers.dart';

// ============================================================================
// SESSION ID (anonymous cart support)
// ============================================================================

/// In-memory anonymous session id.
///
/// **TODO (gap):** Persist this across app restarts using
/// `shared_preferences` (already a dependency of the project) once the
/// backend confirms it needs a *stable* anonymous session across restarts.
/// For now, an in-memory singleton is enough: an anonymous cart is only
/// relevant for the lifetime of the current app session and any logged-in
/// user's cart is scoped server-side by user id instead of session id.
class CartSession {
  CartSession._();

  static String? _sessionId;

  /// Returns the current anonymous session id, generating one on first use.
  static String get id {
    _sessionId ??= _generate();
    return _sessionId!;
  }

  static String _generate() {
    final random =
        DateTime.now().microsecondsSinceEpoch.toRadixString(16) +
        (DateTime.now().hashCode & 0xFFFFFF).toRadixString(16);
    return 'anon_$random';
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

  double get tax => cart?.tax ?? 0;

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
      final result = await _repo.getCart(
        sessionId: sessionId ?? CartSession.id,
      );
      final cart = result as Cart;
      state = state.copyWith(cart: cart, isLoading: false, clearError: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addItem(CartItemRequest request, {String? sessionId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.addToCart(request, sessionId: sessionId ?? CartSession.id);
      await loadCart(sessionId: sessionId);
      return true;
    } catch (e) {
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
