import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(RemoteMessage message, {BuildContext? context}) {
    if (context != null) {
      // App is in foreground, show Flushbar
      Flushbar(
        title: message.notification?.title ?? 'Nouvelle notification',
        message: message.notification?.body ?? '',
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: Colors.blue.shade900,
        icon: Icon(Icons.notifications_active, color: Colors.white),
      ).show(context);
    } else {
      // App is in background/closed, show system notification
      _notificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  }
}
