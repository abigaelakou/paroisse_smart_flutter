import 'package:flutter/material.dart';
import 'package:paroisse_smart_flutter/screens/catechese/liste_paiements_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/inscription_catechese.dart';
import '../../services/catechese_service.dart';
import '../../services/paiement_service.dart';

class ConfirmationInscriptionScreen extends StatefulWidget {
  final int inscriptionId;
  final String token;

  const ConfirmationInscriptionScreen({
    super.key,
    required this.inscriptionId,
    required this.token,
  });

  @override
  State<ConfirmationInscriptionScreen> createState() => _ConfirmationInscriptionScreenState();
}

class _ConfirmationInscriptionScreenState extends State<ConfirmationInscriptionScreen> {
  late final CatecheseService _service;

  InscriptionCatechese? _details;
  final _formKey = GlobalKey<FormState>();
  String _modePaiement = 'Wave';
  String _contact = '';
  double _montant = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _recuUrl;

  final List<String> _modes = ['Wave', 'Orange', 'MTN', 'Moov'];

  @override
  void initState() {
    super.initState();
    _service = CatecheseService(token: widget.token);
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final result = await _service.fetchInscriptionDetails(widget.inscriptionId);
      setState(() {
        _details = result;
        _montant = result.paiement?.montant ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de chargement")),
      );
    }
  }

  Future<void> _submitPaiement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final result = await PaiementService.simulerPaiement(
      operateur: _modePaiement,
      numero: _contact,
      montant: _montant,
    );

    if (!result['success']) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Échec du paiement')),
      );
      return;
    }

    try {
      final recu = await _service.payerInscription(
        inscriptionId: widget.inscriptionId,
        montant: _montant,
        modePaiement: _modePaiement,
        contact: _contact,
      );

      setState(() {
        _isSubmitting = false;
        _recuUrl = recu;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du paiement : ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement de l\'inscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _recuUrl != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  const SizedBox(height: 20),
                  const Text('Paiement effectué avec succès !'),
                  TextButton(
                    onPressed: () async {
                      final url = Uri.parse(_recuUrl!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Impossible d’ouvrir le reçu.")),
                        );
                      }
                    },
                    child: const Text("Télécharger le reçu"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListePaiementsCatecheseScreen(token: widget.token),
                        ),
                      );
                    },
                    child: const Text("Voir mes paiements"),
                  ),
                ],
              )
            : Form(key: _formKey,
                child: ListView(
                  children: [
                    Text("Catéchumène : ${_details?.nomCatechumene ?? ''}"),
                    Text("Niveau : ${_details?.niveau ?? ''}"),
                    Text("Session : ${_details?.session ?? ''}"),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Montant"),
                      initialValue: _montant > 0 ? _montant.toString() : null,
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val == null || double.tryParse(val) == null ? "Entrer un montant valide" : null,
                      onChanged: (val) => _montant = double.tryParse(val) ?? 0,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "Mode de paiement"),
                      value: _modePaiement,
                      items: _modes.map((mode) {
                        return DropdownMenuItem(value: mode, child: Text(mode));
                      }).toList(),
                      onChanged: (val) => setState(() => _modePaiement = val!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Contact (optionnel)"),
                      onChanged: (val) => _contact = val,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitPaiement,
                      child: _isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text("Payer"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
