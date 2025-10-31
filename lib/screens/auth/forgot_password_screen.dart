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
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

    if (email.isEmpty) {
      setState(() => _feedback = "Veuillez entrer votre email.");
      return;
    }
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
      setState(() {
        _feedback = response.statusCode == 200
            ? "✅ Un lien de réinitialisation a été envoyé à votre adresse email."
            : "❌ Erreur : impossible d’envoyer l’email.";
      });
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
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mot de passe oublié"),
          backgroundColor: Colors.green.shade700,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.email_outlined, size: 48, color: Colors.green),
              const SizedBox(height: 12),
              const Text(
                "Entrez votre adresse email pour recevoir un lien de réinitialisation.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: const Icon(Icons.send),
                  label: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Envoyer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
                    fontWeight: FontWeight.w500,
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
