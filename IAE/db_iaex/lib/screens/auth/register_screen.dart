import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/buttons.dart';

/// Register screen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _confirmCtl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _nameCtl.dispose(); _emailCtl.dispose(); _phoneCtl.dispose(); _passwordCtl.dispose(); _confirmCtl.dispose(); super.dispose(); }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.register(name: _nameCtl.text.trim(), email: _emailCtl.text.trim(), phone: _phoneCtl.text.trim(), password: _passwordCtl.text);
    if (success && mounted) {
      final user = auth.currentUser;
      if (user != null && user.favoriteSports.isEmpty) {
        context.go('/setup-profile');
      } else {
        context.go('/');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Registration failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 24),
              const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Join SpaceLink and find your sports circle', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 28),
              _label('Full Name'),
              TextFormField(controller: _nameCtl, decoration: const InputDecoration(hintText: 'Your full name', prefixIcon: Icon(Icons.person_outline_rounded, size: 20)), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
              const SizedBox(height: 14),
              _label('Email'),
              TextFormField(controller: _emailCtl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'your@email.com', prefixIcon: Icon(Icons.email_outlined, size: 20)), validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null),
              const SizedBox(height: 14),
              _label('Phone Number'),
              TextFormField(controller: _phoneCtl, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(hintText: '08xxxxxxxxxx', prefixIcon: Icon(Icons.phone_outlined, size: 20)), validator: (v) => (v == null || v.length < 10) ? 'Valid phone required' : null),
              const SizedBox(height: 14),
              _label('Password'),
              TextFormField(controller: _passwordCtl, obscureText: _obscure, decoration: InputDecoration(hintText: 'Min 6 characters', prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20), onPressed: () => setState(() => _obscure = !_obscure))), validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null),
              const SizedBox(height: 14),
              _label('Confirm Password'),
              TextFormField(controller: _confirmCtl, obscureText: true, decoration: const InputDecoration(hintText: 'Re-enter password', prefixIcon: Icon(Icons.lock_outline_rounded, size: 20)), validator: (v) => v != _passwordCtl.text ? 'Passwords do not match' : null),
              if (auth.error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(auth.error!, style: const TextStyle(fontSize: 12, color: AppColors.errorRed))),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Create Account', isLoading: auth.isLoading, onPressed: _register),
              const SizedBox(height: 16),
              Center(child: GestureDetector(
                onTap: () {
                  context.read<AuthProvider>().clearError();
                  context.go('/login');
                },
                child: RichText(text: const TextSpan(
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  children: [
                    TextSpan(text: 'Already have an account? '),
                    TextSpan(text: 'Sign In', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ],
                )),
              )),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)));
}
