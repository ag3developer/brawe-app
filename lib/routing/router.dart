import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/auth_state_provider.dart';
import '../ui/auth/widgets/login_screen.dart';
import '../ui/auth/widgets/signup_screen.dart';
import '../ui/auth/widgets/welcome_screen.dart';
import '../ui/feed/widgets/feed_screen.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/live/widgets/live_feed_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: RouterRefreshListenable(ref),
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isAuth = authState.asData?.value != null;
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/welcome';

      if (isLoading) return null;

      if (!isAuth) {
        return isLoggingIn ? null : '/welcome';
      }

      if (isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(path: '/feed', builder: (context, state) => const FeedScreen()),
      GoRoute(
        path: '/live',
        builder: (context, state) => const LiveFeedScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
}

class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(Ref ref) {
    _subscription = ref.listen(
      authStateProvider,
      (previous, next) => notifyListeners(),
    );
  }

  late final ProviderSubscription _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
