import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/sport_categories.dart';
import '../../providers/communities_provider.dart';
import '../../widgets/buttons.dart';
import '../../widgets/search_and_chips.dart';

/// Create new community screen
class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});
  @override State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _locationCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final _rulesCtl = TextEditingController();
  String _sportCategory = 'badminton';
  bool _isPrivate = false;

  @override
  void dispose() { _nameCtl.dispose(); _locationCtl.dispose(); _descCtl.dispose(); _rulesCtl.dispose(); super.dispose(); }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<CommunitiesProvider>();
    final success = await prov.createCommunity({
      'name': _nameCtl.text.trim(),
      'sport_category': _sportCategory,
      'location': _locationCtl.text.trim(),
      'description': _descCtl.text.trim(),
      'rules': _rulesCtl.text.trim(),
      'privacy': _isPrivate ? 'private' : 'public',
    });
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Club created!')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CommunitiesProvider>();
    return Scaffold(
      backgroundColor: AppColors.cardSurface,
      appBar: AppBar(backgroundColor: AppColors.cardSurface, title: const Text('Create Club'), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Image upload placeholder
            Center(child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(color: AppColors.softGray, borderRadius: BorderRadius.circular(24)),
              child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.textMuted),
                SizedBox(height: 8),
                Text('Add Cover', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            )),
            const SizedBox(height: 32),

            _label('Club Name'),
            TextFormField(controller: _nameCtl, decoration: const InputDecoration(hintText: 'e.g. Jakarta Badminton Club'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
            const SizedBox(height: 16),

            _label('Sport Category'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: SportCategory.values.where((s) => s != SportCategory.all).map((s) => CategoryChip(label: s.label, icon: s.icon, isSelected: _sportCategory == s.value, onTap: () => setState(() => _sportCategory = s.value))).toList()),
            const SizedBox(height: 16),

            _label('Location'),
            TextFormField(controller: _locationCtl, decoration: const InputDecoration(hintText: 'City or Venue name', prefixIcon: Icon(Icons.location_on_outlined, size: 20)), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
            const SizedBox(height: 16),

            _label('Description'),
            TextFormField(controller: _descCtl, maxLines: 4, decoration: const InputDecoration(hintText: 'What is this club about?')),
            const SizedBox(height: 16),

            _label('Rules'),
            TextFormField(controller: _rulesCtl, maxLines: 3, decoration: const InputDecoration(hintText: 'Any rules for members?')),
            const SizedBox(height: 24),

            // Privacy Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.softGray, borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                const Icon(Icons.lock_outline_rounded, size: 24, color: AppColors.textPrimary),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Private Club', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text('Only approved members can join', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ])),
                Switch.adaptive(value: _isPrivate, onChanged: (v) => setState(() => _isPrivate = v), activeTrackColor: AppColors.buttonPrimary),
              ]),
            ),
            const SizedBox(height: 32),

            PrimaryButton(label: 'Create Club', isLoading: prov.isLoading, onPressed: _create),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)));
}
