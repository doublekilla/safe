import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _locationCtl = TextEditingController();

  List<String> _sports = [];
  String? _skill;
  List<String> _days = [];
  String? _gender;
  String? _base64Image;
  String? _currentImageUrl;

  final _allSports = ['Badminton', 'Basketball', 'Futsal', 'Padel', 'Volleyball'];
  final _allSkills = ['Beginner', 'Intermediate', 'Advanced', 'Pro'];
  final _allDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final _allGenders = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        _nameCtl.text = user.fullName;
        _phoneCtl.text = user.phone ?? '';
        _locationCtl.text = user.location ?? '';
        setState(() {
          _sports = List.from(user.favoriteSports);
          _skill = user.skillLevel;
          _days = List.from(user.availability);
          _gender = user.gender;
          _currentImageUrl = user.profileImage;
        });
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropStyle: CropStyle.circle,
          ),
          IOSUiSettings(
            title: 'Crop Profile Picture',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            cropStyle: CropStyle.circle,
          ),
        ],
      );

      if (croppedFile != null) {
        final bytes = await croppedFile.readAsBytes();
        final ext = croppedFile.path.split('.').last.toLowerCase();
        final base64String = base64Encode(bytes);
        setState(() {
          _base64Image = 'data:image/$ext;base64,$base64String';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _locationCtl.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameCtl.text,
        'phone': _phoneCtl.text,
        'location': _locationCtl.text,
        'favorite_sports': _sports,
        'skill_level': _skill,
        'availability': _days,
        'gender': _gender,
      };
      
      if (_base64Image != null) {
        data['profile_image_base64'] = _base64Image!;
      }

      final auth = context.read<AuthProvider>();
      final success = await auth.updateProfile(data);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!')));
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Failed to update profile')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      UserAvatar(
                        name: _nameCtl.text.isEmpty ? 'User' : _nameCtl.text,
                        imageUrl: _base64Image ?? _currentImageUrl,
                        size: 100,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtl,
                decoration: const InputDecoration(hintText: 'Your name'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              
              const Text('Phone Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneCtl,
                decoration: const InputDecoration(hintText: '0812...'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              const Text('Location', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _locationCtl,
                decoration: const InputDecoration(hintText: 'e.g., Jakarta, Indonesia'),
              ),
              const SizedBox(height: 32),

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
                  : PrimaryButton(label: 'Save Changes', onPressed: _save),
            ],
          ),
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
