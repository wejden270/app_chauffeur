import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/demande.dart';

class DemandeService {
  Future<List<Demande>> getDemandes() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/demandes'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 Réponse brute: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> demandesJson = responseData['data'];
        
        print('📦 Données parsées: $demandesJson');
        
        return demandesJson.map((json) {
          print('🔄 Traitement demande: $json');
          return Demande.fromJson(json);
        }).toList();
      } else {
        throw Exception('Erreur de chargement des demandes');
      }
    } catch (e) {
      print('❌ Erreur getDemandes: $e');
      return [];
    }
  }

  Future<bool> updateDemandeStatus(int demandeId, String status) async {
    try {
      print('📤 Mise à jour demande $demandeId avec status: $status');
      
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/demandes/$demandeId'),
        headers: {
          ...ApiConfig.headers,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'status': status == 'accepted' ? 'acceptee' : 'refusee'
        }),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('❌ Exception dans updateDemandeStatus: $e');
      return false;
    }
  }

 Future<bool> updateDriverStatus(int driverId, String status) async {
  try {
    // Conversion du format du statut pour correspondre à l'API
    String apiStatus = status;
    if (status == "en_mission") {
      apiStatus = "en mission";
    }
    
    print('📤 Tentative de mise à jour du statut - ID: $driverId, Nouveau statut: $apiStatus');
    
    final url = Uri.parse('${ApiConfig.baseUrl}/driver/$driverId/update-status');
    print('📡 URL: $url');

    final Map<String, dynamic> requestBody = {
      'status': apiStatus,
    };
    
    print('📦 Corps de la requête: ${json.encode(requestBody)}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(requestBody),
    );

    print('📥 Code de réponse: ${response.statusCode}');
    print('📥 Corps de la réponse: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return true;
    }
    
    return false;
  } catch (e) {
    print('❌ Exception dans updateDriverStatus: $e');
    return false;
  }
}
}
