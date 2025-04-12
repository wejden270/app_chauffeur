import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../helpers/api_service.dart';
import '../helpers/location_helper.dart';
import 'profile_screen.dart';  // Assure-toi d'importer le ProfileScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getLocationUpdates();
  }

  // Met à jour la position du chauffeur et l'envoie au serveur Laravel
  void _getLocationUpdates() {
    LocationHelper.getLocationStream().listen((Position position) {
      setState(() {
        _currentPosition = position;
      });

      // Envoi de la position au serveur Laravel
      int chauffeurId = 1; // Remplace par l'ID du chauffeur connecté
      LocationHelper.sendLocationToServer(chauffeurId, position);
    });
  }

  // Récupère les missions disponibles du serveur
  Future<List<dynamic>> fetchMissions() async {
    final response = await ApiService.getMissions();
    return response;
  }

  // Accepte une mission
  void _acceptMission(int missionId) {
    print("Mission $missionId acceptée");
    // Ajouter l'appel API ici pour marquer la mission comme acceptée
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Missions disponibles"),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          // Icône de profil en haut à droite
          IconButton(
            icon: Icon(Icons.account_circle), // Icône de profil
            onPressed: () {
              // Naviguer vers l'écran de profil
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Affichage de la position actuelle
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(10),
            child: _currentPosition == null
                ? Text(
              "Récupération de la position...",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
                : Text(
              "📍 Position : ${_currentPosition!.latitude}, ${_currentPosition!.longitude}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchMissions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("❌ Une erreur est survenue"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("🚗 Aucune mission disponible"));
                }

                List missions = snapshot.data!;
                return ListView.builder(
                  itemCount: missions.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12),
                        title: Text(
                          "Mission #${missions[index]['id']}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                          "🧑‍💼 Client : ${missions[index]['client_name']}",
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            _acceptMission(missions[index]['id']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                          child: Text("Accepter"),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}