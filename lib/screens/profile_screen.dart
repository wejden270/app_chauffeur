import 'package:flutter/material.dart';
import 'package:chauffeurs_app/helpers/chauffeur_service.dart';
import 'package:chauffeurs_app/helpers/auth_service.dart';
import 'package:chauffeurs_app/screens/login_screen.dart';
import 'package:chauffeurs_app/screens/edit_profile_screen.dart';
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
      final driverId = 2; // Remplacer par SharedPreferences si besoin
      final url = Uri.parse("http://localhost:8000/api/driver/$driverId/profile");
      final response = await http.get(url);

      // 🔹 Vérification de la réponse brute avant conversion
      print("Réponse API brute : ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);

        // 🔹 Vérifie si la clé "data" existe et est bien formatée
        if (jsonBody.containsKey("data")) {
          setState(() {
            _chauffeurData = Chauffeur.fromJson(jsonBody["data"]);
            _isLoading = false;
            _errorMessage = '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mon Profil")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar par défaut sans chargement d’image
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),

            Text(
              _chauffeurData?.nom ?? "Nom inconnu",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("📧 ${_chauffeurData?.email ?? 'Email non disponible'}"),
            const SizedBox(height: 5),
            Text("📞 ${_chauffeurData?.phone ?? 'Numéro non disponible'}"),
            const SizedBox(height: 5),
            Text("📌 Status: ${_chauffeurData?.status ?? 'Indisponible'}"),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () async {
                if (_chauffeurData != null) {
                  final updatedData = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        chauffeurData: _chauffeurData!,
                      ),
                    ),
                  );
                  if (updatedData != null && updatedData is Chauffeur) {
                    setState(() {
                      _chauffeurData = updatedData;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Profil mis à jour avec succès !")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Impossible de modifier le profil. Données manquantes.")),
                  );
                }
              },
              icon: Icon(Icons.edit),
              label: Text("Modifier le profil"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.exit_to_app, color: Colors.white),
              label: Text("Déconnexion"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
