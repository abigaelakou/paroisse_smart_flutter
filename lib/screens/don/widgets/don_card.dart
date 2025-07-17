import 'package:flutter/material.dart';
import '../../../models/don.dart';

class DonCard extends StatelessWidget {
  final Don don;
  const DonCard({super.key, required this.don});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.volunteer_activism, color: Colors.deepPurple),
        title: Text("${don.montant} FCFA - ${don.modePaiement}"),
        subtitle: Text("Le ${don.dateDon}"),
        trailing: Text(
          don.paymentStatus,
          style: TextStyle(
            color: don.paymentStatus.toLowerCase() == 'payé' ? Colors.green : Colors.orange,
          ),
        ),
      ),
    );
  }
}
