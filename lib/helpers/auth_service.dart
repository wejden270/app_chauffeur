import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ✅ Enregistrer le token
  Future<void> saveToken(String token) async {
    try {
      print('save token ======= $token');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      print("✅ Token enregistré avec succès !");
    } catch (e) {
      print("❌ Erreur lors de l'enregistrement du token : $e");
    }
  }

  // ✅ Enregistrer l'ID du chauffeur après connexion
  Future<void> saveDriverId(int driverId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('driverId', driverId);
      print("✅ driverId enregistré : $driverId");
    } catch (e) {
      print("❌ Erreur lors de l'enregistrement du driverId : $e");
    }
  }

  // ✅ Récupérer l'ID du chauffeur
  Future<int?> getDriverId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? driverId = prefs.getInt('driverId');
      print("🔍 driverId récupéré : $driverId");
      return driverId;
    } catch (e) {
      print("❌ Erreur lors de la récupération du driverId : $e");
      return null;
    }
  }

  // ✅ Récupérer le token
  Future<String?> getToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      print("🔍 Token récupéré : $token");
      return token;
    } catch (e) {
      print("❌ Erreur lors de la récupération du token : $e");
      return null;
    }
  }

  // ✅ Vérifier si le token existe
  Future<bool> isTokenExist() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool exists = prefs.containsKey('token');
      print("🔍 Token existe ? $exists");
      return exists;
    } catch (e) {
      print("❌ Erreur lors de la vérification du token : $e");
      return false;
    }
  }

  // ✅ Supprimer le token et l'ID du chauffeur (déconnexion)
  Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('driverId'); // 🔹 Supprimer aussi l'ID du chauffeur
      print("✅ Déconnexion réussie, token et driverId supprimés !");
    } catch (e) {
      print("❌ Erreur lors de la suppression du token et du driverId : $e");
    }
  }
}
