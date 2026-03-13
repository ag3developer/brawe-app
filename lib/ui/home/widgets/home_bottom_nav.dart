import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/app_colors.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
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
                const NavBarItem(icon: Icons.home_filled),
                NavBarItem(
                  icon: Icons.sensors,
                  onTap: () => context.push('/live'),
                ),
                NavBarItem(
                  icon: Icons.add_circle_outline,
                  onTap: () => context.push('/live/start'),
                ),
                const NavBarItem(icon: Icons.shopping_bag_outlined),
                const NavBarItem(icon: Icons.person_outline),
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
