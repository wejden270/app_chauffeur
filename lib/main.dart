import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:chauffeurs_app/screens/hello_screen.dart';
import 'package:chauffeurs_app/screens/home_screen.dart';
import 'package:chauffeurs_app/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chauffeurs_app/services/notification_service.dart';
import 'package:chauffeurs_app/services/firebase_messaging_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  if (kDebugMode) {
    print('🚀 Initialisation de Firebase...');
  }

  FirebaseMessagingService messagingService = FirebaseMessagingService(navigatorKey: navigatorKey);
  await messagingService.initialize();
  
  // Vérifier si l'utilisateur est connecté
  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_id');
  if (userId != null) {
    if (kDebugMode) {
      print('👤 Utilisateur connecté (ID: $userId)');
    }
    await messagingService.initializeFirebaseMessaging(userId);
  }

  // Gérer les permissions de localisation avant de lancer l'application
  await _handleLocationPermission();

  runApp(MyApp());
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final notificationService = NotificationService();
  await notificationService.initialize();
  notificationService.showNotification(message);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,  // Add navigator key here
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
