import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
/// Splash screen — logo animation, tagline, auto-navigate
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeOut)));
    _scale = Tween<double>(begin: 0.8, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeOut)));
    _controller.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Wait for splash animation and load user simultaneously
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2500)),
      context.read<AuthProvider>().loadUser(),
    ]);
    
    if (mounted) {
      if (context.read<AuthProvider>().isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.buttonPrimary,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeIn.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: const Center(child: Text('SL', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.buttonPrimary))),
                  ),
                  const SizedBox(height: 20),
                  const Text('SpaceLink', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5)),
                  const SizedBox(height: 6),
                  Text('Find Your Sports Circle', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
                  const SizedBox(height: 40),
                  SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white.withValues(alpha: 0.5))),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}
