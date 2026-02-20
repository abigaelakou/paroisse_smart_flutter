import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:paroisse_smart_flutter/navigation/main_scaffold.dart';
import '../../../models/user.dart';

class DonConfirmationScreen extends StatelessWidget {
  final double montant;
  final String modePaiement;
  final String description;
  final String transactionId;
  final String token;
  final int paroisseId;
  final User user;

  const DonConfirmationScreen({
    super.key,
    required this.montant,
    required this.modePaiement,
    required this.description,
    required this.transactionId,
    required this.token,
    required this.paroisseId,
    required this.user,
  });

  String _formatMontant(double montant) {
    final formatter = NumberFormat.decimalPattern("fr_FR");
    return "${formatter.format(montant)} FCFA";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        title: const Text(
          "Confirmation du don",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Animation de succès
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Lottie.asset(
                        'assets/animations/success.json',
                        repeat: false,
                        width: 120,
                        height: 120,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback si l'animation n'existe pas
                          return Icon(
                            Icons.check_circle,
                            size: 100,
                            color: Colors.green.shade700,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Titre de remerciement
                    const Text(
                      "Don effectué avec succès !",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Merci pour votre générosité 🙏",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Card principale avec détails
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade50,
                            Colors.green.shade100.withOpacity(0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade200.withOpacity(0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green.shade200,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Montant principal
                            const Text(
                              "Montant du don",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatMontant(montant),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Séparateur
                            Container(height: 1, color: Colors.green.shade200),

                            const SizedBox(height: 24),

                            // Détails du paiement
                            _buildDetailRow(
                              icon: Icons.payment,
                              label: "Mode de paiement",
                              value: modePaiement,
                            ),

                            const SizedBox(height: 16),

                            _buildDetailRow(
                              icon: Icons.receipt_long,
                              label: "ID Transaction",
                              value: transactionId,
                            ),

                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                icon: Icons.message,
                                label: "Message",
                                value: description,
                              ),
                            ],

                            const SizedBox(height: 16),

                            _buildDetailRow(
                              icon: Icons.calendar_today,
                              label: "Date",
                              value: DateFormat(
                                'dd MMMM yyyy à HH:mm',
                                'fr_FR',
                              ).format(DateTime.now()),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Message inspirant
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber.shade700,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Votre don aide notre paroisse à poursuivre sa mission spirituelle et caritative.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amber.shade900,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Boutons en bas
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bouton retour à l'accueil
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MainScaffold(
                                token: token,
                                user: user,
                                initialIndex: 0, // Onglet Accueil
                              ),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home),
                            SizedBox(width: 8),
                            Text(
                              "Retour à l'accueil",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Bouton faire un autre don
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MainScaffold(
                                token: token,
                                user: user,
                                initialIndex: 1, // Onglet Don
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green.shade700,
                          side: BorderSide(
                            color: Colors.green.shade700,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.volunteer_activism),
                            SizedBox(width: 8),
                            Text(
                              "Faire un autre don",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.green.shade700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
