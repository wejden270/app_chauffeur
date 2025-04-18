import 'package:flutter/material.dart';
import 'package:chauffeurs_app/helpers/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _modelController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/driver/signup'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'name': _nameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'phone': _phoneController.text,
            'model': _modelController.text,
            'license_plate': _licensePlateController.text.toUpperCase(), // Conversion en majuscules
          }),
        );

        print('Données envoyées: ${jsonEncode({
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'phone': _phoneController.text,
          'model': _modelController.text,
          'license_plate': _licensePlateController.text,
        })}'); // Debug log

        if (response.statusCode == 201 || response.statusCode == 200) {
          Navigator.pop(context); // Retour à l'écran précédent après l'inscription réussie
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Inscription réussie ! Connectez-vous maintenant.')),
          );
        } else {
          print('Erreur response: ${response.body}'); // Debug log
          setState(() {
            _errorMessage = 'Une erreur est survenue lors de l\'inscription';
          });
        }
      } catch (e) {
        print('Exception: $e'); // Debug log
        setState(() {
          _errorMessage = 'Erreur : $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscription Chauffeur")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Veuillez entrer un nom' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value != null && value.contains('@')) ? null : 'Entrez un email valide',
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Veuillez entrer un numéro de téléphone' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) => value!.length >= 6 ? null : '6 caractères min.',
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _passwordConfirmationController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Confirmer mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.length >= 6 ? null : '6 caractères min.',
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(
                  labelText: 'Modèle du véhicule',
                  prefixIcon: Icon(Icons.directions_car),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le modèle de votre véhicule';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _licensePlateController,
                decoration: InputDecoration(
                  labelText: 'Plaque d\'immatriculation',
                  prefixIcon: Icon(Icons.confirmation_number),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre plaque d\'immatriculation';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('S\'inscrire', style: TextStyle(fontSize: 16)),
                ),
              ),

              SizedBox(height: 10),
              if (_errorMessage.isNotEmpty)
                Center(
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),

              SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context), // Retourner à l'écran de connexion
                  child: Text(
                    'Déjà un compte ? Connectez-vous',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}