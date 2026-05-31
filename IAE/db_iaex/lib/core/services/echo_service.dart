import 'package:flutter/foundation.dart';
import 'package:laravel_echo/laravel_echo.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'storage_service.dart';

class EchoService {
  final StorageService _storage;
  Echo? _echo;

  EchoService({required StorageService storage}) : _storage = storage;

  Future<void> initEcho() async {
    final token = await _storage.getToken();
    if (token == null) return;

    // Use your reverb credentials from .env
    const String pusherKey = 'reverb_app_key'; // Update if needed

    PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
    
    // In Laravel Echo with Pusher Channels Flutter, we usually initialize Pusher first
    try {
      await pusher.init(
        apiKey: pusherKey,
        cluster: 'mt1', // Reverb ignores this but it's required by some clients
        authEndpoint: 'http://10.0.2.2:8000/api/broadcasting/auth', // or 8000 depending on your setup
        authParams: {
          'headers': {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          }
        },
        useTLS: false,
      );

      await pusher.connect();
    } catch (e) {
      debugPrint('Pusher init error: $e');
    }

    _echo = Echo(
      broadcaster: EchoBroadcasterType.Pusher,
      client: pusher,
      options: {
        'authEndpoint': 'http://10.0.2.2:8000/api/broadcasting/auth',
        'auth': {
          'headers': {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          }
        }
      },
    );
  }

  Echo? get echo => _echo;

  void disconnect() {
    _echo?.disconnect();
    _echo = null;
  }
}
