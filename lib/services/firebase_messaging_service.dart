import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKey;
  
  // Mise à jour de l'URL de base selon l'environnement
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000'; // URL pour l'émulateur Android
    } else {
      return 'http://192.168.1.110:8000'; // URL pour les appareils réels
    }
  }

  FirebaseMessagingService({required this.navigatorKey});

  Future<void> initialize() async {
    try {
      // Vérifier le token existant au démarrage
      String? currentToken = await _messaging.getToken();
      if (kDebugMode) {
        print('🔄 Token FCM actuel: $currentToken');
      }

      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: true,
        carPlay: true,
        criticalAlert: true,
      );

      if (kDebugMode) {
        print('⚙️ Paramètres de notification:');
        print('Alert: ${settings.alert}');
        print('Badge: ${settings.badge}');
        print('Sound: ${settings.sound}');
        print('Authorization: ${settings.authorizationStatus}');
      }

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Configuration des handlers de message
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
        FirebaseMessaging.onMessage.listen(handleForegroundMessage);
        
        RemoteMessage? initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleMessage(initialMessage);
        }
      } else {
        if (kDebugMode) {
          print('❌ Les notifications ne sont pas autorisées');
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Firebase Messaging error: $e');
    }
  }

  Future<String?> getFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        if (kDebugMode) print('📱 Token FCM obtenu: $token');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
      }
      return token;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur lors de la récupération du token FCM: $e');
      return null;
    }
  }

  Future<bool> updateFCMToken(String token, String userId) async {
    try {
      if (userId.isEmpty || token.isEmpty) {
        if (kDebugMode) {
          print('❌ UserId ou token manquant');
          print('UserId: $userId');
          print('Token: $token');
        }
        return false;
      }

      final url = '$_baseUrl/api/driver/fcm/token/update';
      
      if (kDebugMode) {
        print('📤 Envoi du token FCM au serveur');
        print('URL: $url');
        print('Payload: {fcm_token: $token, driver_id: $userId}');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': token,
          'driver_id': userId,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
        }),
      );

      if (kDebugMode) {
        print('📥 Réponse du serveur: ${response.statusCode}');
        print('Corps de la réponse: ${response.body}');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception lors de la mise à jour du token FCM:');
        print('URL utilisée: $_baseUrl');
        print('Exception: ${e.toString()}');
      }
      return false;
    }
  }

  Future<void> initializeFirebaseMessaging(String userId) async {
    try {
      if (kDebugMode) {
        print('🚀 Initialisation FCM pour userId: $userId');
      }

      NotificationSettings settings = await _messaging.requestPermission();
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await getFCMToken();
        if (token != null) {
          bool success = await updateFCMToken(token, userId);
          if (kDebugMode) {
            print('✅ Mise à jour du token FCM: ${success ? 'réussie' : 'échouée'}');
          }
        }

        // Écouter les changements de token
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
          bool success = await updateFCMToken(newToken, userId);
          if (kDebugMode) {
            print('🔄 Token FCM rafraîchi: ${success ? 'réussi' : 'échoué'}');
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de l\'initialisation FCM: $e');
      }
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
      print('📬 Message reçu en premier plan:');
      print('Message ID: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
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
    print('🔔 Message reçu en arrière-plan:');
    print('Message ID: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
  }
}
