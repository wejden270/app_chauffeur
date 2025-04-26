import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/demande.dart';

class DemandeService {
  Future<List<Demande>> getDemandes() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/demandes'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['status'] == 'success' && jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => Demande.fromJson(json)).toList();
        }
        
        print('Structure de réponse inattendue: $jsonResponse');
        return [];
      } else {
        print('Erreur API: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception dans getDemandes: $e');
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
          'status': status == 'accepted' ? 'acceptee' : 'rejetee'
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
}
