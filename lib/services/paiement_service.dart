

class PaiementService {
  static Future<Map<String, dynamic>> simulerPaiement({
    required String operateur,
    required String numero,
    required double montant,
  }) async {
    print("📞 [SIMULATION] Paiement en cours...");
    print("Opérateur: $operateur | Numéro: $numero | Montant: $montant");

    await Future.delayed(const Duration(seconds: 1)); // Simulation d'attente réseau

    if (numero.isEmpty || numero.length < 8) {
      print("❌ Numéro invalide");
      return {
        'success': false,
        'message': "Numéro invalide pour $operateur",
      };
    }

    final transactionId = "TXN_${DateTime.now().millisecondsSinceEpoch}_${operateur.toUpperCase()}";

    print("✅ Paiement simulé avec succès : $transactionId");

    return {
      'success': true,
      'transaction_id': transactionId,
    };
  }
}
