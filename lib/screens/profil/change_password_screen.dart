import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../services/profile_service.dart';


class ChangePasswordScreen extends StatefulWidget {
  final String token;

  const ChangePasswordScreen({super.key, required this.token});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final ProfileService _profileService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(
      Dio(BaseOptions(
        baseUrl: 'https://a9cb0983460d.ngrok-free.app/api',
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      )),
    );
  }

Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final message = await _profileService.changePassword(
  currentPassword: _currentPasswordController.text,
  newPassword: _newPasswordController.text,
  newPasswordConfirmation: _confirmPasswordController.text,
);


  setState(() => _isLoading = false);

  if (message != null && message.contains("succès")) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    // ✅ Redirection vers l’écran de connexion après succès
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false, arguments: 'Mot de passe modifié avec succès');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? "Erreur inconnue")),
    );
  }
}


  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         automaticallyImplyLeading: false,
        title: const Text("Changer le mot de passe")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe actuel',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Champ requis';
                  } else if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                ),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
