import 'package:flutter/material.dart';
import '../../services/demande_messe_service.dart';
import '../../services/paiement_service.dart';
import 'confirmation_demande_screen.dart';
import 'widgets/form_fields.dart';
import '../../models/user.dart';

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
    _loadTypes();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text("Erreur chargement types : $e")),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
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
        _moyenPaiement == null ||
        _typeMesseId == null ||
        _typeIntentionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text("Veuillez compléter tous les champs obligatoires"),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text("Montant invalide"),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text("Numéro de contact invalide"),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text("Paiement échoué : ${paiement['message']}"),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
            const SizedBox(height: 20),
            Text(
              "Chargement...",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.deepPurple.shade700],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
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
                        children: const [
                          Text(
                            "Demande de Messe",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Remplissez le formulaire ci-dessous",
                            style: TextStyle(
                              color: Colors.white70,
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
                "Informations de la messe",
                Icons.info_outline,
              ),
              const SizedBox(height: 16),
              TypeMesseDropdown(
                types: _typesMesse,
                value: _typeMesseId,
                onChanged: (val) => setState(() => _typeMesseId = val),
              ),
              const SizedBox(height: 16),
              TypeIntentionDropdown(
                types: _typesIntention,
                value: _typeIntentionId,
                onChanged: (val) => setState(() => _typeIntentionId = val),
              ),
              const SizedBox(height: 16),
              DateMessePickerFrench(
                date: _dateMesse,
                onDateSelected: (val) => setState(() => _dateMesse = val),
              ),
              const SizedBox(height: 16),
              HeureMesseFieldFrench(
                selectedTime: _heureMesse,
                onChanged: (val) => setState(() => _heureMesse = val),
              ),
              const SizedBox(height: 16),
              LieuMesseField(controller: _lieuController),
              const SizedBox(height: 16),
              IntentionsField(controller: _intentionsController),
              const SizedBox(height: 32),

              _buildSectionHeader("Informations de paiement", Icons.payment),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade50, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade100, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ModePaiementDropdown(
                      modes: _modes,
                      selectedMode: _moyenPaiement,
                      onChanged: (val) => setState(() => _moyenPaiement = val),
                    ),
                    const SizedBox(height: 16),
                    MontantField(controller: _montantController),
                    const SizedBox(height: 16),
                    ContactField(controller: _contactController),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.deepPurple.shade700],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(0, 18, 14, 207),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isLoading ? null : _soumettreDemande,
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              "Envoi en cours...",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.send_rounded, size: 24),
                            SizedBox(width: 12),
                            Text(
                              "Soumettre la demande",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.deepPurple, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }
}
