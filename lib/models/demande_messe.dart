class DemandeMesse {
  final int id;
  final String typeMesse;
  final String typeIntention;
  final String dateMesse;
  final String heureMesse;
  final String lieuMesse;
  final String intentions;

  DemandeMesse({
    required this.id,
    required this.typeMesse,
    required this.typeIntention,
    required this.dateMesse,
    required this.heureMesse,
    required this.lieuMesse,
    required this.intentions,
  });

  factory DemandeMesse.fromJson(Map<String, dynamic> json) {
    return DemandeMesse(
      id: json['id'],
      typeMesse: json['lib_type_messe'] ?? 'Type inconnu',
      typeIntention: json['lib_type_intention'] ?? 'Intention inconnue',
      dateMesse: json['date_messe'],
      heureMesse: json['heure_messe'],
      lieuMesse: json['lieu_messe'],
      intentions: json['intentions'],
    );
  }
}
