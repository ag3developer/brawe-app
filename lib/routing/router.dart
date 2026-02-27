import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../ui/auth/widgets/login_screen.dart';
import '../ui/auth/widgets/signup_screen.dart';
import '../ui/feed/widgets/feed_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/feed',
        builder: (context, state) => const FeedScreen(),
      ),
    ],
  );
}
