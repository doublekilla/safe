import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/sport_categories.dart';
import '../../providers/communities_provider.dart';
import '../../widgets/buttons.dart';
import '../../widgets/search_and_chips.dart';

/// Edit existing community screen
class EditCommunityScreen extends StatefulWidget {
  final int communityId;
  const EditCommunityScreen({super.key, required this.communityId});

  @override
  State<EditCommunityScreen> createState() => _EditCommunityScreenState();
}

class _EditCommunityScreenState extends State<EditCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtl;
  late TextEditingController _locationCtl;
  late TextEditingController _descCtl;
  late TextEditingController _rulesCtl;
  late String _sportCategory;
  late bool _isPrivate;
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final com = context.read<CommunitiesProvider>().selectedCommunity;
    _nameCtl = TextEditingController(text: com?.name ?? '');
    _locationCtl = TextEditingController(text: com?.location ?? '');
    _descCtl = TextEditingController(text: com?.description ?? '');
    _rulesCtl = TextEditingController(text: com?.rules ?? '');
    _sportCategory = com?.sportCategory ?? 'badminton';
    _isPrivate = com?.privacy == 'private';
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _locationCtl.dispose();
    _descCtl.dispose();
    _rulesCtl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _imageFile = File(picked.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    
    final prov = context.read<CommunitiesProvider>();
    final success = await prov.updateCommunity(
      widget.communityId,
      {
        'name': _nameCtl.text.trim(),
        'sport_category': _sportCategory,
        'location': _locationCtl.text.trim(),
        'description': _descCtl.text.trim(),
        'rules': _rulesCtl.text.trim(),
        'privacy': _isPrivate ? 'private' : 'public',
      },
      imagePath: _imageFile?.path,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Club updated successfully')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CommunitiesProvider>();
    final com = prov.selectedCommunity;
    if (com == null) return const Scaffold(backgroundColor: AppColors.background);

    return Scaffold(
      backgroundColor: AppColors.cardSurface,
      appBar: AppBar(
        backgroundColor: AppColors.cardSurface,
        title: const Text('Edit Profile'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Cover Image
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.softGray,
                    borderRadius: BorderRadius.circular(24),
                    image: _imageFile != null
                        ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.contain)
                        : (com.image != null
                            ? DecorationImage(image: NetworkImage(com.image!), fit: BoxFit.contain)
                            : null),
                  ),
                  child: _imageFile == null && com.image == null
                      ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.textMuted),
                          SizedBox(height: 8),
                          Text('Change Cover', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ])
                      : const Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.cardSurface,
                              child: Icon(Icons.edit, size: 16, color: AppColors.textPrimary),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            _label('Club Name'),
            TextFormField(controller: _nameCtl, decoration: const InputDecoration(hintText: 'e.g. Jakarta Badminton Club'), validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
            const SizedBox(height: 16),

            _label('Sport Category'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: SportCategory.values.where((s) => s != SportCategory.all).map((s) => CategoryChip(
                label: s.label,
                icon: s.icon,
                isSelected: _sportCategory == s.value,
                onTap: () => setState(() => _sportCategory = s.value),
              )).toList(),
            ),
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

            PrimaryButton(label: 'Save Changes', isLoading: prov.isLoading, onPressed: _update),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)));
}
