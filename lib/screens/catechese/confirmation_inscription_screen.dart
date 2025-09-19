import 'dart:io';
import 'package:flutter/material.dart';
import 'package:paroisse_smart_flutter/screens/catechese/liste_paiements_screen.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // Ajouter dépendance pour PDF

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
    required paroisseId,
  });

  @override
  State<ConfirmationInscriptionScreen> createState() =>
      _ConfirmationInscriptionScreenState();
}

class _ConfirmationInscriptionScreenState
    extends State<ConfirmationInscriptionScreen> {
  late final CatecheseService _service;

  InscriptionCatechese? _details;
  final _formKey = GlobalKey<FormState>();
  String _modePaiement = 'Wave';
  String _contact = '';
  double _montant = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _recuUrl;
  String? _recuLocalPath;

  final List<String> _modes = ['Wave', 'Orange', 'MTN', 'Moov'];

  @override
  void initState() {
    super.initState();
    _service = CatecheseService(token: widget.token);
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);

    try {
      final result = await _service.fetchInscriptionDetails(
        widget.inscriptionId,
      );

      final montantPaiement = result?.paiement?.montant ?? 0.0;

      setState(() {
        _details = result;
        _montant = montantPaiement;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur de chargement des détails")),
        );
      }
    }
  }

  Future<void> _submitPaiement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // 1️⃣ Simuler le paiement
      final result = await PaiementService.simulerPaiement(
        operateur: _modePaiement,
        numero: _contact,
        montant: _montant,
      );

      if (!result['success']) {
        throw Exception(result['message'] ?? 'Échec du paiement');
      }

      // 2️⃣ Appel API pour enregistrer le paiement
      final recuData = await _service.payerInscription(
        inscriptionId: widget.inscriptionId,
        montant: _montant,
        modePaiement: _modePaiement,
        contact: _contact,
      );

      // 3️⃣ Récupérer l'URL du reçu
      _recuUrl = recuData['url'] as String?;
      if (recuData['montant'] != null) {
        _montant = double.tryParse(recuData['montant'].toString()) ?? _montant;
      }

      // 4️⃣ Télécharger localement le PDF
      if (_recuUrl != null) {
        _recuLocalPath = await _telechargerRecu(
          _recuUrl!,
          widget.inscriptionId,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur : ${e.toString()}")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Téléchargement du PDF si non existant
  Future<String?> _telechargerRecu(String url, int inscriptionId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/recu_$inscriptionId.pdf';

      final file = File(filePath);
      if (await file.exists()) {
        return filePath; // PDF déjà présent
      }

      final dio = Dio();
      await dio.download(url, filePath);

      return filePath;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur téléchargement : ${e.toString()}")),
        );
      }
      return null;
    }
  }

  void _ouvrirRecu() {
    if (_recuLocalPath == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecuPdfLocalScreen(path: _recuLocalPath!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement de l\'inscription')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: _recuLocalPath != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 60,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Paiement effectué avec succès !',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _ouvrirRecu,
                            icon: const Icon(Icons.download),
                            label: const Text("Voir le reçu"),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ListePaiementsCatecheseScreen(
                                    token: widget.token,
                                  ),
                                ),
                              );
                            },
                            child: const Text("Voir mes paiements"),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Catéchumène : ${_details?.nomCatechumene ?? ''}",
                              ),
                              Text("Niveau : ${_details?.niveau ?? ''}"),
                              Text("Session : ${_details?.session ?? ''}"),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: "Montant",
                                  border: OutlineInputBorder(),
                                ),
                                initialValue: _montant.toString(),
                                keyboardType: TextInputType.number,
                                validator: (val) =>
                                    val == null || double.tryParse(val) == null
                                    ? "Entrer un montant valide"
                                    : null,
                                onChanged: (val) =>
                                    _montant = double.tryParse(val) ?? 0.0,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: "Mode de paiement",
                                  border: OutlineInputBorder(),
                                ),
                                value: _modePaiement,
                                items: _modes
                                    .map(
                                      (mode) => DropdownMenuItem(
                                        value: mode,
                                        child: Text(mode),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _modePaiement = val!),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: "Contact (optionnel)",
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (val) => _contact = val,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : _submitPaiement,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text("Payer"),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
      ),
    );
  }
}

class RecuPdfLocalScreen extends StatelessWidget {
  final String path;
  const RecuPdfLocalScreen({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reçu PDF')),
      body: SfPdfViewer.file(File(path)),
    );
  }
}
