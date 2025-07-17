import 'package:flutter/material.dart';
import '../../services/don_service.dart';
import '../../services/paiement_service.dart';
import 'don_confirmation_screen.dart';
import 'mes_dons_screen.dart';

class FaireUnDonScreen extends StatefulWidget {
  final String token;
  final int paroisseId;

  const FaireUnDonScreen({
    super.key,
    required this.token,
    required this.paroisseId,
  });

  @override
  State<FaireUnDonScreen> createState() => _FaireUnDonScreenState();
}

class _FaireUnDonScreenState extends State<FaireUnDonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _modePaiement;
  int? _typeDonId;
  bool _anonyme = false;

  final List<String> _modesPaiementLabels = ['Moov', 'Orange', 'MTN', 'Wave', 'Espèces'];
  final Map<String, String> _modesPaiementMap = {
    'Moov': 'moov',
    'Orange': 'orange',
    'MTN': 'mtn',
    'Wave': 'wave',
    'Espèces': 'especes',
  };

  List<Map<String, dynamic>> _typesDon = [];
  bool _isLoading = false;
  bool _isInitLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTypesDeDon();
  }

  Future<void> _loadTypesDeDon() async {
    try {
      final types = await DonService.fetchTypesDon(widget.token, widget.paroisseId);
      setState(() {
        _typesDon = types;
        _isInitLoading = false;
      });
    } catch (e) {
      setState(() => _isInitLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur chargement types de don : $e")),
      );
    }
  }

  Future<void> _traiterPaiementEtDon() async {
    if (!_formKey.currentState!.validate()) return;

    if (_modePaiement == null || !_modesPaiementMap.containsKey(_modePaiement)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir un mode de paiement valide.")),
      );
      return;
    }

    if (_typeDonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir un type de don.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final montant = double.parse(_montantController.text.trim());
    final numero = _contactController.text.trim();
    final modePaiementKey = _modesPaiementMap[_modePaiement]!;

    final paiement = await PaiementService.simulerPaiement(
      operateur: modePaiementKey,
      numero: numero,
      montant: montant,
    );

    if (!paiement['success']) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur paiement : ${paiement['message']}")),
        );
      }
      return;
    }

    await _enregistrerDon(
      montant: montant,
      mode: modePaiementKey,
      numero: numero,
      transactionId: paiement['transaction_id'],
    );
  }

  Future<void> _enregistrerDon({
    required double montant,
    required String mode,
    required String numero,
    required String transactionId,
  }) async {
    final donData = {
      "description": _descriptionController.text.trim(),
      "mode_paiement": mode,
      "montant": montant,
      "contact": _anonyme ? '' : numero,
      "id_type_don": _typeDonId,
      "paroisse_id": widget.paroisseId,
      "anonymous_donation": _anonyme,
      "transaction_id": transactionId,
    };

    try {
      final response = await DonService.faireUnDon(donData, widget.token);

      if (response['status'] == true) {
        _montantController.clear();
        _contactController.clear();
        _descriptionController.clear();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DonConfirmationScreen(
                montant: montant,
                modePaiement: _modePaiement ?? mode,
                description: (donData['description'] ?? '').toString(),
                transactionId: transactionId,
                token: widget.token,
              ),
            ),
          );
        }
      } else {
        throw Exception(response['message'] ?? 'Erreur inconnue');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur enregistrement : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
         automaticallyImplyLeading: false,
        title: const Text("Faire un don")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Montant (FCFA)"),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Champ obligatoire";
                  if (double.tryParse(value) == null) return "Montant invalide";
                  if (double.parse(value) <= 0) return "Montant doit être > 0";
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _modePaiement,
                items: _modesPaiementLabels
                    .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
                    .toList(),
                onChanged: (val) => setState(() => _modePaiement = val),
                decoration: const InputDecoration(labelText: "Mode de paiement"),
                validator: (value) => value == null ? "Champ requis" : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _typeDonId,
                items: _typesDon
                    .map((type) => DropdownMenuItem(
                          value: type["id"] as int,
                          child: Text(type["lib_type_don"] ?? ''),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _typeDonId = val),
                decoration: const InputDecoration(labelText: "Type de don"),
                validator: (value) => value == null ? "Champ requis" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contactController,
                enabled: !_anonyme,
                decoration: const InputDecoration(labelText: "Contact Mobile Money"),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (!_anonyme && (value == null || value.isEmpty)) {
                    return "Champ obligatoire";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: "Description (facultatif)"),
              ),
              CheckboxListTile(
                title: const Text("Faire un don anonyme"),
                value: _anonyme,
                onChanged: (val) {
                  setState(() {
                    _anonyme = val ?? false;
                    if (_anonyme) _contactController.clear();
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _traiterPaiementEtDon,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                label: Text(_isLoading ? "Traitement..." : "Faire un don"),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MesDonsScreen(token: widget.token),
                    ),
                  );
                },
                child: const Text(
                  "Voir l'historique de mes dons",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
