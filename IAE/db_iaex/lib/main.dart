import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'core/theme/app_theme.dart';
import 'core/services/storage_service.dart';
import 'core/services/api_client.dart';
import 'core/services/echo_service.dart';
import 'core/router/app_router.dart';

import 'providers/auth_provider.dart';
import 'providers/friends_provider.dart';
import 'providers/communities_provider.dart';
import 'providers/activities_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/attendance_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Sign-In with serverClientId for Android
  await GoogleSignIn.instance.initialize(
    // Note: Ganti dengan Android Client ID dari Google Cloud Console
    clientId:
        '950160751571-2kaft2i38idsbd575n48lnli6ftqaas2.apps.googleusercontent.com',
    serverClientId:
        '950160751571-4d4p45gf4d8mqlmbtsuhfnngqjsr78vq.apps.googleusercontent.com',
  );

  final storage = StorageService();

  final apiClient = ApiClient(storage: storage);

  final echoService = EchoService(storage: storage);
  await echoService.initEcho();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(api: apiClient, storage: storage),
        ),
        ChangeNotifierProvider(create: (_) => FriendsProvider(api: apiClient)),
        ChangeNotifierProvider(
          create: (_) => CommunitiesProvider(api: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => ActivitiesProvider(api: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(api: apiClient, echoService: echoService),
        ),
        ChangeNotifierProvider(create: (_) => BookingProvider(api: apiClient)),
        ChangeNotifierProvider(create: (_) => FeedProvider(api: apiClient)),
        ChangeNotifierProvider(
          create: (_) => AttendanceProvider(api: apiClient),
        ),
      ],
      child: const SpaceLinkApp(),
    ),
  );
}

class SpaceLinkApp extends StatelessWidget {
  const SpaceLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SpaceLink',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router(context),
      debugShowCheckedModeBanner: false,
    );
  }
}
