import '../utils/constants.dart';

class FCMService {
  Future<bool> updateFcmToken(String driverId, String fcmToken) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/driver/$driverId/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': fcmToken,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Token FCM mis à jour avec succès');
        return true;
      }
      
      print('❌ Échec de la mise à jour du token FCM: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du token FCM: $e');
      return false;
    }
  }
}
