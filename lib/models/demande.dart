class Demande {
  final int id;
  final Client client;
  final Chauffeur chauffeur;
  final String status;
  final DateTime createdAt;
  final double? client_latitude;    // Ajouté au niveau de la demande
  final double? client_longitude;   // Ajouté au niveau de la demande

  Demande({
    required this.id,
    required this.client,
    required this.chauffeur,
    required this.status,
    required this.createdAt,
    this.client_latitude,
    this.client_longitude,
  });

  factory Demande.fromJson(Map<String, dynamic> json) {
    print('📦 Données demande: $json');
    return Demande(
      id: json['id'],
      client: Client.fromJson(json['client'] ?? {}),
      chauffeur: Chauffeur.fromJson(json['chauffeur'] ?? {}),
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? ''),
      client_latitude: double.tryParse(json['client_latitude']?.toString() ?? '0'),
      client_longitude: double.tryParse(json['client_longitude']?.toString() ?? '0'),
    );
  }
}

class Client {
  final int id;
  final String name;
  final String phone;
  final String email;
  final double? latitude;
  final double? longitude;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.latitude,
    this.longitude,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    print('👤 Données client: $json');
    return Client(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      latitude: double.tryParse(json['client_latitude']?.toString() ?? '0.0'),
      longitude: double.tryParse(json['client_longitude']?.toString() ?? '0.0'),
    );
  }
}

class Chauffeur {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String model;
  final String licensePlate;
  final String status;
  final String? latitude;
  final String? longitude;

  Chauffeur({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.model,
    required this.licensePlate,
    required this.status,
    this.latitude,
    this.longitude,
  });

  factory Chauffeur.fromJson(Map<String, dynamic> json) {
    return Chauffeur(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      model: json['model'],
      licensePlate: json['license_plate'],
      status: json['status'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
