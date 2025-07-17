import 'package:flutter/material.dart';
import 'widgets/demande_messe_form.dart';

class FaireUneDemandeMesseScreen extends StatelessWidget {
  final String token;
  final int paroisseId;
  final String userName;
  final String paroisse;

  const FaireUneDemandeMesseScreen({
    super.key,
    required this.token,
    required this.paroisseId,
    required this.userName,
    required this.paroisse,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         automaticallyImplyLeading: false,
        title: const Text("Demande de messe")),
      body: DemandeMesseForm(
        token: token,
        paroisseId: paroisseId,
        userName: userName,
        paroisse: paroisse,
      ),
    );
  }
}
