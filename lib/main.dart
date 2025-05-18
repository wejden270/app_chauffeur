import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:chauffeurs_app/screens/hello_screen.dart';
import 'package:chauffeurs_app/screens/home_screen.dart';
import 'package:chauffeurs_app/screens/login_screen.dart';
import 'package:chauffeurs_app/screens/chat_screen.dart';  // Ajouter cet import
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chauffeurs_app/services/notification_service.dart';
import 'package:chauffeurs_app/services/firebase_messaging_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:chauffeurs_app/helpers/api_service.dart';

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    
    if (kDebugMode) {
      print('🚀 Démarrage de l\'application...');
    }
    
    runApp(MyApp(navigatorKey: navigatorKey));
  } catch (e) {
    if (kDebugMode) {
      print('❌ Erreur au démarrage: $e');
    }
    runApp(ErrorApp(error: e.toString()));
  }
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

class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Erreur de démarrage: $error'),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  // Ceci masquera le banner DEBUG
      navigatorKey: navigatorKey,
      title: 'Chauffeurs App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/', // Définition de la route initiale
      routes: {
        '/': (context) => HelloScreen(), // Écran d'accueil
        '/login': (context) => LoginScreen(), // Écran de connexion
        '/home': (context) => HomeScreen(), // Écran après connexion
        '/chat': (context) => ChatScreen(), // Nouvelle route pour la messagerie
      },
    );
  }
}