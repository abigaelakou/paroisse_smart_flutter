import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://www.paroissesmart.com/api',
      headers: {'Accept': 'application/json'},
    ),
  );

  bool _isLoading = false;
  String? _feedback;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _feedback = "Veuillez entrer votre email.");
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _feedback = "Email invalide.");
      return;
    }

    setState(() {
      _isLoading = true;
      _feedback = null;
    });

    try {
      final response = await _dio.post(
        '/forgot_password',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        setState(
          () => _feedback =
              "✅ Un lien de réinitialisation a été envoyé à votre adresse email.",
        );
      } else {
        setState(() => _feedback = "❌ Erreur : impossible d’envoyer l’email.");
      }
    } on DioException catch (e) {
      setState(() {
        _feedback =
            e.response?.data['message'] ??
            "❌ Erreur réseau : impossible d’envoyer l’email.";
      });
    } catch (e) {
      setState(() => _feedback = "❌ Erreur inattendue : $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mot de passe oublié"),
          backgroundColor: const Color(0xFF228B22),
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
                  : SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF228B22),
                        ),
                        child: const Text("Envoyer"),
                      ),
                    ),
              if (_feedback != null) ...[
                const SizedBox(height: 24),
                Text(
                  _feedback!,
                  style: TextStyle(
                    color: _feedback!.startsWith("❌")
                        ? Colors.red
                        : Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
