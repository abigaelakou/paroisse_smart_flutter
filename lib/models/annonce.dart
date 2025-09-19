// models/annonce.dart
class Annonce {
  final int id;
  final String titre;
  final String contenu;
  final DateTime createdAt;

  Annonce({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.createdAt,
  });

  factory Annonce.fromJson(Map<String, dynamic> json) {
    return Annonce(
      id: json['id'] ?? 0,
      titre: json['titre'] ?? '',
      contenu: json['contenu'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'contenu': contenu,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
