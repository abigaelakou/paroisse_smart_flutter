import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../services/pays_service.dart';
import '../../services/diocese_service.dart';
import '../../services/paroisse_service.dart';
import '../../services/auth_service.dart';
import '../../services/formatters.dart';
import '../../models/pays.dart';
import '../../models/diocese.dart';
import '../../models/paroisse.dart';

class RegisterParoissienScreen extends StatefulWidget {
  const RegisterParoissienScreen({Key? key}) : super(key: key);

  @override
  State<RegisterParoissienScreen> createState() =>
      _RegisterParoissienScreenState();
}

class _RegisterParoissienScreenState extends State<RegisterParoissienScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _dateNaissController = TextEditingController();
  final _lieuHabitationController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _selectedSexe;
  String? _selectedSituation;
  List<String> _sacrementsRecus = [];

  Pays? _selectedPays;
  Diocese? _selectedDiocese;
  Paroisse? _selectedParoisse;

  bool _isLoading = false;
  bool _isLoadingDioceses = false;
  bool _isLoadingParoisses = false;

  List<Pays> _paysList = [];
  List<Diocese> _diocesesList = [];
  List<Paroisse> _paroissesList = [];

  final PaysService _paysService = PaysService();
  final DioceseService _dioceseService = DioceseService();
  final ParoisseService _paroisseService = ParoisseService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadPays();
  }

  Future<void> _loadPays() async {
    try {
      final pays = await _paysService.fetchPays();
      if (!mounted) return;
      setState(() => _paysList = pays);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur chargement pays: $e'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  Future<void> _loadDioceses(int paysId) async {
    setState(() {
      _isLoadingDioceses = true;
      _diocesesList = [];
      _selectedDiocese = null;
      _paroissesList = [];
      _selectedParoisse = null;
    });
    try {
      final dioceses = await _dioceseService.fetchDiocesesByPays(paysId);
      if (!mounted) return;
      setState(() {
        _diocesesList = dioceses;
        _isLoadingDioceses = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingDioceses = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur chargement diocèses: $e'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  Future<void> _loadParoisses(int dioceseId) async {
    setState(() {
      _isLoadingParoisses = true;
      _paroissesList = [];
      _selectedParoisse = null;
    });
    try {
      final paroisses = await _paroisseService.fetchParoissesActives();
      if (!mounted) return;
      setState(() {
        _paroissesList = paroisses
            .where((p) => p.dioceseId == dioceseId)
            .toList();
        _isLoadingParoisses = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingParoisses = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur chargement paroisses: $e'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedParoisse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une paroisse')),
      );
      return;
    }
    if (_sacrementsRecus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un sacrement'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _authService.registerParoissien(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        contact: _contactController.text.trim(),
        password: _passwordController.text,
        lieuHabitation: _lieuHabitationController.text,
        passwordConfirmation: _passwordConfirmController.text,
        paroisseId: _selectedParoisse!.id,
        sexe: _selectedSexe!,
        situationMatrimoniale: _selectedSituation!,
        dateNaiss: _dateNaissController.text,
        sacrementsRecus: _sacrementsRecus,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Inscription réussie ! Veuillez vous connecter.'),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur lors de l\'inscription'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _dateNaissController.dispose();
    _lieuHabitationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Inscription Paroissien'),
        centerTitle: true,
        backgroundColor: const Color(0xFF228B22),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: _paysList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: Image.asset(
                          'assets/images/logo/logo1.png',
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Paroisse Smart',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF228B22),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Nom complet
                      TextFormField(
                        controller: _nameController,
                        inputFormatters: [UpperCaseTextFormatter()],
                        decoration: const InputDecoration(
                          labelText: 'Nom et Prénom(s) complet',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Veuillez entrer votre nom'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Veuillez entrer votre email';
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value))
                            return 'Email invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Contact
                      TextFormField(
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Contact',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Veuillez entrer votre contact';
                          if (value.length < 8 || value.length > 15)
                            return 'Le contact doit contenir entre 8 et 15 chiffres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Lieu d'habitation
                      TextFormField(
                        controller: _lieuHabitationController,
                        inputFormatters: [UpperCaseTextFormatter()],
                        decoration: const InputDecoration(
                          labelText: 'Lieu d\'Habitation',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Veuillez entrer votre lieu de résidence'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      // Sexe
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Sexe',
                          prefixIcon: Icon(Icons.wc),
                        ),
                        value: _selectedSexe,
                        items: ['Masculin', 'Féminin']
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedSexe = value),
                        validator: (value) => value == null
                            ? 'Veuillez sélectionner le sexe'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Situation matrimoniale
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Situation matrimoniale',
                          prefixIcon: Icon(Icons.favorite),
                        ),
                        value: _selectedSituation,
                        items:
                            [
                                  'Célibataire',
                                  'Marié(e)',
                                  'Veuf(ve)',
                                  'Divorcé(e)',
                                ]
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedSituation = value),
                        validator: (value) => value == null
                            ? 'Veuillez sélectionner la situation matrimoniale'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Date de naissance
                      TextFormField(
                        controller: _dateNaissController,
                        decoration: const InputDecoration(
                          labelText: 'Date de naissance (YYYY-MM-DD)',
                          prefixIcon: Icon(Icons.cake),
                        ),
                        readOnly: true,
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            _dateNaissController.text = date
                                .toIso8601String()
                                .substring(0, 10);
                          }
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Date de naissance requise'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Sacrements
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Sacrements reçus',
                          prefixIcon: Icon(Icons.fact_check),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              ['Baptême', 'Confirmation', 'Mariage', 'Aucun']
                                  .map(
                                    (s) => CheckboxListTile(
                                      value: _sacrementsRecus.contains(s),
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            if (s == 'Aucun')
                                              _sacrementsRecus.clear();
                                            _sacrementsRecus.add(s);
                                            if (s != 'Aucun')
                                              _sacrementsRecus.remove('Aucun');
                                          } else {
                                            _sacrementsRecus.remove(s);
                                          }
                                        });
                                      },
                                      title: Text(s),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pays
                      DropdownSearch<Pays>(
                        items: _paysList,
                        selectedItem: _selectedPays,
                        itemAsString: (p) => p.nom,
                        onChanged: (p) {
                          setState(() => _selectedPays = p);
                          if (p != null) _loadDioceses(p.id);
                        },
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Pays',
                            prefixIcon: Icon(Icons.flag),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              hintText: 'Rechercher un pays...',
                            ),
                          ),
                        ),
                        validator: (value) => value == null
                            ? 'Veuillez sélectionner un pays'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Diocèse
                      _isLoadingDioceses
                          ? const LinearProgressIndicator()
                          : DropdownSearch<Diocese>(
                              items: _diocesesList,
                              selectedItem: _selectedDiocese,
                              itemAsString: (d) => d.nom,
                              onChanged: (d) {
                                setState(() => _selectedDiocese = d);
                                if (d != null) _loadParoisses(d.id);
                              },
                              dropdownDecoratorProps:
                                  const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      labelText: 'Diocèse',
                                      prefixIcon: Icon(Icons.location_city),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                              popupProps: const PopupProps.menu(
                                showSearchBox: true,
                                searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                    hintText: 'Rechercher un diocèse...',
                                  ),
                                ),
                              ),
                              validator: (value) => value == null
                                  ? 'Veuillez sélectionner un diocèse'
                                  : null,
                            ),
                      const SizedBox(height: 16),

                      // Paroisse
                      _isLoadingParoisses
                          ? const LinearProgressIndicator()
                          : DropdownSearch<Paroisse>(
                              items: _paroissesList,
                              selectedItem: _selectedParoisse,
                              itemAsString: (p) => p.nom,
                              onChanged: (p) =>
                                  setState(() => _selectedParoisse = p),
                              dropdownDecoratorProps:
                                  const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      labelText: 'Paroisse',
                                      prefixIcon: Icon(Icons.church),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                              popupProps: const PopupProps.menu(
                                showSearchBox: true,
                                searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                    hintText: 'Rechercher une paroisse...',
                                  ),
                                ),
                              ),
                              validator: (value) => value == null
                                  ? 'Veuillez sélectionner une paroisse'
                                  : null,
                            ),
                      const SizedBox(height: 16),

                      // Mot de passe
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) => value != null && value.length >= 8
                            ? null
                            : 'Mot de passe trop court (min. 8 caractères)',
                      ),
                      const SizedBox(height: 16),

                      // Confirmation mot de passe
                      TextFormField(
                        controller: _passwordConfirmController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmer mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) => value == _passwordController.text
                            ? null
                            : 'Les mots de passe ne correspondent pas',
                      ),
                      const SizedBox(height: 32),

                      // Bouton d'inscription
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _handleRegister,
                                icon: const Icon(Icons.person_add),
                                label: const Text(
                                  'S\'inscrire',
                                  style: TextStyle(fontSize: 18),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF228B22),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 16),

                      // Lien vers connexion
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Vous avez déjà un compte ? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text(
                              'Connectez-vous ici',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
