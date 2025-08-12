import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://www.paroissesmart.com/api', 
    headers: {'Accept': 'application/json'},
  ));

  bool _isLoading = false;
  String? _feedback;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _feedback = null;
    });

    try {
      final response = await _dio.post('/forgot_password', data: {
        'email': _emailController.text.trim(),
      });

      setState(() {
        _feedback = "Un lien de réinitialisation a été envoyé à votre adresse email.";
      });
    } catch (e) {
      setState(() {
        _feedback = "Erreur : impossible d’envoyer l’email.";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mot de passe oublié"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Entrez votre adresse email pour recevoir un lien de réinitialisation.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF228B22),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text("Envoyer"),
                  ),
            if (_feedback != null) ...[
              const SizedBox(height: 24),
              Text(
                _feedback!,
                style: TextStyle(color: _feedback!.startsWith("Erreur") ? Colors.red : Colors.green),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
