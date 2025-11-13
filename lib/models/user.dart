class User {
  final int id;
  final String name;
  final String email;
  final String? contact;
  final String? paroisseNom;
  final int paroisseId; // NON-NULLABLE
  final String sexe;
  final String situationMatrimoniale;
  final String dateNaissance;
  final List<String> sacrements;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.paroisseId, // REQUIRED
    this.contact,
    this.paroisseNom,
    this.sexe = '',
    this.situationMatrimoniale = '',
    this.dateNaissance = '',
    this.sacrements = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final paroissien = json['paroissien'] as Map<String, dynamic>?;
    final paroisse = json['paroisse'] as Map<String, dynamic>?;

    // Extraction des sacrements
    final rawSacrements = paroissien?['sacrement_recu'];
    final sacrementsList = (rawSacrements is String && rawSacrements.isNotEmpty)
        ? rawSacrements.split(',').map((e) => e.trim()).toList()
        : (rawSacrements is List
              ? List<String>.from(rawSacrements)
              : <String>[]);

    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      contact: json['contact'],
      paroisseNom: paroisse?['nom_paroisse'],
      paroisseId: json['paroisse_id'] ?? 0, // Valeur par défaut si null
      sexe: paroissien?['sexe'] ?? '',
      situationMatrimoniale: paroissien?['situation_matrimoniale'] ?? '',
      dateNaissance: paroissien?['date_naiss'] ?? '',
      sacrements: sacrementsList,
    );
  }
}
