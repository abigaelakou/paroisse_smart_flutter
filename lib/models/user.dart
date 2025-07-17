class User {
  final int id;
  final String name;
  final String email;
  final String? contact;
  final int paroisseId;
  final String? paroisseNom;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.paroisseId,
    this.contact,
    this.paroisseNom,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      contact: json['contact'] ?? '',
      paroisseId: json['paroisse_id'],
      paroisseNom: json['paroisse'] != null ? json['paroisse']['nom_paroisse'] ?? '' : 'Non défini',
    );
  }
}
