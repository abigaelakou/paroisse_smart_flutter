// models/evenement.dart
class Evenement {
  final int id;
  final String libelle;
  final String description;
  final DateTime dateEvenement;
  final String heureEvenement;

  Evenement({
    required this.id,
    required this.libelle,
    required this.description,
    required this.dateEvenement,
    required this.heureEvenement,
  });

  factory Evenement.fromJson(Map<String, dynamic> json) {
    return Evenement(
      id: json['id'] ?? 0,
      libelle: json['lib_evenement'] ?? '',
      description: json['description'] ?? '',
      dateEvenement:
          DateTime.tryParse(json['date_evement'] ?? '') ?? DateTime.now(),
      heureEvenement: json['heure_evenement'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lib_evenement': libelle,
      'description': description,
      'date_evement': dateEvenement.toIso8601String(),
      'heure_evenement': heureEvenement,
    };
  }
}
