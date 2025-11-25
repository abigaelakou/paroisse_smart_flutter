class User {
  final int id;
  final String name;
  final String email;
  final String? contact;
  final int paroisseId;
  final String? paroisseNom;
  final String? dioceseNom;
  final String? paysNom;
  final String sexe;
  final String situationMatrimoniale;
  final String dateNaissance;
  final String lieuHabitation;
  final List<String> sacrements;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.contact,
    required this.paroisseId,
    this.paroisseNom,
    this.dioceseNom,
    this.paysNom,
    this.sexe = '',
    this.situationMatrimoniale = '',
    this.dateNaissance = '',
    this.lieuHabitation = '',
    this.sacrements = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Récupération des sacrements
    List<String> sacrementsList = [];
    if (json['paroissien'] != null) {
      final paroissien = json['paroissien'];
      if (paroissien['sacrement_recu'] != null) {
        final sacrementsStr = paroissien['sacrement_recu'] as String;
        if (sacrementsStr.isNotEmpty) {
          sacrementsList = sacrementsStr
              .split(',')
              .map((s) => s.trim())
              .toList();
        }
      }
    }

    // Extraction des informations de paroisse, diocèse et pays
    String? paroisseNom;
    String? dioceseNom;
    String? paysNom;

    if (json['paroisse'] != null) {
      paroisseNom = json['paroisse']['nom_paroisse'] as String?;

      // Diocèse
      if (json['paroisse']['diocese'] != null) {
        dioceseNom = json['paroisse']['diocese']['nom'] as String?;

        // Pays
        if (json['paroisse']['diocese']['pays'] != null) {
          paysNom = json['paroisse']['diocese']['pays']['nom'] as String?;
        }
      }
    }

    return User(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      contact: json['contact'] as String?,
      paroisseId: json['paroisse_id'] as int? ?? 0,
      paroisseNom: paroisseNom,
      dioceseNom: dioceseNom,
      paysNom: paysNom,
      sexe: json['paroissien']?['sexe'] as String? ?? '',
      situationMatrimoniale:
          json['paroissien']?['situation_matrimoniale'] as String? ?? '',
      dateNaissance: json['paroissien']?['date_naiss'] as String? ?? '',
      lieuHabitation: json['lieu_habitation'] ?? '',
      sacrements: sacrementsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'contact': contact,
      'paroisse_id': paroisseId,
      'paroisse_nom': paroisseNom,
      'diocese_nom': dioceseNom,
      'pays_nom': paysNom,
      'sexe': sexe,
      'situation_matrimoniale': situationMatrimoniale,
      'date_naiss': dateNaissance,
      'sacrement_recu': sacrements.join(','),
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, paroisse: $paroisseNom, diocese: $dioceseNom, pays: $paysNom)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
