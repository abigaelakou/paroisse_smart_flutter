class Nouvelle {
  final int id;
  final String titre;
  final String contenu;
  final String createdAt;

  Nouvelle({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.createdAt,
  });

  factory Nouvelle.fromJson(Map<String, dynamic> json) {
    return Nouvelle(
      id: json['id'],
      titre: json['titre'],
      contenu: json['contenu'],
      createdAt: json['created_at'],
    );
  }
}
