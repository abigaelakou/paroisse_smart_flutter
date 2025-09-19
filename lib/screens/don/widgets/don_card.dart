import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/don.dart';

class DonCard extends StatelessWidget {
  final Don don;
  const DonCard({super.key, required this.don});

  String _formatMontant(double montant) {
    final formatter = NumberFormat.decimalPattern("fr_FR");
    return "${formatter.format(montant)} FCFA";
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat("dd MMM yyyy à HH:mm", "fr_FR").format(date);
    } catch (e) {
      return dateString; // fallback si le parsing échoue
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = don.paymentStatus.toLowerCase() == 'payé';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: isPaid
              ? Colors.green.withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
          child: Icon(
            Icons.volunteer_activism,
            color: isPaid ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(
          "${_formatMontant(don.montant)} - ${don.modePaiement}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "Le ${_formatDate(don.dateDon)}",
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          don.paymentStatus,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPaid ? Colors.green : Colors.orange,
          ),
        ),
      ),
    );
  }
}
