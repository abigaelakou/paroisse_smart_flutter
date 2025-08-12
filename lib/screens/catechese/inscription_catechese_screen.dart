import 'package:flutter/material.dart';
import 'widgets/inscription_catechese_form.dart';

class InscriptionCatecheseScreen extends StatelessWidget {
  final String token;
  final int paroisseId;

  const InscriptionCatecheseScreen({
    super.key,
    required this.token,
    required this.paroisseId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inscription à la catéchèse"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: InscriptionCatecheseForm(
          token: token,
          paroisseId: paroisseId,
        ),
      ),
    );
  }
}
