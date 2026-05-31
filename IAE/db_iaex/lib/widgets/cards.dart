import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/formatters.dart';

// ═══════════════════════════════════════════════════════════════
// Community Card
// ═══════════════════════════════════════════════════════════════

/// Community card — cover image, name, category, members, location
class CommunityCard extends StatelessWidget {
  final String name;
  final String? image;
  final String sportCategory;
  final int memberCount;
  final String? location;
  final String? activityFrequency;
  final bool isJoined;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;

  const CommunityCard({
    super.key,
    required this.name,
    this.image,
    required this.sportCategory,
    this.memberCount = 0,
    this.location,
    this.activityFrequency,
    this.isJoined = false,
    this.onTap,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF101820).withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 64,
                height: 64,
                color: AppColors.softGray,
                child: image != null
                    ? Image.network(
                        image!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.groups_rounded,
                          color: AppColors.textMuted,
                        ),
                      )
                    : const Icon(
                        Icons.groups_rounded,
                        color: AppColors.textMuted,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.chipBackground,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          sportCategory.isNotEmpty ? '${sportCategory[0].toUpperCase()}${sportCategory.substring(1)}' : '',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.chipText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.people_outline_rounded,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '$memberCount',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          location!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!isJoined && onJoin != null)
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: onJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Join',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              )
            else if (isJoined)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Joined',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Activity Card
// ═══════════════════════════════════════════════════════════════

/// Activity card — title, sport, location, date, slots, price, level badge
class ActivityCard extends StatelessWidget {
  final String title;
  final String sportType;
  final String? location;
  final String? date;
  final String? time;
  final int quota;
  final int currentParticipants;
  final double cost;
  final String? skillLevel;
  final String? activityType;
  final String status;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.title,
    required this.sportType,
    this.location,
    this.date,
    this.time,
    this.quota = 10,
    this.currentParticipants = 0,
    this.cost = 0,
    this.skillLevel,
    this.activityType,
    this.status = 'available',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = quota - currentParticipants;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF101820).withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.chipActiveBackground,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    sportType.isNotEmpty ? '${sportType[0].toUpperCase()}${sportType.substring(1)}' : '',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.chipActiveText,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                if (activityType != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.chipBackground,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      Formatters.capitalizeWords(activityType!.replaceAll('_', ' ')),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.chipText,
                      ),
                    ),
                  ),
                ],
                if (skillLevel != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.chipBackground,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      Formatters.capitalizeWords(skillLevel!),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.chipText,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            if (date != null || time != null)
              _infoRow(
                Icons.calendar_today_rounded,
                '${date != null ? Formatters.formatDate(date, includeYear: true) : ''} ${time != null ? "• ${Formatters.formatTime(time)}" : ""}'.trim(),
              ),
            if (location != null)
              _infoRow(Icons.location_on_outlined, location!),
            _infoRow(
              Icons.people_outline_rounded,
              '$currentParticipants/$quota ($remaining slots left)',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  Formatters.formatPrice(cost),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Friend Card
// ═══════════════════════════════════════════════════════════════

/// Friend card — avatar, name, distance, sports, skill badge, add button
class FriendCard extends StatelessWidget {
  final String name;
  final String? profileImage;
  final String? location;
  final String? distance;
  final List<String> sports;
  final String? skillLevel;
  final String friendStatus;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final VoidCallback? onMessage;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const FriendCard({
    super.key,
    required this.name,
    this.profileImage,
    this.location,
    this.distance,
    this.sports = const [],
    this.skillLevel,
    this.friendStatus = 'none',
    this.onTap,
    this.onAdd,
    this.onMessage,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF101820).withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            UserAvatar(name: name, imageUrl: profileImage, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (distance != null) ...[
                        const Icon(
                          Icons.near_me_outlined,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          distance!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (location != null) ...[
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (sports.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: sports
                          .take(3)
                          .map(
                            (s) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.chipBackground,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                s,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.chipText,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (friendStatus == 'none' && onAdd != null)
                  GestureDetector(
                    onTap: onAdd,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.buttonPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  )
                else if (friendStatus == 'pending')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Pending',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  )
                else if (friendStatus == 'pending_received') ...[
                  if (onAccept != null)
                    GestureDetector(
                      onTap: onAccept,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (onReject != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onReject,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
                
                if (friendStatus == 'accepted') ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onMessage ?? () {},
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Status Badge
// ═══════════════════════════════════════════════════════════════

/// Status badge — available/full/waiting/joined/canceled/present/absent/late
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'available' || 'present' || 'confirmed' || 'success' || 'active':
        bg = AppColors.success.withValues(alpha: 0.1);
        fg = AppColors.success;
      case 'full' || 'canceled' || 'absent' || 'failed' || 'error':
        bg = AppColors.errorRed.withValues(alpha: 0.1);
        fg = AppColors.errorRed;
      case 'waiting' || 'pending' || 'late' || 'warning':
        bg = AppColors.warning.withValues(alpha: 0.1);
        fg = AppColors.warning;
      case 'joined' || 'completed':
        bg = AppColors.buttonPrimary.withValues(alpha: 0.1);
        fg = AppColors.buttonPrimary;
      case 'beginner':
        bg = AppColors.success.withValues(alpha: 0.08);
        fg = AppColors.success;
      case 'intermediate':
        bg = AppColors.warning.withValues(alpha: 0.08);
        fg = AppColors.warning;
      case 'advanced' || 'pro' || 'professional':
        bg = AppColors.errorRed.withValues(alpha: 0.08);
        fg = AppColors.errorRed;
      default:
        bg = AppColors.chipBackground;
        fg = AppColors.chipText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// User Avatar
// ═══════════════════════════════════════════════════════════════

/// Circular avatar with fallback initials
class UserAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;

  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .where((w) => w.isNotEmpty)
              .take(2)
              .map((w) => w[0].toUpperCase())
              .join()
        : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceContainerHigh,
        image: imageUrl != null
            ? DecorationImage(
                image: imageUrl!.startsWith('data:image')
                    ? MemoryImage(base64Decode(imageUrl!.split(',').last)) as ImageProvider
                    : NetworkImage(imageUrl!),
                fit: BoxFit.cover,
                onError: (_, _) {},
              )
            : null,
      ),
      child: imageUrl == null
          ? Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : null,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Empty State
// ═══════════════════════════════════════════════════════════════

/// Empty state placeholder with icon and message
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 56,
            color: AppColors.textMuted.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Section Header
// ═══════════════════════════════════════════════════════════════

/// Section header with title and "See All" action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
