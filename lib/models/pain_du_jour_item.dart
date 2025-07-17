// models/pain_du_jour_item.dart
class PainDuJourItem {
  final String date;
  final String contenu;
  final String titre;

  PainDuJourItem({required this.date, required this.contenu, required this.titre});

  factory PainDuJourItem.fromJson(Map<String, dynamic> json) {
    return PainDuJourItem(
      date: json['date'] ?? '',
      contenu: json['contenu'] ?? '',
      titre: json['titre'] ?? '',
    );
  }
}
