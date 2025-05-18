import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ApiService {
  // URL de base pour l'API
  static const String baseUrl = 'http://192.168.1.110:8000/api/driver';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      
      if (fcmToken == null) {
        if (kDebugMode) {
          print('⚠️ FCM Token manquant');
        }
        throw Exception('Token FCM non disponible');
      }

      if (kDebugMode) {
        print('🔑 Tentative de connexion...');
        print('📧 Email: $email');
        print('🎟️ FCM Token: $fcmToken');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
          'fcm_token': fcmToken,
          'device_type': 'android',
        }),
      );

      if (kDebugMode) {
        print('📥 Réponse brute: ${response.body}');
        print('📊 Status code: ${response.statusCode}');
      }

      if (response.statusCode != 200) {
        Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 
                       errorData['error'] ?? 
                       'Échec de la connexion (${response.statusCode})');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      
      if (data['user'] == null) {
        throw Exception('Données utilisateur manquantes dans la réponse');
      }

      return data;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur complète: $e');
      }
      rethrow;  // Permet de propager l'erreur exacte
    }
  }
}
