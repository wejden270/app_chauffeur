import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chauffeur_model.dart';

class ChauffeurService {
  static const String BASE_URL = "http://10.0.2.2:8000/api";  // Pour Android Emulator
  final String apiUrl = "$BASE_URL/driver/";

  /// Vérifier si un chauffeur est authentifié
  Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  /// Récupérer les infos du chauffeur en utilisant l'ID
  Future<Chauffeur> fetchChauffeurInfo(int driverId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('prefs =========== $prefs');

    String? token = prefs.getString('auth_token');
    print('token =========== $token');
    if (token == null) {
      throw Exception("Token introuvable, veuillez vous reconnecter.");
    }

    // URL mise à jour pour inclure l'ID du chauffeur
    final url = "$apiUrl$driverId/profile"; // L'ID du chauffeur est ajouté ici

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    print('response ===== ');
    print(response.statusCode);
    if (response.statusCode == 200) {
      return Chauffeur.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      await prefs.remove('token'); // Supprimer le token expiré
      throw Exception("Session expirée. Veuillez vous reconnecter.");
    } else {
      throw Exception("Impossible de récupérer les données du chauffeur. Erreur: ${response.statusCode}");
    }
  }

  /// Mettre à jour le profil du chauffeur (avec ou sans photo)
  Future<bool> updateChauffeurProfile(Map<String, String> data, File? image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Token introuvable, veuillez vous reconnecter.");
    }

    var request = http.MultipartRequest("POST", Uri.parse("$apiUrl/update"));
    request.headers['Authorization'] = 'Bearer $token';

    // Ajouter les champs du formulaire
    data.forEach((key, value) {
      request.fields[key] = value;
    });

    // Ajouter la photo si présente
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath("photo", image.path));
    }

    try {
      var response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return true;
      } else {
        // Vérifier si la réponse est JSON ou autre
        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(responseString);
          throw Exception(jsonResponse['message'] ?? "Erreur lors de la mise à jour du profil.");
        } catch (_) {
          throw Exception("Erreur inconnue: $responseString");
        }
      }
    } catch (e) {
      throw Exception("Erreur de connexion: $e");
    }
  }

  /// Déconnexion du chauffeur
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Supprime le token
  }
}
