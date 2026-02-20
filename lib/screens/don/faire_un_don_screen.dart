import 'package:flutter/material.dart';
import '../../services/don_service.dart';
import '../../services/paiement_service.dart';
import '../../../models/user.dart';
import 'don_confirmation_screen.dart';
import 'mes_dons_screen.dart';

class FaireUnDonScreen extends StatefulWidget {
  final String token;
  final int paroisseId;
  final User user;

  const FaireUnDonScreen({
    super.key,
    required this.token,
    required this.paroisseId,
    required this.user,
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

  final List<Map<String, dynamic>> _modesPaiement = [
    {'label': 'Wave', 'icon': Icons.water_drop, 'color': Colors.blue},
    {'label': 'Orange', 'icon': Icons.phone_android, 'color': Colors.orange},
    {
      'label': 'MTN',
      'icon': Icons.signal_cellular_alt,
      'color': const Color.fromARGB(255, 239, 228, 13),
    },
    {'label': 'Moov', 'icon': Icons.phone_iphone, 'color': Colors.red},
    {
      'label': 'VISA',
      'icon': Icons.payments,
      'color': const Color.fromARGB(255, 4, 153, 246),
    },
  ];

  final Map<String, String> _modesPaiementMap = {
    'Moov': 'moov',
    'Orange': 'orange',
    'MTN': 'mtn',
    'Wave': 'wave',
    'VISA': 'visa',
  };

  List<Map<String, dynamic>> _typesDon = [];
  bool _isLoading = false;
  bool _isInitLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTypesDeDon();
  }

  @override
  void dispose() {
    _montantController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTypesDeDon() async {
    try {
      final types = await DonService.fetchTypesDon(
        widget.token,
        widget.paroisseId,
      );
      setState(() {
        _typesDon = types;
        _isInitLoading = false;
      });
    } catch (e) {
      setState(() => _isInitLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur chargement types de don : $e"),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _traiterPaiementEtDon() async {
    if (!_formKey.currentState!.validate()) return;

    if (_modePaiement == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez choisir un mode de paiement."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_typeDonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez choisir un type de don."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final montant = double.parse(_montantController.text.trim());
    final numero = _contactController.text.trim();
    final modePaiementKey = _modesPaiementMap[_modePaiement]!;

    if (['moov', 'mtn', 'orange', 'wave'].contains(modePaiementKey) &&
        numero.isEmpty) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Numéro Mobile Money requis pour ce paiement."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final paiement = await PaiementService.simulerPaiement(
      operateur: modePaiementKey,
      numero: numero,
      montant: montant,
    );

    if (!paiement['success']) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur paiement : ${paiement['message']}"),
            backgroundColor: Colors.red.shade400,
          ),
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
      "contact": numero,
      "id_type_don": _typeDonId,
      "anonymous_donation": _anonyme, // booléen correct
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
                paroisseId: widget.paroisseId,
                user: widget.user,
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
          SnackBar(
            content: Text("Erreur enregistrement : $e"),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.amber.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Chargement...",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.amber.shade700,
        title: const Text(
          "Faire un don",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MesDonsScreen(token: widget.token),
                ),
              );
            },
            icon: const Icon(Icons.receipt_long, color: Colors.white, size: 24),
            label: const Text(
              "Mes dons",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // En-tête inspirant
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade700, Colors.orange.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.volunteer_activism,
                      size: 48,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Votre générosité fait la différence",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Chaque don compte et aide votre paroisse à poursuivre sa mission",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Montant
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _montantController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Montant du don",
                    hintText: "Ex: 5000",
                    suffixText: "FCFA",
                    prefixIcon: Icon(
                      Icons.payments,
                      color: Colors.amber.shade700,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Montant requis";
                    if (double.tryParse(value) == null)
                      return "Montant invalide";
                    if (double.parse(value) <= 0)
                      return "Montant doit être > 0";
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Type de don
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<int>(
                  value: _typeDonId,
                  decoration: InputDecoration(
                    labelText: "Type de don",
                    prefixIcon: Icon(
                      Icons.category,
                      color: Colors.amber.shade700,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _typesDon
                      .map(
                        (type) => DropdownMenuItem(
                          value: type["id"] as int,
                          child: Text(type["lib_type_don"] ?? ''),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _typeDonId = val),
                  validator: (value) => value == null ? "Type requis" : null,
                ),
              ),

              const SizedBox(height: 16),

              // Section Mode de paiement
              const Text(
                "Mode de paiement",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Grille de modes de paiement
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _modesPaiement.length,
                itemBuilder: (context, index) {
                  final mode = _modesPaiement[index];
                  final isSelected = _modePaiement == mode['label'];

                  return GestureDetector(
                    onTap: () => setState(() => _modePaiement = mode['label']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? mode['color'].withOpacity(0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? mode['color']
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: mode['color'].withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            mode['icon'],
                            color: isSelected
                                ? mode['color']
                                : Colors.grey.shade600,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mode['label'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? mode['color']
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Contact Mobile Money
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    labelText: "Numéro Mobile Money",
                    hintText: "Ex: 0707070707",
                    prefixIcon: Icon(
                      Icons.phone_android,
                      color: Colors.amber.shade700,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Contact requis";
                    if (value.length < 8) return "Numéro trop court";
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Message (optionnel)",
                    hintText: "Ajoutez un message à votre don...",
                    prefixIcon: Icon(
                      Icons.message,
                      color: Colors.amber.shade700,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Don anonyme
              Container(
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: CheckboxListTile(
                  title: const Text(
                    "Faire un don anonyme",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    "Votre contact ne sera pas visible côté paroisse",
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _anonyme,
                  onChanged: (val) => setState(() => _anonyme = val ?? false),
                  activeColor: Colors.amber.shade700,
                ),
              ),

              const SizedBox(height: 32),

              // Bouton d'envoi
              ElevatedButton(
                onPressed: _isLoading ? null : _traiterPaiementEtDon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite),
                          SizedBox(width: 8),
                          Text(
                            "Faire un don",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
