import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import '../helpers/api_service.dart';

class LocationTrackingService {
  Timer? _timer;
  static const int _updateInterval = 30; // secondes

  Future<void> startTracking(String driverId) async {
    if (kDebugMode) {
      print('🛰️ Démarrage du suivi de position...');
    }

    // Vérifier et demander les permissions
    bool hasPermission = await _checkAndRequestPermission();
    if (!hasPermission) return;

    // Démarrer la mise à jour périodique
    _timer = Timer.periodic(
      const Duration(seconds: _updateInterval),
      (_) => _updateLocation(driverId),
    );

    // Première mise à jour immédiate
    await _updateLocation(driverId);
  }

  Future<bool> _checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) {
        print('❌ Services de localisation désactivés');
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (kDebugMode) {
          print('❌ Permission de localisation refusée');
        }
        return false;
      }
    }

    return true;
  }

  Future<void> _updateLocation(String driverId) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await ApiService.updateChauffeurLocation(
        driverId,
        position.latitude,
        position.longitude,
      );

      if (kDebugMode) {
        print('📍 Position mise à jour : ${position.latitude}, ${position.longitude}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur de mise à jour position: $e');
      }
    }
  }

  void stopTracking() {
    _timer?.cancel();
    _timer = null;
    if (kDebugMode) {
      print('🛑 Arrêt du suivi de position');
    }
  }
}
