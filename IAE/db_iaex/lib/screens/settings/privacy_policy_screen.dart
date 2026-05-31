import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// Privacy Policy screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Privacy Policy', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Last updated: May 30, 2026', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            _buildParagraph(
              '1. Information We Collect',
              'We collect information you provide directly to us, including your name, email address, phone number, profile details, sports preferences, and location data. We also collect usage data such as activity history, booking records, and interaction patterns within the app.',
            ),
            _buildParagraph(
              '2. How We Use Your Information',
              'We use your information to provide, maintain, and improve our services, process transactions, send you notifications about activities and bookings, personalize your experience, and connect you with relevant sports communities and venues.',
            ),
            _buildParagraph(
              '3. Information Sharing',
              'We do not sell or rent your personal information to third parties. We may share your profile information with other users in the context of activities and communities you join. We may share data with service providers who assist us in operating our platform.',
            ),
            _buildParagraph(
              '4. Data Security',
              'We implement industry-standard security measures to protect your personal information. This includes encryption of data in transit and at rest, regular security audits, and access controls. However, no method of transmission over the Internet is 100% secure.',
            ),
            _buildParagraph(
              '5. Location Data',
              'With your permission, we collect location data to show nearby venues and activities. You can disable location services at any time through your device settings. Some features may have limited functionality without location access.',
            ),
            _buildParagraph(
              '6. Cookies and Tracking',
              'We use cookies and similar tracking technologies to analyze usage patterns and improve our service. You can manage cookie preferences through your browser or device settings.',
            ),
            _buildParagraph(
              '7. Your Rights',
              'You have the right to access, update, or delete your personal information at any time. You can export your data, request account deletion, or opt out of certain data collection practices by contacting our support team.',
            ),
            _buildParagraph(
              '8. Data Retention',
              'We retain your personal information for as long as your account is active or as needed to provide you services. If you delete your account, we will delete your personal data within 30 days, except where we are required by law to retain it.',
            ),
            _buildParagraph(
              '9. Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.buttonPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.buttonPrimary),
                  SizedBox(height: 8),
                  Text('Your privacy matters', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  SizedBox(height: 4),
                  Text('Contact us at privacy@spacelink.id', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
        ],
      ),
    );
  }
}
