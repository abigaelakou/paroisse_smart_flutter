import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'navigation/main_scaffold.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  final authService = AuthService();
  final token = await authService.getToken();
  final userName = await authService.getUserName() ?? '';
  final paroisseNom = await authService.getParoisseNom() ?? '';
  final paroisseId = await authService.getParoisseId();

  if (token != null && paroisseId == null) {
    throw Exception(
      "L'ID de la paroisse est introuvable alors que le token existe.",
    );
  }

  /// Création d'un utilisateur minimal basé sur les données locales
  final user = token != null
      ? User(
          id: 0, // valeur temporaire (sera écrasée après fetchMe)
          name: userName,
          email: '', // inconnu localement → sera mis à jour par fetchMe
          paroisseId: paroisseId ?? 0,
          paroisseNom: paroisseNom,
        )
      : null;

  runApp(MyApp(initialToken: token, initialUser: user));
}

class MyApp extends StatelessWidget {
  final String? initialToken;
  final User? initialUser;

  const MyApp({Key? key, this.initialToken, this.initialUser})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paroisse Smart',
      debugShowCheckedModeBanner: false,

      // ✅ Configuration de la localisation française
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(primarySwatch: Colors.green),
      home: initialToken != null && initialUser != null
          ? MainScaffold(token: initialToken!, user: initialUser!)
          : const LoginScreen(),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
