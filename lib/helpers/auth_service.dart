import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Enregistrer le token
  Future<void> saveToken(String token) async {
    try {
    print('save token11 ======= $token');
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      print("✅ Token enregistré avec succès !");
    } catch (e) {
      print("❌ Erreur lors de l'enregistrement du token : $e");
    }
  }

  // Récupérer le token
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

  // Vérifier si le token existe
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

  // Supprimer le token (déconnexion)
  Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      print("✅ Token supprimé !");
    } catch (e) {
      print("❌ Erreur lors de la suppression du token : $e");
    }
  }
}
