import 'package:flutter/material.dart';
import '../../../../services/auth_service.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

 Future<void> _handleLogin() async {
  setState(() => _loading = true);
  final result = await AuthService().login(
    _emailController.text.trim(),
    _passwordController.text.trim(),
  );
  setState(() => _loading = false);

  if (result != null) {
    final user = result['user'];
    final token = result['token'];

    // Pour l'instant, on affiche les infos à l'écran :
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Connecté'),
        content: Text('Bienvenue ${user['name']} 👋\nEmail: ${user['email']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            child: Text('Continuer'),
          ),
        ],
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email ou mot de passe incorrect')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Connexion", style: Theme.of(context).textTheme.headlineMedium),
        SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(labelText: 'Mot de passe'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loading ? null : _handleLogin,
          child: _loading
              ? CircularProgressIndicator(color: Colors.white)
              : Text('Se connecter'),
        )
      ],
    );
  }
}
