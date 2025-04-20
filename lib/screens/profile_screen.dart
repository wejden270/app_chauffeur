import 'package:flutter/material.dart';
import 'package:chauffeurs_app/helpers/chauffeur_service.dart';
import 'package:chauffeurs_app/helpers/auth_service.dart';
import 'package:chauffeurs_app/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/chauffeur_model.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Chauffeur? _chauffeurData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final driverId = await AuthService().getDriverId() ?? 1;
      final url = Uri.parse("http://192.168.1.110:8000/api/driver/$driverId/profile");
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
