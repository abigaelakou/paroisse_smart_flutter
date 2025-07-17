// screens/pain_du_jour/widgets/pain_du_jour_item.dart
import 'package:flutter/material.dart';
import '../../../models/pain_du_jour_item.dart';

class PainDuJourItemWidget extends StatelessWidget {
  final PainDuJourItem pain;

  const PainDuJourItemWidget({super.key, required this.pain});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFE7F5E6), // vert pâle
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.bakery_dining, color: Colors.green),
                SizedBox(width: 8),
                Text("Pain du jour", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              pain.titre,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              pain.contenu,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              "📅 ${pain.date}",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
