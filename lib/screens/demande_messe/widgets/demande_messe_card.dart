import 'package:flutter/material.dart';
import '../../../models/demande_messe.dart';
import 'package:intl/intl.dart';

class DemandeMesseCard extends StatelessWidget {
  final DemandeMesse demande;

  const DemandeMesseCard({super.key, required this.demande});

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "Non définie";
    try {
      final dt = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return date; // Si parsing échoue, on renvoie la chaîne brute
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = _formatDate(demande.dateMesse);
    final heure = demande.heureMesse.isNotEmpty == true
        ? demande.heureMesse
        : "Non définie";
    final lieu = demande.lieuMesse.isNotEmpty == true
        ? demande.lieuMesse
        : "Non défini";
    final intentions = demande.intentions.isNotEmpty == true
        ? demande.intentions
        : "Aucune intention";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: const Icon(Icons.church, color: Colors.deepPurple),
        title: Text(
          "${demande.typeMesse} - ${demande.typeIntention}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Date : $date à $heure"),
            Text("Lieu : $lieu"),
            Text("Intentions : $intentions"),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
