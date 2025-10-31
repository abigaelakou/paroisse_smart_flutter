import 'paiement_catechese.dart';

class InscriptionCatechese {
  final int id;
  final String anneeCatechetique;
  final String dateInscription;
  final int idCatechumene;
  final int idUser;
  final int idNiveau;
  final int idSession;
  final int paroisseId;

  // Champs optionnels pour affichage
  final String? nomCatechumene;
  final String? contactCatechumene;
  final String? emailCatechumene;
  final String? nomPrenomPere;
  final String? contactPere;
  final String? nomPrenomMere;
  final String? contactMere;
  final String? nomPrenomParrain;
  final String? contactParrain;
  final String? sacrementRecu;

  final String? niveau;
  final String? session;

  final PaiementCatechese? paiement;

  InscriptionCatechese({
    required this.id,
    required this.anneeCatechetique,
    required this.dateInscription,
    required this.idCatechumene,
    required this.idUser,
    required this.idNiveau,
    required this.idSession,
    required this.paroisseId,
    this.nomCatechumene,
    this.contactCatechumene,
    this.emailCatechumene,
    this.nomPrenomPere,
    this.contactPere,
    this.nomPrenomMere,
    this.contactMere,
    this.nomPrenomParrain,
    this.contactParrain,
    this.sacrementRecu,
    this.niveau,
    this.session,
    this.paiement,
  });

  factory InscriptionCatechese.fromJson(Map<String, dynamic> json) {
    return InscriptionCatechese(
      id: json['inscription_id'] ?? json['id'],
      anneeCatechetique: json['annee_catechetique'] ?? '',
      dateInscription: json['date_inscription'] ?? '',
      idCatechumene: json['id_catechumene'] ?? 0,
      idUser: json['id_user'] ?? 0,
      idNiveau: json['id_niveau'] ?? 0,
      idSession: json['id_session'] ?? 0,
      paroisseId: json['paroisse_id'] ?? 0,

      nomCatechumene: json['name'],
      contactCatechumene: json['contact'],
      emailCatechumene: json['email'],
      nomPrenomPere: json['nom_prenom_pere'],
      contactPere: json['contact_pere'],
      nomPrenomMere: json['nom_prenom_mere'],
      contactMere: json['contact_mere'],
      nomPrenomParrain: json['nom_prenom_parrain'],
      contactParrain: json['contact_parrain'],
      sacrementRecu: json['sacrement_recu'],

      niveau: json['niveau'] ?? json['lib_niveau'],
      session: json['session'] ?? json['lib_session_catechese'],

      paiement: json['paiement'] != null
          ? PaiementCatechese.fromJson(json['paiement'])
          : null,
    );
  }
}
