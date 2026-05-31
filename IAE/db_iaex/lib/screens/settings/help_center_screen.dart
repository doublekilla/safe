import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// Help Center screen
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help Center'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Search
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search help articles...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const Text('Quick Help', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildQuickAction(context, Icons.chat_bubble_outline_rounded, 'Live Chat', () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Live chat is currently offline. Please try again during business hours (09:00 - 18:00 WIB).')));
              })),
              const SizedBox(width: 12),
              Expanded(child: _buildQuickAction(context, Icons.email_outlined, 'Email Us', () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Send us an email at support@spacelink.id')));
              })),
            ],
          ),
          const SizedBox(height: 24),

          // FAQ
          const Text('Frequently Asked Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _buildFaqItem(
            'How do I join an activity?',
            'Browse activities in the Activities tab, select one that interests you, and tap "Join Activity". If the activity is full, you can join the waiting list to be notified when a spot opens up.',
          ),
          _buildFaqItem(
            'How do I create a new activity?',
            'Go to the Activities tab and tap the + button at the bottom right corner. Fill in the details like sport type, date, time, location, and quota, then tap "Create Activity".',
          ),
          _buildFaqItem(
            'How do I cancel my RSVP?',
            'Open the activity detail page and tap "Cancel RSVP". Your spot will be released and the next person on the waiting list will be notified.',
          ),
          _buildFaqItem(
            'How do I change my password?',
            'Go to Profile > Settings > Change Password. You will need to enter your current password and your new password twice to confirm the change.',
          ),
          _buildFaqItem(
            'How do I join a club?',
            'Browse clubs in the Clubs tab, find one you like, and tap "Join Club". For private clubs, your request will need to be approved by the club admin.',
          ),
          _buildFaqItem(
            'Can I reschedule an activity?',
            'Only the host of an activity can edit or reschedule it. If you are the host, go to the activity detail page, tap the edit button, and change the date and time.',
          ),
          _buildFaqItem(
            'How do I delete my account?',
            'Go to Profile > Settings > Privacy & Security > Delete Account. Note that this action is permanent and cannot be undone.',
          ),
          const SizedBox(height: 24),

          // Contact info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Icon(Icons.headset_mic_outlined, size: 32, color: AppColors.buttonPrimary),
                SizedBox(height: 12),
                Text('Still need help?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                SizedBox(height: 4),
                Text('Our support team is available Monday - Friday, 09:00 - 18:00 WIB', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                SizedBox(height: 8),
                Text('support@spacelink.id', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.buttonPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // App version
          Center(
            child: Text('SpaceLink v1.0.0', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.buttonPrimary, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        children: [
          Text(answer, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}
