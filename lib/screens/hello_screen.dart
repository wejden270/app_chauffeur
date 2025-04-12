import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';  // Import nécessaire pour les permissions
import 'package:geolocator/geolocator.dart';  // Import pour obtenir la localisation
import 'package:chauffeurs_app/screens/login_screen.dart';  // Assure-toi d'importer le LoginScreen

class HelloScreen extends StatefulWidget {
  @override
  _HelloScreenState createState() => _HelloScreenState();
}

class _HelloScreenState extends State<HelloScreen> {
  @override
  void initState() {
    super.initState();
    _requestLocationPermission(); // Demander la permission dès le début
  }

  // Demander la permission de localisation
  Future<void> _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      print("Permission de localisation accordée");
      _getCurrentLocation(); // Appeler la fonction pour obtenir la localisation
    } else {
      print("Permission de localisation refusée");
      // Affiche un message si la permission est refusée ou non accordée
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text('Permission refusée'),
              content: Text(
                  'L\'application a besoin de la permission de localisation pour fonctionner.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  // Récupérer la position actuelle du chauffeur
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print("Position actuelle : Latitude: ${position
          .latitude}, Longitude: ${position.longitude}");
      // Après avoir récupéré la position, tu peux naviguer vers l'écran de connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      print("Erreur lors de la récupération de la localisation: $e");
      // Si l'obtention de la position échoue, tu peux afficher un message à l'utilisateur
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text('Erreur de localisation'),
              content: Text(
                  'Impossible de récupérer la localisation. Veuillez réessayer.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            // L'image de fond
            fit: BoxFit.cover, // Permet à l'image de couvrir toute la page
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Bienvenue, Chauffeur !",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(double.infinity, 50),
                    elevation: 5,
                  ),
                  child: Text(
                    'Se connecter',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}