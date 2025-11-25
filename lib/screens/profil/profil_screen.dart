import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:paroisse_smart_flutter/models/paroisse.dart' as models;

import '../../models/user.dart';
import '../../models/paroisse.dart';
import '../../services/profile_service.dart';
import '../../services/paroisse_service.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String token;
  final int paroisseId;

  const ProfileScreen({
    super.key,
    required this.token,
    required this.paroisseId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileService _profileService;
  final ParoisseService _paroisseService = ParoisseService();

  User? _user;
  bool _isLoading = true;

  List<Paroisse> _paroisses = [];
  bool _isLoadingParoisses = false;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(
      Dio(
        BaseOptions(
          baseUrl: 'https://www.paroissesmart.com/api',
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          },
        ),
      ),
    );
    _loadUser();
    _loadParoisses();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _profileService.fetchUser();
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  Future<void> _loadParoisses() async {
    try {
      setState(() => _isLoadingParoisses = true);
      final paroisses = await _paroisseService.fetchParoissesActives();
      if (!mounted) return;
      setState(() {
        _paroisses = paroisses;
        _isLoadingParoisses = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingParoisses = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement des paroisses: $e')),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 12),
            Text('Déconnexion'),
          ],
        ),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _profileService.logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  void _goToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangePasswordScreen(token: widget.token),
      ),
    );
  }

  void _openEditProfileDialog() {
    if (_user == null || _paroisses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chargement en cours, veuillez patienter...'),
        ),
      );
      return;
    }

    final nameController = TextEditingController(text: _user!.name);
    final lieuHabitationController = TextEditingController(
      text: _user!.lieuHabitation,
    );
    final emailController = TextEditingController(text: _user!.email);
    final contactController = TextEditingController(text: _user!.contact ?? "");
    final dateNaissController = TextEditingController(
      text: _user!.dateNaissance,
    );

    String? sexe = _user!.sexe.isNotEmpty ? _user!.sexe : null;
    String? situation = _user!.situationMatrimoniale.isNotEmpty
        ? _user!.situationMatrimoniale
        : null;
    List<String> sacrements = List.from(_user!.sacrements);

    // Trouver la paroisse actuelle dans la liste
    models.Paroisse? selectedParoisse = _paroisses.firstWhere(
      (p) => p.id == _user!.paroisseId,
      orElse: () => _paroisses.first,
    );

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              const Text("Modifier mes infos"),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nom
                  TextFormField(
                    controller: nameController,
                    inputFormatters: [UpperCaseTextFormatter()],
                    decoration: const InputDecoration(
                      labelText: "Nom et Prénom(s) complet",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Veuillez entrer votre nom'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Veuillez entrer votre email';
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) return 'Email invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Contact
                  TextFormField(
                    controller: contactController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Contact',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(15),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Veuillez entrer votre contact';
                      if (value.length < 8 || value.length > 15) {
                        return 'Le contact doit contenir entre 8 et 15 chiffres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Lieu d'habitation
                  TextFormField(
                    controller: lieuHabitationController,
                    inputFormatters: [UpperCaseTextFormatter()],
                    decoration: const InputDecoration(
                      labelText: "Lieu d'habitation",
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Veuillez entrer votre lieu d\'habitation'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Sexe
                  DropdownButtonFormField<String>(
                    value: sexe,
                    items: ['Masculin', 'Féminin']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setStateDialog(() => sexe = val),
                    decoration: const InputDecoration(
                      labelText: 'Sexe',
                      prefixIcon: Icon(Icons.wc),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null ? 'Veuillez sélectionner le sexe' : null,
                  ),
                  const SizedBox(height: 16),

                  // Situation matrimoniale
                  DropdownButtonFormField<String>(
                    value: situation,
                    items: ['Célibataire', 'Marié(e)', 'Veuf(ve)', 'Divorcé(e)']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setStateDialog(() => situation = val),
                    decoration: const InputDecoration(
                      labelText: 'Situation matrimoniale',
                      prefixIcon: Icon(Icons.favorite),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null
                        ? 'Veuillez sélectionner la situation matrimoniale'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Date de naissance
                  TextFormField(
                    controller: dateNaissController,
                    decoration: const InputDecoration(
                      labelText: 'Date de naissance (YYYY-MM-DD)',
                      prefixIcon: Icon(Icons.cake),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final initial =
                          DateTime.tryParse(dateNaissController.text) ??
                          DateTime(2000);
                      final date = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setStateDialog(() {
                          dateNaissController.text = date
                              .toIso8601String()
                              .substring(0, 10);
                        });
                      }
                    },
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Date de naissance requise'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Sacrements reçus
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Sacrements reçus',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        ...['Baptême', 'Confirmation', 'Mariage', 'Aucun'].map(
                          (s) => CheckboxListTile(
                            value: sacrements.contains(s),
                            onChanged: (val) {
                              setStateDialog(() {
                                if (val == true) {
                                  if (s == 'Aucun') {
                                    sacrements.clear();
                                  }
                                  sacrements.add(s);
                                  if (s != 'Aucun') {
                                    sacrements.remove('Aucun');
                                  }
                                } else {
                                  sacrements.remove(s);
                                }
                              });
                            },
                            title: Text(s),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Paroisse
                  _isLoadingParoisses
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        )
                      : DropdownSearch<models.Paroisse>(
                          items: _paroisses,
                          selectedItem: selectedParoisse,
                          itemAsString: (paroisse) => paroisse.nom,
                          onChanged: (paroisse) =>
                              setStateDialog(() => selectedParoisse = paroisse),
                          dropdownDecoratorProps: const DropDownDecoratorProps(
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
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                          validator: (value) => value == null
                              ? 'Veuillez sélectionner une paroisse'
                              : null,
                        ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (selectedParoisse == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez sélectionner une paroisse'),
                    ),
                  );
                  return;
                }

                try {
                  final message = await _profileService.updateProfile(
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    contact: contactController.text.trim(),
                    lieuHabitation: lieuHabitationController.text.trim(),
                    sexe: sexe ?? "",
                    situation: situation ?? "",
                    dateNaissance: dateNaissController.text.trim(),
                    sacrements: sacrements,
                    paroisseId: selectedParoisse!.id,
                  );

                  if (!mounted) return;
                  Navigator.pop(context);
                  await _loadUser();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text(message)),
                        ],
                      ),
                      backgroundColor: Colors.green.shade600,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red.shade600,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.save),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              label: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        title: const Text(
          'Mon Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUser,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chargement du profil...',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : _user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Utilisateur introuvable',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadUser,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUser,
              color: Colors.blue.shade700,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.blue.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200,
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text(
                              _user!.name.isNotEmpty
                                  ? _user!.name[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _user!.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.email,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _user!.email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Informations personnelles
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Informations personnelles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildInfoTile(
                    "Contact",
                    _user!.contact ?? 'Non défini',
                    Icons.phone,
                    Colors.green,
                  ),
                  _buildInfoTile(
                    "Paroisse",
                    _user!.paroisseNom ?? 'Non définie',
                    Icons.church,
                    Colors.purple,
                  ),
                  if (_user!.sexe.isNotEmpty)
                    _buildInfoTile(
                      "Sexe",
                      _user!.sexe,
                      Icons.wc,
                      Colors.indigo,
                    ),
                  if (_user!.situationMatrimoniale.isNotEmpty)
                    _buildInfoTile(
                      "Situation",
                      _user!.situationMatrimoniale,
                      Icons.favorite,
                      Colors.pink,
                    ),
                  if (_user!.dateNaissance.isNotEmpty)
                    _buildInfoTile(
                      "Date de naissance",
                      _user!.dateNaissance,
                      Icons.cake,
                      Colors.orange,
                    ),
                  if (_user!.sacrements.isNotEmpty)
                    _buildInfoTile(
                      "Sacrements",
                      _user!.sacrements.join(', '),
                      Icons.fact_check,
                      Colors.teal,
                    ),

                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    children: [
                      Icon(Icons.settings, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildActionTile(
                    icon: Icons.edit,
                    iconBg: Colors.blue.shade50,
                    iconColor: Colors.blue.shade700,
                    title: 'Modifier mes infos',
                    subtitle: 'Nom, email, contact, paroisse…',
                    onTap: _openEditProfileDialog,
                  ),

                  const SizedBox(height: 12),

                  _buildActionTile(
                    icon: Icons.lock_reset,
                    iconBg: Colors.orange.shade50,
                    iconColor: Colors.orange.shade700,
                    title: 'Modifier le mot de passe',
                    subtitle: 'Changez votre mot de passe',
                    onTap: _goToChangePassword,
                  ),

                  const SizedBox(height: 12),

                  _buildActionTile(
                    icon: Icons.logout,
                    iconBg: Colors.red.shade50,
                    iconColor: Colors.red.shade700,
                    title: 'Se déconnecter',
                    subtitle: 'Quitter l\'application',
                    onTap: _logout,
                    titleColor: Colors.red,
                  ),

                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Container(
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
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: titleColor ?? Colors.black,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
