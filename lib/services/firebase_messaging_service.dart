import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKey;

  FirebaseMessagingService({required this.navigatorKey});

  Future<void> initialize() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await _messaging.getToken();
        if (kDebugMode) {
          print('🔥 FCM Token: $token');
        }

        // Handle terminated state messages
        FirebaseMessaging.instance.getInitialMessage().then(_handleMessage);

        // Handle background/foreground messages
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
        FirebaseMessaging.onMessage.listen(handleForegroundMessage);

        // Token refresh
        _messaging.onTokenRefresh.listen((token) {
          if (kDebugMode) print('🔄 New FCM token: $token');
        });
      }
    } catch (e) {
      if (kDebugMode) print('❌ Firebase Messaging error: $e');
    }
  }

  void _handleMessage(RemoteMessage? message) {
    if (message == null) return;
    if (kDebugMode) {
      print('📨 Message handled: ${message.messageId}');
      print('📦 Data: ${message.data}');
    }

    if (message.data['screen'] != null) {
      navigatorKey.currentState?.pushNamed(
        '/${message.data['screen']}',
        arguments: message.data,
      );
    }
  }

  Future<void> handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('📬 Foreground message received:');
      print('📝 Title: ${message.notification?.title}');
      print('📄 Body: ${message.notification?.body}');
    }

    final context = navigatorKey.currentContext;
    if (context != null) {
      Flushbar(
        title: message.notification?.title ?? 'Nouvelle notification',
        message: message.notification?.body ?? '',
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: Colors.blue.shade900,
        icon: const Icon(Icons.notifications_active, color: Colors.white),
        onTap: (_) => _handleMessage(message),
      ).show(context);
    }
  }
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('🔔 Background message: ${message.messageId}');
  }
}
