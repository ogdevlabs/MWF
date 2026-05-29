import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../firebase_options.dart';

/// Top-level background message handler.
/// MUST be top-level (not a method) — runs in a separate isolate.
/// Only shows a local notification — no Riverpod, no Drift access.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Background notifications are automatically shown by the OS via FCM
  // notification payload. No flutter_local_notifications needed here.
}

/// Android notification channel for coach replies.
const AndroidNotificationChannel coachRepliesChannel =
    AndroidNotificationChannel(
  'coach_replies',
  'Coach Replies',
  description: 'Notifications when your coach replies',
  importance: Importance.high,
);

class FcmService {
  FcmService({
    required this.supabase,
    required this.router,
  });

  final SupabaseClient supabase;
  final GoRouter router;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize FCM: request permission, create Android channel, set up handlers.
  Future<void> initialize() async {
    // Request permission (iOS will show prompt; Android 13+ requires runtime permission)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(coachRepliesChannel);

    // Initialize flutter_local_notifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
    );

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // Set up background message handler (top-level function)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle notification tap when app was terminated
    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleMessageNavigation(initialMessage.data);
    }

    // Handle notification tap when app was in background
    FirebaseMessaging.onMessageOpenedApp
        .listen((msg) => handleMessageNavigation(msg.data));
  }

  /// Register FCM token for current user. Call after sign-in.
  ///
  /// Obtains the token from FirebaseMessaging and upserts it to Supabase.
  /// Also sets up a listener for token refresh.
  Future<void> registerToken(String studentId) async {
    final token = await FirebaseMessaging.instance.getToken();
    await registerTokenDirect(studentId: studentId, token: token);

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await registerTokenDirect(studentId: studentId, token: newToken);
    });
  }

  /// Testable token registration that bypasses FirebaseMessaging.
  ///
  /// Upserts [token] to `students.fcm_token` for [studentId].
  /// Does nothing when [token] is null.
  @visibleForTesting
  Future<void> registerTokenDirect({
    required String studentId,
    required String? token,
  }) async {
    if (token == null) return;
    await supabase
        .from('students')
        .update({'fcm_token': token}).eq('id', studentId);
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          coachRepliesChannel.id,
          coachRepliesChannel.name,
          channelDescription: coachRepliesChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// Called when user taps a local notification.
  ///
  /// Exposed as non-private to allow unit testing of navigation logic.
  @visibleForTesting
  void onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    final data = jsonDecode(response.payload!) as Map<String, dynamic>;
    handleMessageNavigation(data);
  }

  /// Navigate based on message data. Called for FCM message taps and
  /// notification response taps.
  ///
  /// Exposed as non-private to allow unit testing of navigation logic.
  @visibleForTesting
  void handleMessageNavigation(Map<String, dynamic> data) {
    if (data['type'] == 'coach_reply') {
      router.go('/coach-chat');
    }
  }
}
