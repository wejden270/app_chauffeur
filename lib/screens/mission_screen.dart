import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../helpers/location_helper.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Correction de l'import
import '../models/demande.dart';
import '../services/demande_service.dart';

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
  final DemandeService _demandeService = DemandeService();
  List<Demande> _demandes = [];
  bool _isLoadingDemandes = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadDemandes();
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

  Future<void> _loadDemandes() async {
    setState(() => _isLoadingDemandes = true);
    try {
      final demandes = await _demandeService.getDemandes();
      setState(() {
        _demandes = demandes;
        _isLoadingDemandes = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des demandes: $e');
      setState(() => _isLoadingDemandes = false);
    }
  }

  void _handleDemande(Demande demande, bool accept) async {
    try {
      await _demandeService.updateDemandeStatus(
        demande.id, 
        accept ? 'accepted' : 'rejected'
      );
      _loadDemandes(); // Recharger les demandes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept ? 'Demande acceptée' : 'Demande rejetée'),
          backgroundColor: accept ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du traitement de la demande')),
      );
    }
  }

  Widget _buildDemandesList() {
    if (_isLoadingDemandes) {
      return Center(child: CircularProgressIndicator());
    }

    if (_demandes.isEmpty) {
      return Center(child: Text('Aucune demande disponible'));
    }

    return ListView.builder(
      itemCount: _demandes.length,
      itemBuilder: (context, index) {
        final demande = _demandes[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('Destination: ${demande.dropLocation}'),
            subtitle: Text('Prix: ${demande.price}€'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () => _handleDemande(demande, true),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () => _handleDemande(demande, false),
                ),
              ],
            ),
          ),
        );
      },
    );
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
      appBar: AppBar(
        title: const Text("Mission en cours"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDemandes,
          ),
        ],
      ),
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
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: _buildDemandesList(),
              );
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
