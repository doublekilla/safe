import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/buttons.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _locationCtl = TextEditingController();
  final List<String> _sports = [];
  String? _skill;
  final List<String> _days = [];
  String? _gender;

  final _allSports = ['Badminton', 'Basketball', 'Futsal', 'Padel', 'Volleyball'];
  final _allSkills = ['Beginner', 'Intermediate', 'Advanced', 'Pro'];
  final _allDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final _allGenders = ['Male', 'Female'];

  @override
  void dispose() {
    _locationCtl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_sports.isEmpty || _skill == null || _days.isEmpty || _gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final data = {
      'location': _locationCtl.text,
      'favorite_sports': _sports,
      'skill_level': _skill,
      'availability': _days,
      'gender': _gender,
    };

    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(data);
    
    if (success && mounted) {
      context.go('/');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Failed to update profile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Set Up Profile'),
        automaticallyImplyLeading: false, // Force them to complete it
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome to EithSpace!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Let us know a bit about your sports preferences to get started.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 32),

            const Text('Location', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _locationCtl,
              decoration: const InputDecoration(hintText: 'e.g., Jakarta, Indonesia'),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Favorite Sports'),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _allSports.map((s) => _buildChip(
                label: s,
                selected: _sports.contains(s),
                onTap: () => setState(() {
                  _sports.contains(s) ? _sports.remove(s) : _sports.add(s);
                }),
              )).toList(),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Skill Level'),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _allSkills.map((s) => _buildChip(
                label: s,
                selected: _skill == s,
                onTap: () => setState(() => _skill = s),
              )).toList(),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Availability'),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _allDays.map((d) => _buildChip(
                label: d,
                selected: _days.contains(d),
                onTap: () => setState(() {
                  _days.contains(d) ? _days.remove(d) : _days.add(d);
                }),
              )).toList(),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Gender'),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _allGenders.map((g) => _buildChip(
                label: g,
                selected: _gender == g,
                onTap: () => setState(() => _gender = g),
              )).toList(),
            ),
            const SizedBox(height: 40),

            context.watch<AuthProvider>().isLoading
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(label: 'Complete Setup', onPressed: _submit),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    );
  }

  Widget _buildChip({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.buttonPrimary : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.buttonPrimary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
