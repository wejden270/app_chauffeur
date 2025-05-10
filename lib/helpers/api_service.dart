import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    return 'http://192.168.1.110:8000/api'; // remplace par l'IP réelle de ton PC
  }

  static Future<void> updateDriverFCMToken(String driverId, String fcmToken) async {
    final url = Uri.parse('$baseUrl/driver/$driverId/fcm-token');

    final payload = {
      'fcm_token': fcmToken,
      'device_type': 'android',
    };

    print('📤 Envoi du token FCM au serveur');
    print('URL: $url');
    print('Payload: $payload');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('✅ Token FCM mis à jour avec succès sur le serveur');
      } else {
        print('❌ Échec de la mise à jour du token FCM. Code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('🔥 Erreur lors de la mise à jour du token FCM: $e');
    }
  }
  static Future<void> updateChauffeurLocation(String driverId, double latitude, double longitude) async {
  final url = Uri.parse('$baseUrl/driver/$driverId/location');

  final payload = {
    'latitude': latitude,
    'longitude': longitude,
  };

  print('📍 Envoi de la position du chauffeur au serveur');
  print('URL: $url');
  print('Payload: $payload');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('✅ Position mise à jour avec succès');
    } else {
      print('❌ Échec de la mise à jour de la position. Code: ${response.statusCode}, Body: ${response.body}');
    }
  } catch (e) {
    print('🔥 Erreur lors de la mise à jour de la position : $e');
  }
}

}
