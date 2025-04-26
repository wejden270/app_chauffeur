import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/api_service.dart';

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
  static Future<void> sendLocationToServer(String driverId, Position position) async {
    try {
      await ApiService.updateChauffeurLocation(
        driverId,
        position.latitude,
        position.longitude
      );
    } catch (e) {
      print('❌ Error sending location: $e');
    }
  }

  static Future<void> updateLocation(Position position) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Récupérer l'ID comme String et le convertir en int
      String? driverId = prefs.getString('driver_id');
      
      if (driverId != null) {
        await ApiService.updateChauffeurLocation(
          driverId, // Pas besoin de conversion puisque l'API attend un String
          position.latitude,
          position.longitude
        );
      } else {
        print('❌ Driver ID not found in preferences');
      }
    } catch (e) {
      print('❌ Error sending location: $e');
    }
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
