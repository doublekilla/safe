import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/sport_categories.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/buttons.dart';
import '../../widgets/search_and_chips.dart';

/// Profile setup screen (post-register)
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final List<String> _selectedSports = [];
  String _skillLevel = 'beginner';
  final List<String> _selectedPurposes = [];
  final _locationCtl = TextEditingController();
  final _bioCtl = TextEditingController();

  @override
  void dispose() { _locationCtl.dispose(); _bioCtl.dispose(); super.dispose(); }

  Future<void> _completeSetup() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile({
      'favorite_sports': _selectedSports,
      'skill_level': _skillLevel,
      'joining_purpose': _selectedPurposes,
      'location': _locationCtl.text.trim(),
      'bio': _bioCtl.text.trim(),
    });
    if (success && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Setup Profile'), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('Favorite Sports (Select multiple)'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: SportCategory.values.where((s) => s != SportCategory.all).map((s) {
              final isSel = _selectedSports.contains(s.value);
              return CategoryChip(
                label: s.label, icon: s.icon, isSelected: isSel,
                onTap: () => setState(() { isSel ? _selectedSports.remove(s.value) : _selectedSports.add(s.value); }),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _label('Skill Level'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: AppColors.softGray, borderRadius: BorderRadius.circular(12)),
            child: Row(children: SkillLevel.values.map((l) {
              final sel = _skillLevel == l.value;
              return Expanded(child: GestureDetector(onTap: () => setState(() => _skillLevel = l.value), child: AnimatedContainer(
                duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: sel ? AppColors.buttonPrimary : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(l.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.textSecondary))),
              )));
            }).toList()),
          ),
          const SizedBox(height: 24),
          _label('What brings you to SpaceLink?'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: JoiningPurpose.values.map((p) {
              final isSel = _selectedPurposes.contains(p.value);
              return CategoryChip(
                label: p.label, isSelected: isSel,
                onTap: () => setState(() { isSel ? _selectedPurposes.remove(p.value) : _selectedPurposes.add(p.value); }),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _label('Location (City/Area)'),
          TextFormField(controller: _locationCtl, decoration: const InputDecoration(hintText: 'e.g. South Jakarta', prefixIcon: Icon(Icons.location_on_outlined, size: 20))),
          const SizedBox(height: 24),
          _label('Short Bio'),
          TextFormField(controller: _bioCtl, maxLines: 3, decoration: const InputDecoration(hintText: 'Tell us a bit about yourself...')),
          const SizedBox(height: 32),
          PrimaryButton(label: 'Complete Setup', isLoading: auth.isLoading, onPressed: _completeSetup),
          const SizedBox(height: 12),
          Center(child: TextButton(onPressed: () => context.go('/home'), child: const Text('Skip for now', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)))),
        ]),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)));
}
