import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_paroissien_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profil/profil_screen.dart';
import '../screens/profil/change_password_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
// import '../screens/pain/pain_du_jour_screen.dart';
import '../screens/catechese/confirmation_inscription_screen.dart';


class AppRoutes {
  static const String login = '/login';
  static const String register = '/auth/register-paroissien';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String changePassword = '/change-password';
  static const String forgotPassword = '/forgot-password';
  static const String painDuJour = '/pain-du-jour';
  static const String paiementInscription = '/paiement-inscription';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

        case register:
        return MaterialPageRoute(builder: (_) => const RegisterParoissienScreen());

      case home:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            token: args['token'],
            userName: args['userName'],
            paroisse: args['paroisse'],
          ),
        );

      case profile:
        final token = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(token: token),
        );

      case changePassword:
        final token = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ChangePasswordScreen(token: token),
        );

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      // case painDuJour:
      //   final token = settings.arguments as String;
      //   return MaterialPageRoute(
      //     builder: (_) => PainDuJourScreen(token: token),
      //   );

      case paiementInscription:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ConfirmationInscriptionScreen(
            token: args['token'],
            inscriptionId: args['inscriptionId'],
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(), // fallback sécurisée
        );
    }
  }
}
