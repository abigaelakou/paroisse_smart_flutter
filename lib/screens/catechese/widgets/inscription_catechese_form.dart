import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
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
  State<InscriptionCatecheseForm> createState() => _InscriptionCatecheseFormState();
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

  @override
  void initState() {
    super.initState();
    _service = CatecheseService(token: widget.token); 
    _loadOptions();
  }

  @override
  void dispose() {
    _anneeController.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors du chargement des données")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir une date d'inscription")),
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

      Navigator.pushNamed(context, '/paiement-inscription', arguments: {
        'token': widget.token,
        'inscriptionId': response.id,
        'paroisseId': widget.paroisseId,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l’inscription")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownSearch<Catechumene>(
                    items: _catechumenes,
                    itemAsString: (c) => c.name,
                    selectedItem: _selectedCatechumene,
                    onChanged: (val) => setState(() => _selectedCatechumene = val),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Sélectionner un catéchumène",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    validator: (value) => value == null ? "Champ requis" : null,
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          labelText: 'Rechercher...',
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                DropdownButtonFormField<NiveauCatechetique>(
                  value: _selectedNiveau,
                  hint: const Text("Niveau catéchétique"),
                  items: _niveaux.map((n) {
                    return DropdownMenuItem(value: n, child: Text(n.libNiveau));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedNiveau = val),
                  validator: (value) => value == null ? "Champ requis" : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<SessionCatechese>(
                  value: _selectedSession,
                  hint: const Text("Session"),
                  items: _sessions.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s.libSession));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedSession = val),
                  validator: (value) => value == null ? "Champ requis" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _anneeController,
                  decoration: const InputDecoration(labelText: "Année catéchétique"),
                  validator: (val) => val!.isEmpty ? "Champ requis" : null,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_selectedDate == null
                      ? "Choisir la date d’inscription"
                      : "Date : ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text("Valider l'inscription"),
                ),
              ],
            ),
          );
  }
}
