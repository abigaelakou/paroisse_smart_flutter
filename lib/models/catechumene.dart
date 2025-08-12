class Catechumene {
  final int id;
  final String name;

  Catechumene({required this.id, required this.name});

  factory Catechumene.fromJson(Map<String, dynamic> json) {
    return Catechumene(
      id: json['id'],
      name: json['name'],
    );
  }
}
