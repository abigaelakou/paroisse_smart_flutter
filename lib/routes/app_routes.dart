import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_paroissien_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profil/profil_screen.dart';
import '../screens/profil/change_password_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/catechese/confirmation_inscription_screen.dart';
import '../models/user.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/auth/register-paroissien';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String changePassword = '/change-password';
  static const String forgotPassword = '/forgot-password';
  static const String paiementInscription = '/paiement-inscription';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterParoissienScreen(),
        );

      case home:
        final args = settings.arguments as Map<String, dynamic>?;
        final token = args?['token'] ?? '';
        final userName = args?['userName'] ?? 'Fidèle';
        final paroisse = args?['paroisse'] ?? '';
        final paroisseId = args?['paroisseId'] ?? 0;
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            token: token,
            userName: userName,
            paroisse: paroisse,
            paroisseId: paroisseId,
            userId: args?['userId'] ?? 0,
            userEmail: args?['userEmail'] ?? '',
          ),
        );
      case profile:
        final args = settings.arguments as Map<String, dynamic>?;
        final token = args?['token'] ?? '';
        final paroisseId = args?['paroisseId'] ?? 0;
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(token: token, paroisseId: paroisseId),
        );

      case changePassword:
        final args = settings.arguments as Map<String, dynamic>?;
        final token = args?['token'] ?? '';
        return MaterialPageRoute(
          builder: (_) => ChangePasswordScreen(token: token),
        );

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case paiementInscription:
        final args = settings.arguments as Map<String, dynamic>?;
        final token = args?['token'] ?? '';
        final inscriptionId = args?['inscriptionId'] ?? 0;
        final paroisseId = args?['paroisseId'] ?? 0;
        final user = args?['user'] as User;
        return MaterialPageRoute(
          builder: (_) => ConfirmationInscriptionScreen(
            token: token,
            inscriptionId: inscriptionId,
            paroisseId: paroisseId,
            user: user,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(), // fallback sécurisé
        );
    }
  }
}
