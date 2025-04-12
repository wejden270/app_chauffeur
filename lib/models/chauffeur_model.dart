class Chauffeur {
  final int id;
  final String nom;
  final String phone;
  final String email;
  final String statut;
  final String? photo;  // Ajout de la propriété photo

  Chauffeur({
    required this.id,
    required this.nom,
    required this.phone,
    required this.email,
    required this.statut,
    this.photo,  // Le champ photo est optionnel
  });

  // Convertir un JSON en objet Chauffeur
  factory Chauffeur.fromJson(Map<String, dynamic> json) {
    return Chauffeur(
      id: json['id'],
      nom: json['nom'],
      phone: json['phone'],
      email: json['email'],
      statut: json['statut'],
      photo: json['photo'],  // Assurez-vous que la clé 'photo' existe dans le JSON
    );
  }
}
