import 'package:flutter/material.dart';
import 'package:chauffeurs_app/helpers/chauffeur_service.dart';
import 'package:chauffeurs_app/helpers/auth_service.dart';
import 'package:chauffeurs_app/screens/login_screen.dart';
import 'package:chauffeurs_app/screens/edit_profile_screen.dart';
import '../models/chauffeur_model.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Chauffeur? _chauffeurData; // Utilisation de Chauffeur et non de Map
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Charger les informations du chauffeur depuis l'API
  Future<void> _loadProfile() async {
    try {
      // Utilise l'ID du chauffeur stocké dans l'application
      final driverId = 1; // Remplace par l'ID réel du chauffeur, qui peut être récupéré via Auth ou autre logique

      final data = await ChauffeurService().fetchChauffeurInfo(driverId); // Envoie l'ID à l'API
      setState(() {
        _chauffeurData = data;
        _isLoading = false;
        _errorMessage = data == null ? 'Aucune donnée trouvée pour ce profil.' : '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors du chargement du profil : $e';
      });
      print('❌ Erreur lors du chargement du profil: $e');
    }
  }

  // Déconnexion du chauffeur
  Future<void> _logout() async {
    try {
      await AuthService().logout();  // Utilisation de AuthService pour la déconnexion
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
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueGrey,
              backgroundImage: _chauffeurData?.photo != null
                  ? NetworkImage(_chauffeurData!.photo!)
                  : null,
              child: _chauffeurData?.photo == null
                  ? Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            SizedBox(height: 20),
            Text(
              _chauffeurData?.nom ?? "Nom inconnu",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("📧 ${_chauffeurData?.email ?? 'Email non disponible'}"),
            SizedBox(height: 5),
            Text("📞 ${_chauffeurData?.phone ?? 'Numéro non disponible'}"),
            SizedBox(height: 5),
            Text("📌 Statut: ${_chauffeurData?.statut ?? 'Indisponible'}"),
            SizedBox(height: 20),

            // Bouton Modifier le profil
            ElevatedButton.icon(
              onPressed: () async {
                final updatedData = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                        chauffeurData: _chauffeurData!),
                  ),
                );
                if (updatedData != null) {
                  setState(() {
                    _chauffeurData = updatedData;
                  });
                }
              },
              icon: Icon(Icons.edit),
              label: Text("Modifier le profil"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent),
            ),
            SizedBox(height: 20),

            // Bouton Déconnexion
            ElevatedButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.exit_to_app, color: Colors.white),
              label: Text("Déconnexion"),
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
