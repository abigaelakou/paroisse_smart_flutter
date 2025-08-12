class Evenement {
  final int id;
  final String lib_evenement;
  final String description;
  final String date_evement;
  final String heure_evenement;

  Evenement({
    required this.id,
    required this.lib_evenement,
    required this.description,
    required this.date_evement,
    required this.heure_evenement,
  });

  factory Evenement.fromJson(Map<String, dynamic> json) {
    return Evenement(
      id: json['id'],
      lib_evenement: json['lib_evenement'],
      description: json['description'],
      date_evement: json['date_evement'],
      heure_evenement: json['heure_evenement'],
    );
  }
}
