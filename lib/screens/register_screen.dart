import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chauffeurs_app/helpers/chauffeur_service.dart';
import 'package:chauffeurs_app/models/chauffeur_model.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _modelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/driver/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': _nameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'phone': _phoneController.text,
            'model': _modelController.text,
            'license_plate': _licensePlateController.text,
          }),
        );
        // ...existing code...
      } catch (e) {
        // ...existing code...
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inscription')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            // ...existing code...
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
            SizedBox(height: 16),
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
            SizedBox(height: 16),
            // ...existing code...
          ],
        ),
      ),
    );
  }
}