import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:chauffeurs_app/screens/hello_screen.dart';
import 'package:chauffeurs_app/screens/home_screen.dart';
import 'package:chauffeurs_app/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _handleLocationPermission(); // Demande l'autorisation de localisation
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chauffeurs App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/', // Définition de la route initiale
      routes: {
        '/': (context) => HelloScreen(), // Écran d'accueil
        '/login': (context) => LoginScreen(), // Écran de connexion
        '/home': (context) => HomeScreen(), // Écran après connexion
      },
    );
  }
}

/// Fonction pour gérer les autorisations de localisation
Future<void> _handleLocationPermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Vérifie si le GPS est activé
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    debugPrint("Le service de localisation est désactivé. Activez-le !");
    return;
  }

  // Vérifie l'état actuel de l'autorisation
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      debugPrint("Permission de localisation refusée !");
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    debugPrint("Permission de localisation refusée en permanence !");
    return;
  }

  // Récupère la position actuelle après l'autorisation
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  debugPrint("Position actuelle : ${position.latitude}, ${position.longitude}");
}
