import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/buttons.dart';

/// Login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _emailCtl.dispose(); _passwordCtl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(email: _emailCtl.text.trim(), password: _passwordCtl.text);
    if (success && mounted) {
      final user = auth.currentUser;
      if (user != null && user.favoriteSports.isEmpty) {
        context.go('/setup-profile');
      } else {
        context.go('/');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
              const Text('Welcome back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Sign in to your SpaceLink account', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(controller: _emailCtl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'your@email.com', prefixIcon: Icon(Icons.email_outlined, size: 20)), validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null),
              const SizedBox(height: 14),
              const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(controller: _passwordCtl, obscureText: _obscure, decoration: InputDecoration(hintText: '••••••••', prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20), onPressed: () => setState(() => _obscure = !_obscure))), validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null),
              if (auth.error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(auth.error!, style: const TextStyle(fontSize: 12, color: AppColors.errorRed))),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Sign In', isLoading: auth.isLoading, onPressed: _login),
              const SizedBox(height: 16),
              // Google login
              SizedBox(
                width: double.infinity, height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
                  label: const Text('Continue with Google', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
              Center(child: GestureDetector(
                onTap: () {
                  context.read<AuthProvider>().clearError();
                  context.go('/register');
                },
                child: RichText(text: const TextSpan(
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  children: [
                    TextSpan(text: "Don't have an account? "),
                    TextSpan(text: 'Sign Up', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ],
                )),
              )),
            ]),
          ),
        ),
      ),
      ),
    );
  }
}
