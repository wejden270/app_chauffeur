import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chauffeur_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../services/firebase_messaging_service.dart';

class ChauffeurService {
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else {
      return 'http://192.168.1.110:8000/api'; // Toujours utiliser l'IP locale pour les appareils physiques
    }
  }

  String get apiUrl => "$baseUrl/driver/";

  // Vérifie si le chauffeur est authentifié
  Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('driverId') != null;
  }

  // Récupère les informations du chauffeur
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

  // Met à jour le profil du chauffeur, y compris le token FCM
  Future<Chauffeur> updateChauffeurProfile(Map<String, String> data, File? image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? driverId = prefs.getInt('driverId');

    print("🔍 Vérification driverId avant mise à jour : $driverId");

    if (driverId == null) {
      throw Exception("❌ Aucun chauffeur connecté. Assurez-vous d'être connecté et réessayez.");
    }

    // Récupérer le FCM token
    String? fcmToken = await getFcmToken();
    if (fcmToken != null) {
      data['fcm_token'] = fcmToken;
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

  Future<String?> getFcmToken() async {
    try {
      final messagingService = FirebaseMessagingService(
        navigatorKey: GlobalKey<NavigatorState>(),
      );
      return await messagingService.getFCMToken();
    } catch (e) {
      print('❌ Erreur lors de la récupération du FCM token: $e');
      return null;
    }
  }

  // Envoie du token FCM au serveur
  Future<bool> updateFCMToken(String token, int driverId) async {
    final url = "$apiUrl$driverId/fcm/token"; // Endpoint pour mettre à jour le token

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': token,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
        }),
      );

      if (response.statusCode == 200) {
        print('🔄 Token FCM mis à jour avec succès');
        return true;
      } else {
        print('❌ Erreur lors de la mise à jour du token FCM: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur de connexion : $e');
      return false;
    }
  }

  // Déconnecte le chauffeur et supprime son ID des préférences partagées
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('driverId');
    print("🔹 Déconnexion réussie, driverId supprimé.");
  }

  // Enregistre l'ID du chauffeur dans les préférences partagées
  Future<void> saveDriverId(int driverId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('driverId', driverId);
    print("✅ driverId enregistré : $driverId");
  }
}
