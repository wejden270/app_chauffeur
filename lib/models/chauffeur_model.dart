class Chauffeur {
  final int id;
  final String nom;
  final String phone;
  final String email;
  final String status;
  final String? photo;
  final String? model;
  final String? license_plate;
  final String? fcmToken;

  Chauffeur({
    required this.id,
    required this.nom,
    required this.phone,
    required this.email,
    required this.status,
    this.photo,
    this.model,
    this.license_plate,
    this.fcmToken,
  });

  factory Chauffeur.fromJson(Map<String, dynamic> json) {
    return Chauffeur(
      id: json['id'] ?? 0,
      nom: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? '',
      photo: json['photo'], // Ce champ peut rester null
      model: json['model'],
      license_plate: json['license_plate'],
      fcmToken: json['fcm_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nom,
      'phone': phone,
      'email': email,
      'status': status,
      'photo': photo,
      'model': model,
      'license_plate': license_plate,
      'fcm_token': fcmToken,
    };
  }
}
