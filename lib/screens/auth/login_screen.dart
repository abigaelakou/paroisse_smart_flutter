import 'package:flutter/material.dart';
import 'package:paroisse_smart_flutter/screens/auth/register_paroissien_screen.dart';
import '../../services/auth_service.dart'; 
import '../../navigation/main_scaffold.dart'; 
import 'forgot_password_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

 Future<void> _handleLogin() async {
  setState(() => _isLoading = true);

  final result = await _authService.login(
    _emailController.text.trim(),
    _passwordController.text,
  );

  setState(() => _isLoading = false);

  if (result != null) {
    final token = result['token'];
    final user = result['user'];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainScaffold(
          token: token,
          userName: user.name,
          paroisse: user.paroisseNom ?? '',
           paroisseId: user.paroisseId,
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email ou mot de passe incorrect')),
    );
  }
}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromRGBO(255, 255, 255, 0.984),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo/logo1.png', height: 100),
                const SizedBox(height: 12),
                Text("Bienvenue sur Paroisse Smart",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: const Color.fromRGBO(0, 0, 0, 1))),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                  onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                      );
                    },
                    child: const Text("Mot de passe oublié ?", style: TextStyle(color: const Color.fromRGBO(0, 0, 0, 1))),
                  ),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF228B22),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _handleLogin,
                        child: const Text("Connexion"),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterParoissienScreen()),
                    );
                  },
                  child: const Text("Créer un compte"),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
