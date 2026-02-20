import 'package:flutter/foundation.dart';

class PaiementService {
  /// Simule un paiement pour tests
  static Future<Map<String, dynamic>> simulerPaiement({
    required String operateur,
    required String numero,
    required double montant,
  }) async {
    if (kDebugMode) {
      debugPrint("📞 [SIMULATION] Paiement en cours...");
      debugPrint("Opérateur: $operateur | Numéro: $numero | Montant: $montant");
    }

    // Simulation d'attente réseau
    await Future.delayed(const Duration(seconds: 1));

    // Validation simple du numéro
    if (numero.isEmpty || numero.length < 8) {
      if (kDebugMode) debugPrint("❌ Numéro invalide");
      return {'success': false, 'message': "Numéro invalide pour $operateur"};
    }

    final transactionId =
        "TXN_${DateTime.now().millisecondsSinceEpoch}_${operateur.toUpperCase()}";

    if (kDebugMode) {
      debugPrint("✅ Paiement simulé avec succès : $transactionId");
    }

    return {'success': true, 'transaction_id': transactionId};
  }
}
