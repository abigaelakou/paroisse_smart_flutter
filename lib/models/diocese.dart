import 'package:paroisse_smart_flutter/models/pays.dart';

class Diocese {
  final int id;
  final String nom;
  final int paysId;
  final Pays? pays;

  Diocese({
    required this.id,
    required this.nom,
    required this.paysId,
    this.pays,
  });

  factory Diocese.fromJson(Map<String, dynamic> json) {
    return Diocese(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      paysId: json['pays_id'] as int? ?? 0,
      pays: json['pays'] != null ? Pays.fromJson(json['pays']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nom': nom, 'pays_id': paysId};
  }

  @override
  String toString() => nom;
}
