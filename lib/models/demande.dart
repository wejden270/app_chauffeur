class Demande {
  final int id;
  final int clientId;
  final int chauffeurId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Client client;
  final Chauffeur chauffeur;

  Demande({
    required this.id,
    required this.clientId,
    required this.chauffeurId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.client,
    required this.chauffeur,
  });

  factory Demande.fromJson(Map<String, dynamic> json) {
    return Demande(
      id: json['id'],
      clientId: json['client_id'],
      chauffeurId: json['chauffeur_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      client: Client.fromJson(json['client']),
      chauffeur: Chauffeur.fromJson(json['chauffeur']),
    );
  }
}

class Client {
  final int id;
  final String name;
  final String phone;
  final String email;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
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
