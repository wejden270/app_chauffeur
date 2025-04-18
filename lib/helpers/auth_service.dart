import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ✅ Enregistrer le token
  Future<bool> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return true;
    } catch (e) {
      print("❌ Erreur d'enregistrement du token : $e");
      return false;
    }
  }

  // ✅ Enregistrer l'ID du chauffeur après connexion
  Future<bool> saveDriverId(int driverId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('driverId', driverId);
      return true;
    } catch (e) {
      print("❌ Erreur d'enregistrement du driverId : $e");
      return false;
    }
  }

  // ✅ Récupérer l'ID du chauffeur
  Future<int?> getDriverId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('driverId'); // Retourne null si l'ID n'existe pas
    } catch (e) {
      print("❌ Erreur de récupération du driverId : $e");
      return null;
    }
  }

  // ✅ Récupérer le token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token'); // Retourne null si le token n'existe pas
    } catch (e) {
      print("❌ Erreur de récupération du token : $e");
      return null;
    }
  }

  // ✅ Vérifier si le token existe
  Future<bool> isTokenExist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('token');
    } catch (e) {
      print("❌ Erreur de vérification du token : $e");
      return false;
    }
  }

  // ✅ Supprimer le token et l'ID du chauffeur (déconnexion)
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('driverId');
      return true;
    } catch (e) {
      print("❌ Erreur lors de la déconnexion : $e");
      return false;
    }
  }
}
