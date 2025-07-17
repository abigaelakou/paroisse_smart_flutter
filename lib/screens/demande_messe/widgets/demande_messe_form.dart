import 'package:flutter/material.dart';
import '../../../services/demande_messe_service.dart';
import '../../../services/paiement_service.dart';
import '../confirmation_demande_screen.dart';
import 'form_fields.dart';

class DemandeMesseForm extends StatefulWidget {
  final String token;
  final int paroisseId;
  final String userName;
  final String paroisse;

  const DemandeMesseForm({
    super.key,
    required this.token,
    required this.paroisseId,
    required this.userName,
    required this.paroisse,
  });

  @override
  State<DemandeMesseForm> createState() => _DemandeMesseFormState();
}

class _DemandeMesseFormState extends State<DemandeMesseForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _lieuController = TextEditingController();
  final TextEditingController _intentionsController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  DateTime? _dateMesse;
  TimeOfDay? _heureMesse;
  String? _moyenPaiement;
  int? _typeMesseId;
  int? _typeIntentionId;

  List<Map<String, dynamic>> _typesMesse = [];
  List<Map<String, dynamic>> _typesIntention = [];

  bool _isLoading = false;

  final _modes = ['Moov', 'Orange', 'MTN', 'Wave'];
  final _modesMap = {'Moov': 'moov', 'Orange': 'orange', 'MTN': 'mtn', 'Wave': 'wave'};

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    try {
      final typesMesse = await DemandeMesseService.fetchTypesMesse(widget.token, widget.paroisseId);
      final typesIntention = await DemandeMesseService.fetchTypesIntention(widget.token, widget.paroisseId);
      setState(() {
        _typesMesse = typesMesse;
        _typesIntention = typesIntention;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur chargement types : $e")));
      }
    }
  }

  String formatHeureToTimeString(TimeOfDay time) {
    final heures = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$heures:$minutes:00';
  }

  Future<void> _soumettreDemande() async {
    if (!_formKey.currentState!.validate() || _dateMesse == null || _moyenPaiement == null || _heureMesse == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Formulaire incomplet")));
      return;
    }

    setState(() => _isLoading = true);

    final montant = double.parse(_montantController.text.trim());
    final numero = _contactController.text.trim();
    final operateur = _modesMap[_moyenPaiement]!;

    final paiement = await PaiementService.simulerPaiement(
      operateur: operateur,
      numero: numero,
      montant: montant,
    );

    if (!paiement['success']) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Paiement échoué : ${paiement['message']}")));
      return;
    }

    final data = {
      "id_type_messe": _typeMesseId,
      "id_type_intention": _typeIntentionId,
      "date_messe": _dateMesse!.toIso8601String().split('T')[0],
      "heure_messe": formatHeureToTimeString(_heureMesse!),
      "lieu_messe": _lieuController.text.trim(),
      "intentions": _intentionsController.text.trim(),
      "montant": montant,
      "moyen_paiement": operateur,
      "contact": numero,
      "transaction_id": paiement['transaction_id'],
    };

    try {
      final response = await DemandeMesseService.envoyerDemandeMesse(token: widget.token, data: data);
      if (response['status'] == true) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ConfirmationDemandeScreen(
              message: response['message'],
              transactionId: paiement['transaction_id'],
              montant: montant,
              modePaiement: operateur,
              token: widget.token,
              userName: widget.userName,
              paroisse: widget.paroisse,
              paroisseId: widget.paroisseId,
            ),
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Erreur inconnue');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur enregistrement : $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_typesMesse.isEmpty || _typesIntention.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TypeMesseDropdown(types: _typesMesse, value: _typeMesseId, onChanged: (val) => setState(() => _typeMesseId = val)),
          const SizedBox(height: 10),
          TypeIntentionDropdown(types: _typesIntention, value: _typeIntentionId, onChanged: (val) => setState(() => _typeIntentionId = val)),
          const SizedBox(height: 10),
          DateMessePicker(date: _dateMesse, onDateSelected: (val) => setState(() => _dateMesse = val)),
          const SizedBox(height: 10),
          HeureMesseField(selectedTime: _heureMesse, onChanged: (val) => setState(() => _heureMesse = val)),
          const SizedBox(height: 10),
          LieuMesseField(controller: _lieuController),
          const SizedBox(height: 10),
          IntentionsField(controller: _intentionsController),
          const SizedBox(height: 10),
          ModePaiementDropdown(modes: _modes, selectedMode: _moyenPaiement, onChanged: (val) => setState(() => _moyenPaiement = val)),
          const SizedBox(height: 10),
          MontantField(controller: _montantController),
          const SizedBox(height: 10),
          ContactField(controller: _contactController),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _soumettreDemande,
            icon: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send),
            label: Text(_isLoading ? "Envoi en cours..." : "Soumettre la demande"),
          ),
        ],
      ),
    );
  }
}
