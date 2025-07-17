import 'package:flutter/material.dart';
import '../inscription_catechese_screen.dart';
import '../liste_paiements_screen.dart';

class CatecheseMenuScreen extends StatelessWidget {
  final String token;
  final int paroisseId;

  const CatecheseMenuScreen({
    super.key,
    required this.token,
    required this.paroisseId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          const Text(
            "Catéchèse",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // 🔘 Bouton - Faire une inscription
          ElevatedButton.icon(
            icon: const Icon(Icons.app_registration),
            label: const Text("Faire une inscription"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InscriptionCatecheseScreen(
                    token: token,
                    paroisseId: paroisseId,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // 🔘 Bouton - Mes paiements
          ElevatedButton.icon(
            icon: const Icon(Icons.receipt_long),
            label: const Text("Mes paiements"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListePaiementsCatecheseScreen(token: token),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.orange[700],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
