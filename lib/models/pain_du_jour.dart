class PainDuJour {
  final int id;
  final String titre;
  final String contenu;
  final String date_pain;

  PainDuJour({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.date_pain,
  });

factory PainDuJour.fromJson(Map<String, dynamic> json) {
  final pain = PainDuJour(
    id: json['id'] ?? 0,
    titre: json['titre'] ?? '',
    contenu: json['contenu'] ?? '',
    date_pain: json['date_pain'] ?? '',
  );
  print("🎯 Pain reçu depuis JSON : ${pain.titre} | ${pain.contenu} | ${pain.date_pain}");
  return pain;
}


}
