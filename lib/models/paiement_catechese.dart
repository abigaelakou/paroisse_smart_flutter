// class PaiementCatechese {
//   final int id;
//   final int inscriptionId;
//   final String nomCatechumene;
//   final String niveau;
//   final String session;
//   final DateTime dateInscription;
//   final int montant;
//   final String statut;

//   PaiementCatechese({
//     required this.id,
//     required this.inscriptionId,
//     required this.nomCatechumene,
//     required this.niveau,
//     required this.session,
//     required this.dateInscription,
//     required this.montant,
//     required this.statut,
//   });

//   factory PaiementCatechese.fromJson(Map<String, dynamic> json) {
//     final inscription = json['inscription'] ?? {};

//     return PaiementCatechese(
//       id: json['id'] ?? 0,
//       inscriptionId: json['id_inscription'] ?? 0,
//       nomCatechumene: inscription['catechumene']?['name'] ?? 'Inconnu',
//       niveau: inscription['niveau']?['lib_niveau'] ?? 'N/A',
//       session: inscription['session']?['lib_session_catechese'] ?? 'N/A',
//       dateInscription:
//           DateTime.tryParse(inscription['date_inscription'] ?? '') ??
//           DateTime(2000, 1, 1),
//       montant: (json['montant'] != null)
//           ? int.tryParse(json['montant'].toString()) ?? 0
//           : 0,
//       statut: json['payment_status'] ?? 'Inconnu',
//     );
//   }
// }
class PaiementCatechese {
  final int id;
  final int inscriptionId;
  final String nomCatechumene;
  final String niveau;
  final String session;
  final DateTime dateInscription;
  final double montant;
  final String statut;
  final String? recuUrl;

  PaiementCatechese({
    required this.id,
    required this.inscriptionId,
    required this.nomCatechumene,
    required this.niveau,
    required this.session,
    required this.dateInscription,
    required this.montant,
    required this.statut,
    this.recuUrl,
  });

  factory PaiementCatechese.fromJson(Map<String, dynamic> json) {
    final inscription = json['inscription'] ?? {};

    return PaiementCatechese(
      id: json['id'] ?? 0,
      inscriptionId: json['id_inscription'] ?? 0,
      nomCatechumene: inscription['catechumene']?['name'] ?? 'Inconnu',
      niveau: inscription['niveau']?['lib_niveau'] ?? 'N/A',
      session: inscription['session']?['lib_session_catechese'] ?? 'N/A',
      dateInscription:
          DateTime.tryParse(inscription['date_inscription'] ?? '') ??
          DateTime(2000, 1, 1),
      montant: double.tryParse(json['montant'].toString()) ?? 0.0,
      statut: json['payment_status'] ?? 'Inconnu',
      recuUrl: json['recu_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "id_inscription": inscriptionId,
      "nom_catechumene": nomCatechumene,
      "niveau": niveau,
      "session": session,
      "date_inscription": dateInscription.toIso8601String(),
      "montant": montant,
      "payment_status": statut,
      "recu_url": recuUrl,
    };
  }
}
