import 'package:flutter/material.dart';

class DonConfirmationScreen extends StatelessWidget {
  final double montant; 
  final String modePaiement;
  final String description;
  final String transactionId;
  final String token;

  const DonConfirmationScreen({
    super.key,
    required this.montant,
    required this.modePaiement,
    required this.description,
    required this.transactionId,
     required this.token, 
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirmation du don")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 20),
           Text(
              "Merci pour votre don !",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 10),
            Text("Montant : $montant FCFA"),
            Text("Mode de paiement : $modePaiement"),
            if (description.isNotEmpty) Text("Description : $description"),
            Text("ID de transaction : $transactionId"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Retour"),
            )
          ],
        ),
      ),
    );
  }
}
