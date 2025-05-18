import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../helpers/api_service.dart';
import '../helpers/location_helper.dart';
import 'profile_screen.dart';
import 'package:chauffeurs_app/services/firebase_messaging_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/demande.dart';
import '../services/demande_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  final FirebaseMessagingService _messagingService = FirebaseMessagingService(
    navigatorKey: GlobalKey<NavigatorState>(),
  );
  final DemandeService _demandeService = DemandeService();
  List<Demande> _demandes = [];
  bool _isLoadingDemandes = false;

  @override
  void initState() {
    super.initState();
    _getLocationUpdates();
    _loadDemandes();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  void _getLocationUpdates() {
    _positionStreamSubscription = LocationHelper.getLocationStream().listen(
      (Position position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
          _sendLocationToServer();
        }
      },
    );
  }

  Future<void> _sendLocationToServer() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? driverId = prefs.getString('driver_id');
      
      if (driverId != null && _currentPosition != null) {
        await LocationHelper.sendLocationToServer(
          driverId,
          _currentPosition!,
        );
      }
    } catch (e) {
      print('❌ Error sending location: $e');
    }
  }

  Future<void> _loadDemandes() async {
    setState(() => _isLoadingDemandes = true);
    try {
      print('🔄 Chargement des demandes...');
      final demandes = await _demandeService.getDemandes();
      print('📦 Demandes reçues: ${demandes.length}');
      
      if (mounted) {
        setState(() {
          _demandes = demandes;
          _isLoadingDemandes = false;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des demandes: $e');
      if (mounted) {
        setState(() {
          _isLoadingDemandes = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du chargement des demandes'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    }
  }

  Future<void> _handleDemande(Demande demande, bool accept) async {
    try {
      final success = await _demandeService.updateDemandeStatus(
        demande.id,
        accept ? 'accepted' : 'rejected'
      );

      if (success) {
        await _loadDemandes(); // Recharger les demandes
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(accept ? 'Demande acceptée' : 'Demande rejetée'),
              backgroundColor: accept ? Colors.green : Colors.red,
            ),
          );
          
          // Ouvrir Google Maps si la demande est acceptée
          if (accept && demande.client_latitude != null && demande.client_longitude != null) {
            openMap(demande.client_latitude!, demande.client_longitude!);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la mise à jour du statut'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Erreur lors du traitement de la demande: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du traitement de la demande'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> openMap(double latitude, double longitude) async {
    final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
    } else {
      throw 'Impossible d\'ouvrir Google Maps.';
    }
  }

  void _openChat(int clientId) {
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: clientId,
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Client: ${course['client_name'] ?? 'Non spécifié'}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.chat_bubble_outline),
                  onPressed: () => _openChat(course['client_id']),
                  tooltip: 'Discuter avec le client',
                ),
              ],
            ),
            // ...existing course card content...
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Demandes de course"),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(10),
            child: _currentPosition == null
                ? Text(
                    "Récupération de la position...",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )
                : Text(
                    "📍 Position : ${_currentPosition!.latitude}, ${_currentPosition!.longitude}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
          Expanded(
            child: _isLoadingDemandes
                ? Center(child: CircularProgressIndicator())
                : _demandes.isEmpty
                    ? Center(child: Text('Aucune demande disponible'))
                    : RefreshIndicator(
                        onRefresh: _loadDemandes,
                        child: ListView.builder(
                          itemCount: _demandes.length,
                          itemBuilder: (context, index) {
                            final demande = _demandes[index];
                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(12),
                                title: Text(
                                  "Client: ${demande.client.name}",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Téléphone: ${demande.client.phone}"),
                                    Text("Status: ${demande.status}"),
                                    Text("Date: ${demande.createdAt.toString().split('.')[0]}"),
                                    Text('Position client: '
                                        '${demande.client_latitude?.toStringAsFixed(6) ?? "N/A"}, '
                                        '${demande.client_longitude?.toStringAsFixed(6) ?? "N/A"}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.check_circle, color: Colors.green),
                                      onPressed: () => _handleDemande(demande, true),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.cancel, color: Colors.red),
                                      onPressed: () => _handleDemande(demande, false),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.map, color: Colors.blue),
                                      onPressed: () {
                                        if (demande.client_latitude != null && demande.client_longitude != null) {
                                          openMap(demande.client_latitude!, demande.client_longitude!);
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.chat_bubble_outline),
                                      onPressed: () => _openChat(demande.client.id),
                                      tooltip: 'Discuter avec le client',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadDemandes,
        child: Icon(Icons.refresh),
        tooltip: 'Actualiser les demandes',
      ),
    );
  }
}
