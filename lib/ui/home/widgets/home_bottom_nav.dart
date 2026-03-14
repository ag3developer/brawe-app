import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/app_colors.dart';
import '../../../data/repositories/auth_state_provider.dart';

class HomeBottomNav extends ConsumerWidget {
  const HomeBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.slate.withValues(alpha: 0.35),
          ),
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavBarItem(
                  icon: Icons.home_filled,
                  onTap: () => context.go('/home'),
                ),
                NavBarItem(
                  icon: Icons.sensors,
                  onTap: () => context.push('/live'),
                ),
                NavBarItem(
                  icon: Icons.add_circle_outline,
                  onTap: () => context.push('/live/start'),
                ),
                const NavBarItem(icon: Icons.shopping_bag_outlined),
                NavBarItem(
                  icon: Icons.person_outline,
                  onTap: () {
                    if (user != null) {
                      context.push('/profile/${user.id}');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  const NavBarItem({super.key, required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}
