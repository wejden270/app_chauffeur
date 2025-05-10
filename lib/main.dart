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

  // Assurer la cohérence des IDs utilisateur
  await _ensureUserIdConsistency();

  FirebaseMessagingService messagingService = FirebaseMessagingService(navigatorKey: navigatorKey);
  await messagingService.initialize();
  
  // Vérifier si l'utilisateur est connecté - utiliser driverId pour cohérence
  final prefs = await SharedPreferences.getInstance();
  int? driverId = prefs.getInt('driverId');
  
  if (driverId != null) {
    if (kDebugMode) {
      print('👤 Chauffeur connecté (ID: $driverId)');
    }
    await messagingService.initializeFirebaseMessaging(driverId.toString());
  } else {
    if (kDebugMode) {
      print('👤 Aucun chauffeur connecté');
    }
  }

  // Gérer les permissions de localisation avant de lancer l'application
  await _handleLocationPermission();

  runApp(MyApp());
}

// Fonction pour assurer la cohérence entre user_id et driverId
Future<void> _ensureUserIdConsistency() async {
  final prefs = await SharedPreferences.getInstance();
  int? driverId = prefs.getInt('driverId');
  String? userId = prefs.getString('user_id');
  
  // Si un ID existe et l'autre non, assurez la cohérence
  if (driverId != null && userId == null) {
    await prefs.setString('user_id', driverId.toString());
    if (kDebugMode) {
      print('🔄 user_id ajouté pour cohérence: $driverId');
    }
  } else if (userId != null && driverId == null) {
    try {
      int id = int.parse(userId);
      await prefs.setInt('driverId', id);
      if (kDebugMode) {
        print('🔄 driverId ajouté pour cohérence: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la conversion de user_id: $e');
      }
    }
  }
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