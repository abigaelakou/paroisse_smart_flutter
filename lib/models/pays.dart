class Pays {
  final int id;
  final String nom;
  final String? code;

  Pays({required this.id, required this.nom, this.code});

  factory Pays.fromJson(Map<String, dynamic> json) {
    return Pays(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nom': nom, 'code': code};
  }

  @override
  String toString() => nom;
}
