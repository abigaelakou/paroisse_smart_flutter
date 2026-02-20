import 'package:flutter/material.dart';
import '../../../services/demande_messe_service.dart';
import '../../../services/paiement_service.dart';
import '../confirmation_demande_screen.dart';
import 'form_fields.dart';
import '../../../models/user.dart';

class DemandeMesseForm extends StatefulWidget {
  final String token;
  final User user;

  const DemandeMesseForm({super.key, required this.token, required this.user});

  @override
  State<DemandeMesseForm> createState() => _DemandeMesseFormState();
}

class _DemandeMesseFormState extends State<DemandeMesseForm>
    with SingleTickerProviderStateMixin {
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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    // _loadTypes();
  }

  @override
  void dispose() {
    _lieuController.dispose();
    _intentionsController.dispose();
    _montantController.dispose();
    _contactController.dispose();
    _animationController.dispose();
    super.dispose();
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
        _moyenPaiement == null ||
        _typeMesseId == null ||
        _typeIntentionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text("Veuillez compléter tous les champs obligatoires"),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final montant = double.tryParse(_montantController.text.trim());
    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              const Text("Montant invalide"),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final numero = _contactController.text.trim();
    if (numero.isEmpty || numero.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              const Text("Numéro de contact invalide"),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final operateur = _modesMap[_moyenPaiement!]!;
    setState(() => _isLoading = true);

    try {
      final paiement = await PaiementService.simulerPaiement(
        operateur: operateur,
        numero: numero,
        montant: montant,
      );

      if (!paiement['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.cancel_outlined, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text("Paiement échoué : ${paiement['message']}"),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
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
              user: widget.user,
            ),
          ),
        );
      } else {
        throw Exception(response['message'] ?? "Erreur inconnue");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text("Erreur : $e")),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && (_typesMesse.isEmpty || _typesIntention.isEmpty)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Chargement des informations...",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.church,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Demande de Messe",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Remplissez le formulaire ci-dessous",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(
              context,
              icon: Icons.info_outline,
              title: "Informations de la messe",
              color: Colors.blue,
            ),
            const SizedBox(height: 12),

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
            DateMessePickerFrench(
              date: _dateMesse,
              onDateSelected: (val) => setState(() => _dateMesse = val),
            ),
            const SizedBox(height: 10),
            HeureMesseFieldFrench(
              selectedTime: _heureMesse,
              onChanged: (val) => setState(() => _heureMesse = val),
            ),
            const SizedBox(height: 10),
            LieuMesseField(controller: _lieuController),
            const SizedBox(height: 10),
            IntentionsField(controller: _intentionsController),
            const SizedBox(height: 24),

            _buildSectionHeader(
              context,
              icon: Icons.payment,
              title: "Informations de paiement",
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade100.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Détails du paiement",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ModePaiementDropdown(
                      modes: _modes,
                      selectedMode: _moyenPaiement,
                      onChanged: (val) => setState(() => _moyenPaiement = val),
                    ),
                    const SizedBox(height: 10),
                    MontantField(controller: _montantController),
                    const SizedBox(height: 10),
                    ContactField(controller: _contactController),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isLoading
                      ? [Colors.grey.shade400, Colors.grey.shade500]
                      : [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.8),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _isLoading
                        ? Colors.grey.shade300
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isLoading ? null : _soumettreDemande,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    else
                      const Icon(
                        Icons.send_rounded,
                        size: 24,
                        color: Colors.white,
                      ),
                    const SizedBox(width: 12),
                    Text(
                      _isLoading ? "Envoi en cours..." : "Soumettre la demande",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.3), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
