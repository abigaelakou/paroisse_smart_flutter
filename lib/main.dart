import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../navigation/main_scaffold.dart'; 
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  final authService = AuthService();
  final token = await authService.getToken();
  final userName = await authService.getUserName() ?? '';
  final paroisseNom = await authService.getParoisseNom() ?? '';
  final paroisseId = await authService.getParoisseId();

  if (token != null && paroisseId == null) {
    throw Exception("L'ID de la paroisse est introuvable alors que le token existe.");
  }

  runApp(MyApp(
    initialToken: token,
    initialUserName: userName,
    initialParoisseNom: paroisseNom,
    initialParoisseId: paroisseId ?? 0, // valeur par défaut au cas où
  ));
}


class MyApp extends StatelessWidget {
  final String? initialToken;
  final String initialUserName;
  final String initialParoisseNom;
  final int initialParoisseId;

  const MyApp({
    Key? key,
    this.initialToken,
    required this.initialUserName,
    required this.initialParoisseNom,
    required this.initialParoisseId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paroisse Smart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: initialToken != null
          ? MainScaffold(
              token: initialToken!,
              userName: initialUserName,
              paroisse: initialParoisseNom,
              paroisseId: initialParoisseId,
            )
          : const LoginScreen(),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}


