import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../services/paroisse_service.dart';
import '../../services/auth_service.dart';
import '../../services/formatters.dart';

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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _selectedSexe;
  String? _selectedSituation;
  List<String> _sacrementsRecus = [];
  Paroisse? _selectedParoisse;
  bool _isLoading = false;
  List<Paroisse> _paroisses = [];

  final ParoisseService _paroisseService = ParoisseService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadParoisses();
  }

  Future<void> _loadParoisses() async {
    try {
      final paroisses = await _paroisseService.fetchParoissesActives();
      setState(() => _paroisses = paroisses);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement paroisses: $e')),
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
        passwordConfirmation: _passwordConfirmController.text,
        paroisseId: _selectedParoisse!.id,
        sexe: _selectedSexe!,
        situationMatrimoniale: _selectedSituation!,
        dateNaiss: _dateNaissController.text,
        sacrementsRecus: _sacrementsRecus,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie ! Veuillez vous connecter.'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'inscription')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
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
          child: _paroisses.isEmpty
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
                        inputFormatters: [
                          UpperCaseTextFormatter(), // ✅ transforme en majuscule
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Nom et Prénom(s) complet',
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
                        decoration: const InputDecoration(labelText: 'Email'),
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
                        decoration: const InputDecoration(labelText: 'Contact'),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Veuillez entrer votre contact';
                          if (!RegExp(r'^\d{8,15}$').hasMatch(value))
                            return 'Contact invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Sexe
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Sexe'),
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

                      // Paroisse
                      DropdownSearch<Paroisse>(
                        items: _paroisses,
                        selectedItem: _selectedParoisse,
                        itemAsString: (paroisse) => paroisse.nom,
                        onChanged: (paroisse) =>
                            setState(() => _selectedParoisse = paroisse),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Paroisse',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        validator: (value) => value == null
                            ? 'Veuillez sélectionner une paroisse'
                            : null,
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              hintText: 'Rechercher une paroisse...',
                            ),
                          ),
                        ),
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
                            : 'Mot de passe trop court',
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
