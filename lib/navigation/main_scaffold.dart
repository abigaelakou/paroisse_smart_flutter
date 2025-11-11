import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/profil/profil_screen.dart';
import '../screens/don/faire_un_don_screen.dart';
import '../screens/demande_messe/widgets/messe_menu_screen.dart';
import '../screens/catechese/widgets/catechese_menu_screen.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class MainScaffold extends StatefulWidget {
  final String token;
  final User user;
  final int initialIndex;

  const MainScaffold({
    Key? key,
    required this.token,
    required this.user,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late User _currentUser;
  final AuthService _authService = AuthService();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _currentIndex = widget.initialIndex;
    _syncUserData();
  }

  /// Synchronise les données utilisateur avec l'API `/me`
  Future<void> _syncUserData() async {
    try {
      final updatedUser = await _authService.fetchMe();
      setState(() => _currentUser = updatedUser);

      // Mise à jour locale (SharedPreferences)
      await _authService.setUserName(updatedUser.name);
      await _authService.setParoisseNom(updatedUser.paroisseNom ?? '');
      await _authService.setParoisseId(updatedUser.paroisseId);
    } catch (e) {
      debugPrint("❌ Erreur lors de la synchro user : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        token: widget.token,
        userName: _currentUser.name,
        paroisse: _currentUser.paroisseNom ?? '',
        paroisseId: _currentUser.paroisseId,
        userId: _currentUser.id,
        userEmail: _currentUser.email,
      ),
      FaireUnDonScreen(
        token: widget.token,
        paroisseId: _currentUser.paroisseId,
        user: _currentUser,
      ),
      MesseTabScreen(
        token: widget.token,
        userName: _currentUser.name,
        paroisse: _currentUser.paroisseNom ?? '',
        paroisseId: _currentUser.paroisseId,
        userId: _currentUser.id,
        userEmail: _currentUser.email,
      ),
      CatecheseMenuScreen(
        token: widget.token,
        paroisseId: _currentUser.paroisseId,
        user: _currentUser,
      ),

      ProfileScreen(token: widget.token, paroisseId: _currentUser.paroisseId),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Paroisse Smart"),
            Image.asset('assets/images/logo/logo1.png', height: 28),
          ],
        ),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Don',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Messe'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Catéchèse'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
