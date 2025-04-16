import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chauffeur_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ChauffeurService {
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else if (Platform.isAndroid && !kIsWeb) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://192.168.1.110:8000/api';
    }
  }

  String get apiUrl => "$baseUrl/driver/";

  Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('driverId') != null;
  }

  Future<Chauffeur> fetchChauffeurInfo(int driverId) async {
    final url = "$apiUrl$driverId/profile";
    final response = await http.get(Uri.parse(url));

    print('Request URL: $url');
    print('Response status: ${response.statusCode}');
    print('Response body brut: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final jsonBody = json.decode(response.body);
        if (jsonBody.containsKey("data")) {
          return Chauffeur.fromJson(jsonBody["data"]);
        } else {
          throw Exception("Format JSON invalide : clé 'data' manquante.");
        }
      } catch (e) {
        throw Exception("Erreur lors du parsing JSON : $e");
      }
    } else {
      throw Exception("Impossible de récupérer les données du chauffeur. Erreur: ${response.statusCode}");
    }
  }

  Future<Chauffeur> updateChauffeurProfile(Map<String, String> data, File? image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? driverId = prefs.getInt('driverId');

    print("🔍 Vérification driverId avant mise à jour : $driverId"); // Ajoute cette ligne pour voir si l'ID est bien stocké

    if (driverId == null) {
      throw Exception("❌ Aucun chauffeur connecté. Assurez-vous d'être connecté et réessayez.");
    }

    var request = http.MultipartRequest("POST", Uri.parse("$apiUrl$driverId/update"));

    data.forEach((key, value) {
      request.fields[key] = value;
    });

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath("photo", image.path));
    }

    try {
      var response = await request.send();
      final responseString = await response.stream.bytesToString();
      final Map<String, dynamic> jsonResponse = jsonDecode(responseString);

      if (response.statusCode == 200) {
        return Chauffeur.fromJson(jsonResponse["data"]);
      } else {
        throw Exception(jsonResponse.containsKey("message") ? jsonResponse["message"] : "Erreur lors de la mise à jour du profil.");
      }
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('driverId');
    print("🔹 Déconnexion réussie, driverId supprimé.");
  }

  Future<void> saveDriverId(int driverId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('driverId', driverId);
    print("✅ driverId enregistré : $driverId");
  }
}
