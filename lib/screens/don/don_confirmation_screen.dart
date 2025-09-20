import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DonConfirmationScreen extends StatelessWidget {
  final double montant;
  final String modePaiement;
  final String description;
  final String transactionId;
  final String token; // prêt si tu veux l'utiliser plus tard pour fetch un reçu

  const DonConfirmationScreen({
    super.key,
    required this.montant,
    required this.modePaiement,
    required this.description,
    required this.transactionId,
    required this.token,
  });

  String _formatMontant(double montant) {
    final formatter = NumberFormat.decimalPattern("fr_FR");
    return "${formatter.format(montant)} FCFA";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirmation du don")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 90, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "Merci pour votre don !",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Détails du don dans une Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Montant : ${_formatMontant(montant)}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Mode de paiement : $modePaiement",
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        "Description : $description",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      "ID de transaction : $transactionId",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Retour à l'accueil"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
