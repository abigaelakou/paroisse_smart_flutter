import 'package:flutter/material.dart';
import '../../../models/demande_messe.dart';

class DemandeMesseCard extends StatelessWidget {
  final DemandeMesse demande;

  const DemandeMesseCard({super.key, required this.demande});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.church, color: Colors.deepPurple),
        title: Text("${demande.typeMesse} - ${demande.typeIntention}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date : ${demande.dateMesse} à ${demande.heureMesse}"),
            Text("Lieu : ${demande.lieuMesse}"),
            Text("Intentions : ${demande.intentions}"),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
