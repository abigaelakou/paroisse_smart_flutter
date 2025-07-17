import 'package:flutter/material.dart';
import '../../navigation/main_scaffold.dart';

class ConfirmationDemandeScreen extends StatelessWidget {
  final String message;
  final String transactionId;
  final double montant;
  final String modePaiement;
  final String token;
  final String userName;
  final String paroisse;
  final int paroisseId;

  const ConfirmationDemandeScreen({
    super.key,
    required this.message,
    required this.transactionId,
    required this.montant,
    required this.modePaiement,
    required this.token,
    required this.userName,
    required this.paroisse,
    required this.paroisseId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirmation")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildInfoRow("Mode de paiement", modePaiement.toUpperCase()),
            _buildInfoRow("Montant", "${montant.toStringAsFixed(0)} FCFA"),
            _buildInfoRow("ID Transaction", transactionId),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text("Retour à l’accueil"),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MainScaffold(
                      token: token,
                      userName: userName,
                      paroisse: paroisse,
                      paroisseId: paroisseId,
                    ),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label :", style: const TextStyle(fontWeight: FontWeight.w500)),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
