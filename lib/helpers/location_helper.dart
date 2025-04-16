import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart';

class LocationHelper {
  // Récupère un flux de la position actuelle de l'utilisateur
  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Met à jour la position tous les 10 mètres
      ),
    );
  }

  // Envoie la position actuelle du chauffeur vers le serveur
  static Future<void> sendLocationToServer(int chauffeurId, Position position) async {
    // Convertir chauffeurId en String
    //await ApiService.updateChauffeurLocationSimple(chauffeurId.toString(), position.latitude, position.longitude);
    await ApiService.updateChauffeurLocationSimple(chauffeurId.toDouble(), position.latitude, position.longitude);
  }

  // Récupère la position actuelle de l'utilisateur
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Le service de localisation n'est pas activé
      return null;
    }

    // Vérifier et demander la permission de localisation
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission refusée
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission refusée définitivement
      return null;
    }

    // Obtenir la position actuelle
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
