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
    final url = "http://127.0.0.1:8000/api/driver/{id}/profile";

    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/driver/$driverId/profile'));
    print('Request URL: $url');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return Chauffeur.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Impossible de récupérer les données du chauffeur. Erreur: ${response.statusCode}");
    }
  }

  Future<bool> updateChauffeurProfile(Map<String, String> data, File? image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? driverId = prefs.getInt('driverId');

    if (driverId == null) {
      throw Exception("Aucun chauffeur connecté, veuillez vous reconnecter.");
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

      if (response.statusCode == 200) {
        return true;
      } else {
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

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('driverId');
  }
}
