import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/evenement.dart';

class EvenementItem extends StatelessWidget {
  final Evenement evenement;

  const EvenementItem({super.key, required this.evenement});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              evenement.libelle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              "📅 ${dateFormat.format(evenement.dateEvenement)} à ${evenement.heureEvenement}",
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                evenement.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
