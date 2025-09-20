// models/pain_du_jour.dart
class PainDuJour {
  final int id;
  final String titre;
  final String contenu;
  final DateTime datePain;

  PainDuJour({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.datePain,
  });

  factory PainDuJour.fromJson(Map<String, dynamic> json) {
    final pain = PainDuJour(
      id: json['id'] ?? 0,
      titre: json['titre'] ?? '',
      contenu: json['contenu'] ?? '',
      datePain: DateTime.tryParse(json['date_pain'] ?? '') ?? DateTime.now(),
    );
    print("🎯 Pain reçu depuis JSON : ${pain.titre} | ${pain.datePain}");
    return pain;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'contenu': contenu,
      'date_pain': datePain.toIso8601String(),
    };
  }
}
