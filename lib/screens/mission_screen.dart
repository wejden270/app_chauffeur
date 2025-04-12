import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../helpers/location_helper.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Correction de l'import

class MissionScreen extends StatefulWidget {
  final LatLng clientLocation;

  const MissionScreen({Key? key, required this.clientLocation}) : super(key: key); // ✅ Ajout du key

  @override
  _MissionScreenState createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  late GoogleMapController mapController;
  LatLng? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Récupère la position actuelle du chauffeur
  void _getCurrentLocation() async {
    Position? position = await LocationHelper.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    }
  }

  // Centre la carte sur la position actuelle
  void _centerMap() {
    if (_currentPosition != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLng(_currentPosition!),
      );
    }
  }

  // Démarre la navigation vers le client via Google Maps
  void _startNavigation() async {
    final Uri googleMapsUri = Uri.parse(
        "google.navigation:q=${widget.clientLocation.latitude},${widget.clientLocation.longitude}&mode=d");

    if (await canLaunchUrl(googleMapsUri)) { // ✅ Utilisation correcte de canLaunchUrl
      await launchUrl(googleMapsUri); // ✅ Utilisation correcte de launchUrl
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir Google Maps.")),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mission en cours")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? widget.clientLocation,
              zoom: 14.0,
            ),
            markers: {
              if (_currentPosition != null)
                Marker(
                  markerId: const MarkerId('chauffeur'),
                  position: _currentPosition!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                ),
              Marker(
                markerId: const MarkerId('client'),
                position: widget.clientLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
            },
          ),

          // Boutons flottants pour navigation et recentrage
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: _centerMap,
              child: const Icon(Icons.my_location),
              backgroundColor: Colors.blue,
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _startNavigation,
              child: const Icon(Icons.navigation),
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
