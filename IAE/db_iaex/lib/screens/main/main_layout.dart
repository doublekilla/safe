import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// Main scaffold with 5-tab bottom navigation
class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          border: const Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_filled, label: 'Home', path: '/home'),
                _NavItem(icon: Icons.people_alt_rounded, label: 'Friends', path: '/friends'),
                _NavItem(icon: Icons.groups_rounded, label: 'Clubs', path: '/communities'),
                _NavItem(icon: Icons.event_note_rounded, label: 'Activities', path: '/activities'),
                _NavItem(icon: Icons.person_rounded, label: 'Profile', path: '/profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;

  const _NavItem({required this.icon, required this.label, required this.path});

  @override
  Widget build(BuildContext context) {
    final isActive = GoRouterState.of(context).uri.toString().startsWith(path);
    final color = isActive ? AppColors.buttonPrimary : AppColors.textMuted;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.go(path),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? AppColors.surfaceContainerHigh : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}
