class Paroisse {
  final int id;
  final String nom;

  Paroisse({required this.id, required this.nom});

  factory Paroisse.fromJson(Map<String, dynamic> json) {
    return Paroisse(
      id: json['id'],
      nom: json['nom_paroisse'],
    );
  }
}
