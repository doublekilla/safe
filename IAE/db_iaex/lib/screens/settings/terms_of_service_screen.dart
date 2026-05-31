import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// Terms of Service screen
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Terms of Service'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Terms of Service', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Last updated: May 30, 2026', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            _buildParagraph(
              '1. Acceptance of Terms',
              'By accessing and using SpaceLink, you agree to be bound by these Terms of Service and all applicable laws and regulations. If you do not agree with any of these terms, you are prohibited from using this application.',
            ),
            _buildParagraph(
              '2. Use of Service',
              'SpaceLink provides a platform for sports enthusiasts to discover venues, join activities, and connect with other players. You must be at least 13 years old to use this service. You are responsible for maintaining the confidentiality of your account credentials.',
            ),
            _buildParagraph(
              '3. User Conduct',
              'You agree not to engage in any activity that interferes with or disrupts the service. This includes spamming, creating fake accounts, impersonating others, posting offensive content, or engaging in any illegal activities through the platform.',
            ),
            _buildParagraph(
              '4. Bookings and Payments',
              'All bookings made through SpaceLink are subject to availability. Cancellation policies may vary depending on the venue. Payment processing is handled securely through our integrated payment partners. Refund policies are subject to individual venue terms.',
            ),
            _buildParagraph(
              '5. Community Guidelines',
              'Users are expected to maintain respectful communication within clubs and activities. Harassment, discrimination, or abusive behavior will result in account suspension or termination.',
            ),
            _buildParagraph(
              '6. Intellectual Property',
              'All content, features, and functionality of SpaceLink are owned by us and are protected by international copyright, trademark, and other intellectual property laws.',
            ),
            _buildParagraph(
              '7. Limitation of Liability',
              'SpaceLink shall not be liable for any injuries, damages, or losses that occur during or as a result of activities organized through the platform. Users participate in all activities at their own risk.',
            ),
            _buildParagraph(
              '8. Changes to Terms',
              'We reserve the right to modify these terms at any time. Continued use of the service after changes constitutes acceptance of the new terms. We will notify users of significant changes via email or in-app notification.',
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
                  Icon(Icons.email_outlined, color: AppColors.buttonPrimary),
                  SizedBox(height: 8),
                  Text('Questions about our terms?', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  SizedBox(height: 4),
                  Text('Contact us at legal@spacelink.id', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
