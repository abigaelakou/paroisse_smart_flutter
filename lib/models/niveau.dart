class NiveauCatechetique {
  final int id;
  final String libNiveau;

  NiveauCatechetique({required this.id, required this.libNiveau});

  factory NiveauCatechetique.fromJson(Map<String, dynamic> json) {
    return NiveauCatechetique(
      id: json['id'],
      libNiveau: json['lib_niveau'],
    );
  }
}
