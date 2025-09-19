import 'package:flutter/material.dart';
import '../../../services/demande_messe_service.dart';
import '../../../services/paiement_service.dart';
import 'confirmation_demande_screen.dart';
import './widgets/form_fields.dart';
import '../../../models/user.dart';

class DemandeMesseForm extends StatefulWidget {
  final String token;
  final User user;

  const DemandeMesseForm({super.key, required this.token, required this.user});

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
  final _modesMap = {
    'Moov': 'moov',
    'Orange': 'orange',
    'MTN': 'mtn',
    'Wave': 'wave',
  };

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    setState(() => _isLoading = true);
    try {
      final typesMesse = await DemandeMesseService.fetchTypesMesse(
        widget.token,
        widget.user.paroisseId,
      );
      final typesIntention = await DemandeMesseService.fetchTypesIntention(
        widget.token,
        widget.user.paroisseId,
      );
      if (!mounted) return;
      setState(() {
        _typesMesse = typesMesse;
        _typesIntention = typesIntention;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur chargement types : $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String formatHeureToTimeString(TimeOfDay time) {
    final heures = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$heures:$minutes:00';
  }

  Future<void> _soumettreDemande() async {
    if (!_formKey.currentState!.validate() ||
        _dateMesse == null ||
        _heureMesse == null ||
        _moyenPaiement == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez compléter tous les champs obligatoires"),
        ),
      );
      return;
    }

    final montant = double.tryParse(_montantController.text.trim());
    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Montant invalide")));
      return;
    }

    setState(() => _isLoading = true);

    final numero = _contactController.text.trim();
    final operateur = _modesMap[_moyenPaiement]!;

    try {
      final paiement = await PaiementService.simulerPaiement(
        operateur: operateur,
        numero: numero,
        montant: montant,
      );

      if (!paiement['success']) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Paiement échoué : ${paiement['message']}")),
        );
        setState(() => _isLoading = false);
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

      final response = await DemandeMesseService.envoyerDemandeMesse(
        token: widget.token,
        data: data,
      );

      if (!mounted) return;
      if (response['status'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ConfirmationDemandeScreen(
              message: response['message'] ?? "Demande enregistrée avec succès",
              transactionId: paiement['transaction_id'],
              montant: montant,
              modePaiement: operateur,
              token: widget.token,
              user: widget.user, // ✅ passage direct de l’objet User
            ),
          ),
        );
      } else {
        throw Exception(
          response['message'] ?? "Erreur inconnue lors de l'enregistrement",
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && (_typesMesse.isEmpty || _typesIntention.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TypeMesseDropdown(
            types: _typesMesse,
            value: _typeMesseId,
            onChanged: (val) => setState(() => _typeMesseId = val),
          ),
          const SizedBox(height: 10),
          TypeIntentionDropdown(
            types: _typesIntention,
            value: _typeIntentionId,
            onChanged: (val) => setState(() => _typeIntentionId = val),
          ),
          const SizedBox(height: 10),
          DateMessePicker(
            date: _dateMesse,
            onDateSelected: (val) => setState(() => _dateMesse = val),
          ),
          const SizedBox(height: 10),
          HeureMesseField(
            selectedTime: _heureMesse,
            onChanged: (val) => setState(() => _heureMesse = val),
          ),
          const SizedBox(height: 10),
          LieuMesseField(controller: _lieuController),
          const SizedBox(height: 10),
          IntentionsField(controller: _intentionsController),
          const SizedBox(height: 10),
          ModePaiementDropdown(
            modes: _modes,
            selectedMode: _moyenPaiement,
            onChanged: (val) => setState(() => _moyenPaiement = val),
          ),
          const SizedBox(height: 10),
          MontantField(controller: _montantController),
          const SizedBox(height: 10),
          ContactField(controller: _contactController),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _soumettreDemande,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(
              _isLoading ? "Envoi en cours..." : "Soumettre la demande",
            ),
          ),
        ],
      ),
    );
  }
}
