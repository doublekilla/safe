import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// Language selection screen
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'English';

  final _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'id', 'name': 'Bahasa Indonesia', 'native': 'Indonesia'},
    {'code': 'zh', 'name': 'Chinese', 'native': '中文'},
    {'code': 'ja', 'name': 'Japanese', 'native': '日本語'},
    {'code': 'ko', 'name': 'Korean', 'native': '한국어'},
    {'code': 'ms', 'name': 'Malay', 'native': 'Melayu'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Language'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _languages.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final lang = _languages[index];
          final isSelected = lang['name'] == _selected;
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() => _selected = lang['name']!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Language set to ${lang['name']}')),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.buttonPrimary.withValues(alpha: 0.08) : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.buttonPrimary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lang['name']!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isSelected ? AppColors.buttonPrimary : AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(lang['native']!, style: TextStyle(fontSize: 13, color: isSelected ? AppColors.buttonPrimary.withValues(alpha: 0.7) : AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: AppColors.buttonPrimary, size: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
