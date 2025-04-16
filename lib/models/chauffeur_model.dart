class Chauffeur {
  final int id;
  final String nom;
  final String phone;
  final String email;
  final String status;
  final String? photo;

  Chauffeur({
    required this.id,
    required this.nom,
    required this.phone,
    required this.email,
    required this.status,
    this.photo,
  });

  factory Chauffeur.fromJson(Map<String, dynamic> json) {
    return Chauffeur(
      id: json['id'] ?? 0,
      nom: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? '',
      photo: json['photo'], // Ce champ peut rester null
    );
  }
}
