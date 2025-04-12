import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 🔹 Définition de l'URL de base selon la plateforme
  static String get baseUrl {
    // true = téléphone réel, false = émulateur
    const bool isPhysicalDevice = true;

    if (defaultTargetPlatform == TargetPlatform.android && !isPhysicalDevice) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://192.168.1.110:8000/api'; // remplace par ton IP locale
    }
  }


  // 🔹 INSCRIPTION CHAUFFEUR
  static Future<Map<String, dynamic>> registerDriver(Map<String, dynamic> driverData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/driver/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(driverData),
      );

      print("🔹 [INSCRIPTION] Code: ${response.statusCode}, Réponse: ${response.body}");

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {'error': _handleError(response)};
      }
    } catch (e) {
      return {'error': 'Erreur de connexion : $e'};
    }
  }

  // 🔹 CONNEXION CHAUFFEUR
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/driver/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim(),
          'password': password,
        }),
      );

      print("🔹 [CONNEXION] Code: ${response.statusCode}, Réponse: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          await saveToken(data['token']); // Sauvegarder le token après la connexion
        }
        return data;
      } else {
        return {'error': _handleError(response)};
      }
    } catch (e) {
      return {'error': 'Erreur de connexion : $e'};
    }
  }

  // 🔹 ENREGISTRER LE TOKEN (Stockage sécurisé)
  static Future<void> saveToken(String token) async {
    print('save token ======= $token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // 🔹 RÉCUPÉRER LE TOKEN
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // 🔹 SUPPRIMER LE TOKEN (Déconnexion)
  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // 🔹 LOGOUT (Déconnexion)
  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/driver/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        print("🔹 [LOGOUT] Code: ${response.statusCode}, Réponse: ${response.body}");

        if (response.statusCode == 200) {
          await deleteToken(); // Supprime le token local
        } else {
          throw Exception("Erreur de déconnexion");
        }
      } else {
        throw Exception("Token non trouvé");
      }
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      throw e;
    }
  }

  // 🔹 RÉCUPÉRER LE PROFIL DU CHAUFFEUR
  static Future<Map<String, dynamic>> getChauffeurProfile() async {
    try {
      final token = await getToken(); // Vérifie si le token existe
      if (token == null) {
        return {'error': 'Token introuvable, veuillez vous reconnecter'}; // Retourne une erreur si pas de token
      }

      final response = await http.get(
        Uri.parse('$baseUrl/driver/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("🔹 [PROFIL CHAUFFEUR] Code: ${response.statusCode}, Réponse: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': _handleError(response)};
      }
    } catch (e) {
      return {'error': 'Erreur de connexion : $e'};
    }
  }

  // 🔹 RÉCUPÉRER LES DONNÉES D'UN CHAUFFEUR SPÉCIFIQUE
  static Future<Map<String, dynamic>> getDriverData(String driverId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/driver/$driverId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("🔹 [DONNÉES CHAUFFEUR] Code: ${response.statusCode}, Réponse: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': _handleError(response)};
      }
    } catch (e) {
      return {'error': 'Erreur de connexion : $e'};
    }
  }

  // 🔹 METTRE À JOUR LE STATUT DU CHAUFFEUR
  static Future<Map<String, dynamic>> updateChauffeurStatus(String newStatus) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/driver/update-status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': newStatus}),
      );

      print("🔹 [MISE À JOUR STATUT] Code: ${response.statusCode}, Réponse: ${response.body}");

      return json.decode(response.body);
    } catch (e) {
      print("Erreur lors de la mise à jour du statut : $e");
      return {'error': 'Erreur lors de la mise à jour du statut'};
    }
  }

  // 🔹 METTRE À JOUR LA LOCALISATION DU CHAUFFEUR
  static Future<bool> updateChauffeurLocationSimple(String driverId, double latitude, double longitude) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/driver/update-location'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'driver_id': driverId,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      print("🔹 [MISE À JOUR LOCALISATION] Code: ${response.statusCode}, Réponse: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Erreur lors de la mise à jour de la localisation : $e");
      return false;
    }
  }

  // 🔹 RÉCUPÉRER LES MISSIONS
  static Future<List<dynamic>> getMissions() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/missions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("🔹 [MISSIONS] Code: ${response.statusCode}, Réponse: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // 🔹 GESTION DES ERREURS HTTP
  static String _handleError(http.Response response) {
    try {
      final Map<String, dynamic> errorData = json.decode(response.body);
      return errorData['message'] ?? 'Erreur inconnue (${response.statusCode})';
    } catch (e) {
      return 'Erreur de traitement (${response.statusCode})';
    }
  }
}
