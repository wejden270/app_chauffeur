import 'package:flutter/material.dart';
import 'package:chauffeurs_app/screens/signup_screen.dart';
import 'package:chauffeurs_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chauffeurs_app/services/firebase_messaging_service.dart';
import '../services/location_tracking_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService().login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('driverId', response['user']['id']);
      await prefs.setString('user_id', response['user']['id'].toString());
      
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          child: Form(
            key: _formKey,
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

                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isLoading 
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Se connecter'),
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
      ),
    );
  }
}