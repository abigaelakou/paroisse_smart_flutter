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
  bool _isSubmitting = false;

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
      final catechumenes = await _service.fetchCatechumenes(widget.paroisseId);
      final niveaux = await _service.fetchNiveaux();
      final sessions = await _service.fetchSessions();

      setState(() {
        _catechumenes = catechumenes;
        _niveaux = niveaux;
        _sessions = sessions;
      });
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

    setState(() => _isSubmitting = true);

    try {
      final _ = await _service.inscrireCatechumene(
        annee: _anneeController.text.trim(),
        dateInscription: _selectedDate!,
        catechumeneId: _selectedCatechumene!.id,
        niveauId: _selectedNiveau!.id,
        sessionId: _selectedSession!.id,
      );

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/paiement-inscription',
        arguments: {'token': widget.token, 'paroisseId': widget.paroisseId},
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l’inscription")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔘 Catéchumène
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
                  decoration: InputDecoration(labelText: 'Rechercher...'),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 🔘 Niveau
            DropdownButtonFormField<NiveauCatechetique>(
              value: _selectedNiveau,
              hint: const Text("Niveau catéchétique"),
              items: _niveaux
                  .map(
                    (n) => DropdownMenuItem(value: n, child: Text(n.libNiveau)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedNiveau = val),
              validator: (value) => value == null ? "Champ requis" : null,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            // 🔘 Session
            DropdownButtonFormField<SessionCatechese>(
              value: _selectedSession,
              hint: const Text("Session"),
              items: _sessions
                  .map(
                    (s) =>
                        DropdownMenuItem(value: s, child: Text(s.libSession)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedSession = val),
              validator: (value) => value == null ? "Champ requis" : null,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            // 🔘 Année
            TextFormField(
              controller: _anneeController,
              decoration: const InputDecoration(
                labelText: "Année catéchétique",
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty
                  ? "Champ requis"
                  : (val.length < 4 ? "Année invalide" : null),
            ),
            const SizedBox(height: 12),

            // 🔘 Date
            ElevatedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDate == null
                    ? "Choisir la date d’inscription"
                    : "Date : ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            // 🔘 Bouton soumission
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text("Valider l'inscription"),
            ),
          ],
        ),
      ),
    );
  }
}
