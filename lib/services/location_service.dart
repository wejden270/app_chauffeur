import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import '../helpers/api_service.dart';

class LocationService {
  static Future<void> initializeLocation(String driverId) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("Le service de localisation est désactivé.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("Permission de localisation refusée!");
        return;
      }
    }

    // Configurer les mises à jour de position
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // Mise à jour tous les 100 mètres
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) async {
      try {
        await ApiService.updateChauffeurLocation(
          driverId,
          position.latitude,
          position.longitude,
        );
        debugPrint("✅ Position mise à jour: ${position.latitude}, ${position.longitude}");
      } catch (e) {
        debugPrint("❌ Erreur mise à jour position: $e");
      }
    });
  }
}
