import 'package:flutter/material.dart';
import 'package:chauffeurs_app/helpers/chauffeur_service.dart';
import 'package:chauffeurs_app/helpers/auth_service.dart';
import 'package:chauffeurs_app/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/chauffeur_model.dart';
import '../services/demande_service.dart';  // Ajouter cet import
import '../config/api_config.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Chauffeur? _chauffeurData;
  bool _isLoading = true;
  String _errorMessage = '';

  final DemandeService _demandeService = DemandeService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final driverId = await AuthService().getDriverId() ?? 1;
      final url = Uri.parse("${ApiConfig.baseUrl}/driver/$driverId/profile");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        if (jsonBody.containsKey("data")) {
          setState(() {
            _chauffeurData = Chauffeur.fromJson(jsonBody["data"]);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = "Données du chauffeur introuvables.";
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Erreur : Code ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Erreur lors du chargement du profil : $e";
      });
      print("❌ Erreur lors du chargement du profil: $e");
    }
  }

  Future<void> _logout() async {
    try {
      await AuthService().logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print('❌ Erreur lors de la déconnexion : $e');
    }
  }

  Future<void> _toggleStatus() async {
    if (_chauffeurData == null) return;

    try {
      setState(() => _isLoading = true);
      
      final driverId = await AuthService().getDriverId() ?? 1;
      final newStatus = _chauffeurData?.status == 'disponible' ? 'en_mission' : 'disponible';
      
      print('🔄 Tentative de changement de statut pour le chauffeur $driverId');
      print('📝 Nouveau statut demandé: $newStatus');
      
      final success = await _demandeService.updateDriverStatus(driverId, newStatus);
      
      if (success) {
        print('✅ Statut mis à jour avec succès');
        await _loadProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Statut mis à jour avec succès'), backgroundColor: Colors.green)
        );
      } else {
        print('❌ Échec de la mise à jour du statut');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour du statut'), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      print('❌ Exception lors du changement de statut: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red)
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label : ${value ?? 'Non disponible'}",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle() {
    final isAvailable = _chauffeurData?.status == 'disponible';
    
    return ElevatedButton.icon(
      onPressed: _toggleStatus,
      icon: Icon(isAvailable ? Icons.directions_car : Icons.pause),
      label: Text(isAvailable ? 'Passer En Mission' : 'Passer Disponible'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isAvailable ? Colors.green : Colors.orange,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blueGrey,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _chauffeurData?.nom ?? "Nom inconnu",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 30, thickness: 1.5),
                      _buildStatusToggle(), // Ajouter le bouton de changement de statut
                      const Divider(height: 30, thickness: 1.5),

                      _buildInfoRow(Icons.email, "Email", _chauffeurData?.email),
                      _buildInfoRow(Icons.phone, "Téléphone", _chauffeurData?.phone),
                      _buildInfoRow(Icons.directions_car, "Modèle", _chauffeurData?.model),
                      _buildInfoRow(Icons.confirmation_number, "Plaque", _chauffeurData?.license_plate),
                      _buildInfoRow(Icons.assignment_turned_in, "Statut", _chauffeurData?.status),

                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text("Déconnexion"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
