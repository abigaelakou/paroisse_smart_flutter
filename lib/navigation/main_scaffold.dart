import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/profil/profil_screen.dart';
import '../screens/don/faire_un_don_screen.dart';
import '../screens/demande_messe/widgets/messe_menu_screen.dart';
import '../screens/catechese/widgets/catechese_menu_screen.dart';
import '../services/auth_service.dart';

class MainScaffold extends StatefulWidget {
  final String token;
  final String userName;
  final String paroisse;
  final int paroisseId;

  const MainScaffold({
    Key? key,
    required this.token,
    required this.userName,
    required this.paroisse,
    required this.paroisseId,
  }) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late String _userName;
  late String _paroisse;
  late int _paroisseId;
  final AuthService _authService = AuthService();

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _paroisse = widget.paroisse;
    _paroisseId = widget.paroisseId;

    // Appel non async ici, on déclenche la future sans attendre
    _syncUserData();
  }

  Future<void> _syncUserData() async {
    final user = await _authService.fetchMe(widget.token);
    if (user != null) {
      if (user.name != _userName) {
        setState(() => _userName = user.name);
        await _authService.setUserName(user.name);
      }
      if ((user.paroisseNom ?? '') != _paroisse) {
        setState(() => _paroisse = user.paroisseNom ?? '');
        await _authService.setParoisseNom(user.paroisseNom ?? '');
      }
      if (user.paroisseId != _paroisseId) {
        setState(() => _paroisseId = user.paroisseId);
        await _authService.setParoisseId(user.paroisseId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        token: widget.token,
        userName: _userName,
        paroisse: _paroisse,
      ),
      FaireUnDonScreen(
        token: widget.token,
        paroisseId: _paroisseId,
      ),
      MesseTabScreen(
        token: widget.token,
        userName: _userName,
        paroisse: _paroisse,
        paroisseId: _paroisseId,
      ),
      CatecheseMenuScreen(
        token: widget.token,
        paroisseId: _paroisseId,
      ),
      ProfileScreen(token: widget.token),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Paroisse Smart"),
            Image.asset(
              'assets/images/logo/logo1.png',
              height: 28,
            ),
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
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'Don'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Messe'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Catéchèse'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
