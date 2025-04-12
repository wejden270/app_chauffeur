import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chauffeurs_app/helpers/chauffeur_service.dart';
import 'package:chauffeurs_app/models/chauffeur_model.dart'; // Import ajouté pour le modèle Chauffeur

class EditProfileScreen extends StatefulWidget {
  final Chauffeur chauffeurData; // Utilisation du modèle Chauffeur au lieu de Map
  EditProfileScreen({required this.chauffeurData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _statutController;
  File? _image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.chauffeurData.nom); // Corrected 'name' to 'nom'
    _emailController = TextEditingController(text: widget.chauffeurData.email);
    _phoneController = TextEditingController(text: widget.chauffeurData.phone);
    _statutController = TextEditingController(text: widget.chauffeurData.statut ?? '');
  }

  // Fonction pour sélectionner une image de la galerie
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Fonction pour sauvegarder les informations du profil
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Création des données mises à jour
      Map<String, String> updatedData = {
        "name": _nameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text,
        "statut": _statutController.text,
      };

      ChauffeurService chauffeurService = ChauffeurService(); // Instanciation de ChauffeurService

      bool success = await chauffeurService.updateChauffeurProfile(updatedData, _image); // Correct method call
      if (success) {
        Navigator.pop(context, updatedData); // Retourner les données mises à jour
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Échec de la mise à jour")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Modifier le profil")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Avatar avec possibilité de modifier l'image
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueGrey,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null ? Icon(Icons.camera_alt, size: 40) : null,
                ),
              ),
              SizedBox(height: 20),

              // Champs de formulaire pour le nom, email, téléphone et statut
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Nom"),
                validator: (value) => value!.isEmpty ? "Entrez un nom" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) => value!.isEmpty ? "Entrez un email" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Téléphone"),
                validator: (value) => value!.isEmpty ? "Entrez un numéro" : null,
              ),
              TextFormField(
                controller: _statutController,
                decoration: InputDecoration(labelText: "Statut"),
              ),
              SizedBox(height: 20),

              // Bouton pour sauvegarder les modifications
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text("Sauvegarder"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
