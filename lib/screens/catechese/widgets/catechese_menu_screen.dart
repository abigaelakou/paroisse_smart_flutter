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
      appBar: AppBar(
        title: const Text("Catéchèse"),
        centerTitle: true,
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // 🔘 Bouton - Faire une inscription
            _buildMenuButton(
              context,
              icon: Icons.app_registration,
              label: "Faire une inscription",
              color: Colors.green[700]!,
              onTap: () {
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
            ),
            const SizedBox(height: 20),

            // 🔘 Bouton - Mes paiements
            _buildMenuButton(
              context,
              icon: Icons.receipt_long,
              label: "Mes paiements",
              color: Colors.orange[700]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ListePaiementsCatecheseScreen(token: token),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔧 Widget réutilisable pour éviter la répétition du code
  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 26),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
    );
  }
}
