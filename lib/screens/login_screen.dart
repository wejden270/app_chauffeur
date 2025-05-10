import 'package:flutter/material.dart';
import 'package:chauffeurs_app/screens/signup_screen.dart';
import 'package:chauffeurs_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chauffeurs_app/services/firebase_messaging_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Précharger le token FCM pour qu'il soit prêt lors de la connexion
    _preloadFCMToken();
  }

  // Préchargement du token FCM
  Future<void> _preloadFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (kDebugMode) {
        print('🔍 Token FCM préchargé: $token');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors du préchargement du token FCM: $e');
      }
    }
  }

  // Méthode de connexion
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (kDebugMode) {
        print('Login response data: $response'); // Pour le débogage
      }
      
      // Ne pas considérer "Connexion réussie" comme une erreur
      if (response != null) {
        // Récupérer driverId du response
        int? driverId;
        
        if (response.containsKey('user') && response['user'] != null) {
          driverId = response['user']['id'];
        } else if (response.containsKey('driver') && response['driver'] != null) {
          driverId = response['driver']['id'];
        } else if (response.containsKey('id')) {
          driverId = response['id'];
        }
        
        if (driverId != null) {
          // Sauvegarder driverId
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('driverId', driverId);
          await prefs.setString('user_id', driverId.toString());
          
          if (kDebugMode) {
            print('✅ driverId sauvegardé: $driverId');
          }
          
          // Initialiser FCM avec le driverId
          _initializeFirebaseMessaging(driverId.toString());
        }
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString()
            .replaceAll('Exception: ', '')
            .replaceAll('Erreur de connexion: ', '');
      });
      if (kDebugMode) {
        print('❌ Login error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Initialiser Firebase Messaging après connexion réussie
  Future<void> _initializeFirebaseMessaging(String driverId) async {
    try {
      final messagingService = FirebaseMessagingService(
        navigatorKey: GlobalKey<NavigatorState>(),
      );
      await messagingService.initializeFirebaseMessaging(driverId);
      
      if (kDebugMode) {
        print('✅ Firebase Messaging initialisé pour driverId: $driverId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de l\'initialisation FCM: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50, // Fond doux
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de l'application
              Image.asset(
                'assets/images/logo.png',  // Updated path to match assets directory
                height: 100,
              ),
              SizedBox(height: 10),

              Text(
                "Connexion",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
              ),

              SizedBox(height: 20),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: Colors.blue.shade700),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(height: 12),

                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),

                      SizedBox(height: 20),

                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Se connecter'),
                      ),

                      SizedBox(height: 10),

                      if (_errorMessage.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error, color: Colors.red),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 15),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                child: Text(
                  'Pas encore inscrit ? Inscrivez-vous ici',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}