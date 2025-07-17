class Annonce {
  final int id;
  final String titre;
  final String contenu;
  final String createdAt;

  Annonce({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.createdAt,
  });

  factory Annonce.fromJson(Map<String, dynamic> json) {
    return Annonce(
      id: json['id'],
      titre: json['titre'],
      contenu: json['contenu'],
      createdAt: json['created_at'],
    );
  }
}
