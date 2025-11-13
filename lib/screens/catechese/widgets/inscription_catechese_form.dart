import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/services.dart';
import '../../../../models/catechumene.dart';
import '../../../../models/niveau.dart';
import '../../../../models/session.dart';
import '../../../../services/catechese_service.dart';

class InscriptionCatecheseForm extends StatefulWidget {
  final String token;
  final int paroisseId;

  const InscriptionCatecheseForm({
    super.key,
    required this.token,
    required this.paroisseId,
  });

  @override
  State<InscriptionCatecheseForm> createState() =>
      _InscriptionCatecheseFormState();
}

class _InscriptionCatecheseFormState extends State<InscriptionCatecheseForm> {
  final _formKey = GlobalKey<FormState>();
  final _anneeController = TextEditingController();

  DateTime? _selectedDate;

  List<Catechumene> _catechumenes = [];
  List<NiveauCatechetique> _niveaux = [];
  List<SessionCatechese> _sessions = [];

  Catechumene? _selectedCatechumene;
  NiveauCatechetique? _selectedNiveau;
  SessionCatechese? _selectedSession;

  bool _isLoading = false;

  late CatecheseService _service;

  // @override
  // void initState() {
  //   super.initState();
  //   _service = CatecheseService(token: widget.token);
  //   _loadOptions();
  // }
  @override
  void initState() {
    super.initState();
    _service = CatecheseService(token: widget.token);
    _loadOptions();

    // ✅ Pré-remplir automatiquement l'année catéchétique
    final currentYear = DateTime.now().year;
    _anneeController.text = "$currentYear-${currentYear + 1}";
  }

  @override
  void dispose() {
    // _anneeController.dispose();
    final currentYear = DateTime.now().year;
    _anneeController.text = "$currentYear-${currentYear + 1}";
    super.dispose();
  }

  Future<void> _loadOptions() async {
    setState(() => _isLoading = true);
    try {
      _catechumenes = await _service.fetchCatechumenes(widget.paroisseId);
      _niveaux = await _service.fetchNiveaux();
      _sessions = await _service.fetchSessions();
    } catch (e) {
      debugPrint("Erreur _loadOptions(): $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur lors du chargement des données"),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez choisir une date d'inscription"),
        ),
      );
      return;
    }

    try {
      final response = await _service.inscrireCatechumene(
        annee: _anneeController.text,
        dateInscription: _selectedDate!,
        catechumeneId: _selectedCatechumene!.id,
        niveauId: _selectedNiveau!.id,
        sessionId: _selectedSession!.id,
      );

      if (mounted) {
        Navigator.pushNamed(
          context,
          '/paiement-inscription',
          arguments: {
            'token': widget.token,
            'inscriptionId': response.id,
            'paroisseId': widget.paroisseId,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'inscription")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Colors.teal.shade600,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chargement des données...',
                  style: TextStyle(
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader(
                  icon: Icons.person,
                  title: 'Informations du catéchumène',
                  color: Colors.blue.shade600,
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownSearch<Catechumene>(
                    items: _catechumenes,
                    itemAsString: (c) => c.name,
                    selectedItem: _selectedCatechumene,
                    onChanged: (val) =>
                        setState(() => _selectedCatechumene = val),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Sélectionner un catéchumène",
                        prefixIcon: Icon(
                          Icons.person_search,
                          color: Colors.blue.shade600,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    validator: (value) => value == null ? "Champ requis" : null,
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          labelText: 'Rechercher...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildSectionHeader(
                  icon: Icons.school,
                  title: 'Niveau et session',
                  color: Colors.purple.shade600,
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<NiveauCatechetique>(
                    value: _selectedNiveau,
                    hint: const Text("Niveau catéchétique"),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.purple.shade600,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.stairs,
                        color: Colors.purple.shade600,
                      ),
                    ),
                    items: _niveaux.map((n) {
                      return DropdownMenuItem(
                        value: n,
                        child: Text(n.libNiveau),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedNiveau = val),
                    validator: (value) => value == null ? "Champ requis" : null,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<SessionCatechese>(
                    value: _selectedSession,
                    hint: const Text("Session"),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.purple.shade600,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.event_available,
                        color: Colors.purple.shade600,
                      ),
                    ),
                    items: _sessions.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.libSession),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedSession = val),
                    validator: (value) => value == null ? "Champ requis" : null,
                  ),
                ),
                const SizedBox(height: 24),

                _buildSectionHeader(
                  icon: Icons.calendar_today,
                  title: 'Année et date',
                  color: Colors.orange.shade600,
                ),
                TextFormField(
                  controller: _anneeController,
                  decoration: InputDecoration(
                    labelText: "Année catéchétique",
                    hintText: "Ex: 2025-2026",
                    prefixIcon: Icon(
                      Icons.date_range,
                      color: Colors.orange.shade600,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.orange.shade600,
                        width: 2,
                      ),
                    ),
                  ),
                  inputFormatters: [
                    // 🔒 Bloque tout sauf chiffres et tiret
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                    // 🔒 Limite à 9 caractères (ex: 2025-2026)
                    LengthLimitingTextInputFormatter(9),
                  ],
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Champ requis";
                    }

                    // Vérifier le format : 4 chiffres - 4 chiffres
                    final regex = RegExp(r'^\d{4}-\d{4}$');
                    if (!regex.hasMatch(val)) {
                      return "Format invalide. Ex: 2025-2026";
                    }

                    // Extraire les années
                    final parts = val.split('-');
                    final anneeDebut = int.tryParse(parts[0]);
                    final anneeFin = int.tryParse(parts[1]);

                    if (anneeDebut == null || anneeFin == null) {
                      return "Année invalide";
                    }

                    // Année courante et suivante
                    final currentYear = DateTime.now().year;
                    final nextYear = currentYear + 1;

                    if (anneeDebut != currentYear || anneeFin != nextYear) {
                      return "L'année catéchétique doit être $currentYear-$nextYear";
                    }

                    return null; // ✅ Tout est bon
                  },
                ),

                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Colors.orange.shade600,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) setState(() => _selectedDate = date);
                    },
                    icon: const Icon(Icons.calendar_today, size: 20),
                    label: Text(
                      _selectedDate == null
                          ? "Choisir la date d'inscription"
                          : "Date : ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade600, Colors.teal.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.check_circle, size: 24),
                    label: const Text(
                      "Valider l'inscription",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildSectionHeader({
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
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
