class Paroissien {
  final String? sexe;
  final String? situationMatrimoniale;
  final String? dateNaiss;
  final String? lieuHabitation;
  final List<String> sacrements;

  Paroissien({
    this.sexe,
    this.situationMatrimoniale,
    this.dateNaiss,
    this.lieuHabitation,
    this.sacrements = const [],
  });

  factory Paroissien.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Paroissien();
    final rawSacrements = json['sacrement_recu'];
    final sacrementsList = (rawSacrements is String && rawSacrements.isNotEmpty)
        ? rawSacrements.split(',').map((e) => e.trim()).toList()
        : (rawSacrements is List
              ? List<String>.from(rawSacrements)
              : <String>[]);

    return Paroissien(
      sexe: json['sexe'],
      situationMatrimoniale: json['situation_matrimoniale'],
      dateNaiss: json['date_naiss'],
      lieuHabitation: json['lieu_habitation'],
      sacrements: sacrementsList,
    );
  }
}
