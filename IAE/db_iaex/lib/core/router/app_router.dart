import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/profile_setup_screen.dart';
import '../../screens/main/main_layout.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/friends/search_friends_screen.dart';
import '../../screens/friends/friend_detail_screen.dart';
import '../../screens/friends/friend_requests_screen.dart';
import '../../screens/friends/my_friends_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/communities/search_communities_screen.dart';
import '../../screens/communities/community_detail_screen.dart';
import '../../screens/communities/create_community_screen.dart';
import '../../screens/communities/community_management_screen.dart';
import '../../screens/communities/edit_community_screen.dart';
import '../../screens/communities/community_members_screen.dart';
import '../../screens/communities/pending_requests_screen.dart';
import '../../screens/communities/assign_admins_screen.dart';
import '../../screens/activities/activity_list_screen.dart';
import '../../screens/activities/create_activity_screen.dart';
import '../../screens/activities/edit_activity_screen.dart';
import '../../screens/activities/event_detail_screen.dart';
import '../../screens/activities/rsvp_screen.dart';
import '../../screens/activities/attendance_screen.dart';
import '../../screens/activities/select_existing_activity_screen.dart';
import '../../screens/activities/activity_invitations_screen.dart';
import '../../screens/chat/chat_list_screen.dart';
import '../../screens/chat/chat_detail_screen.dart';
import '../../screens/chat/group_chat_screen.dart';
import '../../screens/feed/community_feed_screen.dart';
import '../../screens/booking/court_booking_screen.dart';
import '../../screens/booking/booking_confirmation_screen.dart';
import '../../screens/history/activity_history_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/profile/settings_screen.dart';
import '../../screens/profile/setup_profile_screen.dart';
import '../../screens/settings/change_password_screen.dart';
import '../../screens/settings/language_screen.dart';
import '../../screens/settings/privacy_security_screen.dart';
import '../../screens/settings/terms_of_service_screen.dart';
import '../../screens/settings/privacy_policy_screen.dart';
import '../../screens/settings/help_center_screen.dart';

/// App router using go_router with shell route for bottom nav
class AppRouter {
  static GoRouter router(BuildContext context) {
    return GoRouter(
      initialLocation: '/splash',
      routes: [
        // ─── Pre-auth screens ───
        GoRoute(path: '/', redirect: (_, _) => '/home'),
        GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const OnboardingScreen(),
        ),
        GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
        GoRoute(
          path: '/profile-setup',
          builder: (_, _) => const ProfileSetupScreen(),
        ),

        // ─── Main app with bottom nav ───
        ShellRoute(
          builder: (context, state, child) => MainLayout(child: child),
          routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            GoRoute(
              path: '/friends',
              builder: (_, _) => const SearchFriendsScreen(),
            ),
            GoRoute(
              path: '/communities',
              builder: (_, _) => const SearchCommunitiesScreen(),
            ),
            GoRoute(
              path: '/activities',
              builder: (_, _) => const ActivityListScreen(),
            ),
            GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          ],
        ),

        // ─── Detail / sub-screens ───
        GoRoute(
          path: '/notifications',
          builder: (_, _) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/friend/:id',
          builder: (_, state) => FriendDetailScreen(
            friendId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/community/create',
          builder: (_, _) => const CreateCommunityScreen(),
        ),
        GoRoute(
          path: '/community/:id',
          builder: (_, state) => CommunityDetailScreen(
            communityId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/community/:id/manage',
          builder: (_, state) => CommunityManagementScreen(
            communityId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/community/:id/edit',
          builder: (_, state) => EditCommunityScreen(
            communityId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/community/:id/members',
          builder: (_, state) => CommunityMembersScreen(
            communityId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/community/:id/pending',
          builder: (_, state) => PendingRequestsScreen(
            communityId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/community/:id/admins',
          builder: (_, state) => AssignAdminsScreen(
            communityId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/activity/create',
          builder: (_, _) => const CreateActivityScreen(),
        ),
        GoRoute(
          path: '/activities/invitations',
          builder: (_, _) => const ActivityInvitationsScreen(),
        ),
        GoRoute(
          path: '/activity/select-existing/:friendId',
          builder: (_, state) => SelectExistingActivityScreen(
            friendId: int.parse(state.pathParameters['friendId']!),
          ),
        ),
        GoRoute(
          path: '/activity/:id',
          builder: (_, state) => EventDetailScreen(
            activityId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/activity/:id/edit',
          builder: (_, state) => const EditActivityScreen(),
        ),
        GoRoute(
          path: '/activity/:id/rsvp',
          builder: (_, state) =>
              RsvpScreen(activityId: int.parse(state.pathParameters['id']!)),
        ),
        GoRoute(
          path: '/activity/:id/attendance',
          builder: (_, state) => AttendanceScreen(
            activityId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(path: '/chat', builder: (_, _) => const ChatListScreen()),
        GoRoute(
          path: '/chat/:id',
          builder: (_, state) => ChatDetailScreen(
            conversationId: int.parse(state.pathParameters['id']!),
            name: state.uri.queryParameters['name'] ?? '',
          ),
        ),
        GoRoute(
          path: '/group-chat/:id',
          builder: (_, state) => GroupChatScreen(
            groupId: int.parse(state.pathParameters['id']!),
            groupName: state.uri.queryParameters['name'] ?? '',
          ),
        ),
        GoRoute(
          path: '/feed',
          builder: (_, state) {
            final cId = state.uri.queryParameters['communityId'];
            return CommunityFeedScreen(
              communityId: cId != null ? int.tryParse(cId) : null,
            );
          },
        ),
        GoRoute(
          path: '/booking',
          builder: (_, _) => const CourtBookingScreen(),
        ),
        GoRoute(
          path: '/booking/confirm',
          builder: (_, _) => const BookingConfirmationScreen(),
        ),
        GoRoute(
          path: '/setup-profile',
          builder: (_, state) => const SetupProfileScreen(),
        ),
        GoRoute(
          path: '/activity-history',
          builder: (_, state) => const ActivityHistoryScreen(),
        ),
        GoRoute(
          path: '/edit-profile',
          builder: (_, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/friends/requests',
          builder: (_, _) => const FriendRequestsScreen(),
        ),
        GoRoute(
          path: '/friends/my',
          builder: (_, _) => const MyFriendsScreen(),
        ),

        // ─── Settings sub-screens ───
        GoRoute(
          path: '/settings/change-password',
          builder: (_, _) => const ChangePasswordScreen(),
        ),
        GoRoute(
          path: '/settings/language',
          builder: (_, _) => const LanguageScreen(),
        ),
        GoRoute(
          path: '/settings/privacy-security',
          builder: (_, _) => const PrivacySecurityScreen(),
        ),
        GoRoute(
          path: '/settings/terms',
          builder: (_, _) => const TermsOfServiceScreen(),
        ),
        GoRoute(
          path: '/settings/privacy-policy',
          builder: (_, _) => const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: '/settings/help',
          builder: (_, _) => const HelpCenterScreen(),
        ),
      ],
    );
  }
}
