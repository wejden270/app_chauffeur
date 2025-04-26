import 'package:flutter/material.dart';
import '../models/demande.dart';
import '../services/demande_service.dart';

class DemandeDetailsScreen extends StatelessWidget {
  final Demande demande;
  final DemandeService _demandeService = DemandeService();

  DemandeDetailsScreen({required this.demande});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détails de la demande')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lieu de prise en charge: ${demande.pickupLocation}'),
            Text('Destination: ${demande.dropLocation}'),
            Text('Prix: ${demande.price}€'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _demandeService.updateDemandeStatus(demande.id, 'accepted');
                      Navigator.pop(context, true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur lors de l\'acceptation')),
                      );
                    }
                  },
                  child: Text('Accepter'),
                  style: ElevatedButton.styleFrom(primary: Colors.green),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _demandeService.updateDemandeStatus(demande.id, 'rejected');
                      Navigator.pop(context, false);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur lors du rejet')),
                      );
                    }
                  },
                  child: Text('Rejeter'),
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
