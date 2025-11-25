import 'package:paroisse_smart_flutter/models/diocese.dart';

class Paroisse {
  final int id;
  final String nom;
  final String? adresse;
  final String? contact;
  final String? email;
  final int status;
  final int dioceseId;
  final Diocese? diocese;

  Paroisse({
    required this.id,
    required this.nom,
    this.adresse,
    this.contact,
    this.email,
    this.status = 0,
    required this.dioceseId,
    this.diocese,
  });

  factory Paroisse.fromJson(Map<String, dynamic> json) {
    return Paroisse(
      id: json['id'] as int? ?? 0,
      nom: json['nom_paroisse'] as String? ?? json['nom'] as String? ?? '',
      adresse: json['adresse'] as String?,
      contact: json['contact'] as String?,
      email: json['email'] as String?,
      status: json['status'] as int? ?? 0,
      dioceseId: json['diocese_id'] as int? ?? 0,
      diocese: json['diocese'] != null
          ? Diocese.fromJson(json['diocese'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom_paroisse': nom,
      'adresse': adresse,
      'contact': contact,
      'email': email,
      'status': status,
      'diocese_id': dioceseId,
    };
  }

  bool get isActive => status == 1;

  @override
  String toString() {
    return 'Paroisse(id: $id, nom: $nom, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Paroisse && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// class Paroisse {
//   final int id;
//   final String nom;
//   final String? adresse;
//   final String? contact;
//   final String? email;
//   final int? status;
//   final int dioceseId;
//   final Diocese? diocese;

//   Paroisse({
//     required this.id,
//     required this.nom,
//     this.adresse,
//     this.contact,
//     this.email,
//     this.status,
//     required this.dioceseId,
//     this.diocese,
//   });

//   // factory Paroisse.fromJson(Map<String, dynamic> json) {
//   //   return Paroisse(
//   //     id: json['id'],
//   //     nom: json['nom_paroisse'] ?? '',
//   //     adresse: json['adresse'],
//   //     contact: json['contact'],
//   //     email: json['email'],
//   //     status: json['status'],
//   //   );
//   // }

//   factory Paroisse.fromJson(Map<String, dynamic> json) {
//     return Paroisse(
//       id: json['id'] as int,
//       nom: json['nom_paroisse'] as String? ?? json['nom'] as String? ?? '',
//       adresse: json['adresse'] as String?,
//       contact: json['contact'] as String?,
//       email: json['email'] as String?,
//       status: json['status'] as int? ?? 0,
//       dioceseId: json['diocese_id'] as int? ?? 0,
//       diocese: json['diocese'] != null
//           ? Diocese.fromJson(json['diocese'])
//           : null,
//     );
//   }

//   /// Conversion vers JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'nom_paroisse': nom,
//       'adresse': adresse,
//       'contact': contact,
//       'email': email,
//       'status': status,
//       'diocese_id': dioceseId,
//     };
//   }

//   /// Vérifie si la paroisse est active
//   bool get isActive => status == 1;

//   @override
//   String toString() {
//     return 'Paroisse(id: $id, nom: $nom, status: $status)';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is Paroisse && other.id == id;
//   }

//   @override
//   int get hashCode => id.hashCode;
// }
