import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chauffeurs_app/helpers/chauffeur_service.dart';
import 'package:chauffeurs_app/models/chauffeur_model.dart';

class EditProfileScreen extends StatefulWidget {
  final Chauffeur chauffeurData;
  EditProfileScreen({required this.chauffeurData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _statusController;
  File? _image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.chauffeurData.nom);
    _emailController = TextEditingController(text: widget.chauffeurData.email);
    _phoneController = TextEditingController(text: widget.chauffeurData.phone);
    _statusController = TextEditingController(text: widget.chauffeurData.status ?? '');
  }

  // Sélectionner une image
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Sauvegarder les modifications
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      Map<String, String> updatedData = {
        "name": _nameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text,
        "status": _statusController.text,
      };

      ChauffeurService chauffeurService = ChauffeurService();

      try {
        // Récupérer les données mises à jour
        Chauffeur updatedChauffeur = await chauffeurService.updateChauffeurProfile(updatedData, _image);

        // Mettre à jour les données affichées
        Navigator.pop(context, updatedChauffeur);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Échec de la mise à jour : $e")),
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
                controller: _statusController,
                decoration: InputDecoration(labelText: "Statut"),
              ),
              SizedBox(height: 20),

              // Bouton sauvegarde
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
