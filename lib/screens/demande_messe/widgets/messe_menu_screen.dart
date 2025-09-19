import 'package:flutter/material.dart';
import '../faire_demande_screen.dart';
import '../mes_demandes_messe_screen.dart';
import '../../../models/user.dart';

class MesseTabScreen extends StatefulWidget {
  final String token;
  final String userName;
  final String paroisse;
  final int paroisseId;
  final int userId;
  final String userEmail;

  const MesseTabScreen({
    super.key,
    required this.token,
    required this.userName,
    required this.paroisse,
    required this.paroisseId,
    required this.userId,
    required this.userEmail,
  });

  @override
  State<MesseTabScreen> createState() => _MesseTabScreenState();
}

class _MesseTabScreenState extends State<MesseTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getIndicatorColor(int index) {
    return _tabController.index == index
        ? Colors.amberAccent
        : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    // Création de l'objet User complet
    final user = User(
      id: widget.userId,
      name: widget.userName,
      email: widget.userEmail,
      paroisseId: widget.paroisseId,
      paroisseNom: widget.paroisse,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Barre de menu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.deepPurple,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _tabController.animateTo(0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _getIndicatorColor(0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.edit_note, color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Text(
                              "Faire une demande",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _tabController.animateTo(1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _getIndicatorColor(1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.list_alt, color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Text(
                              "Mes demandes",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenu des onglets
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Passer l'objet User complet
                  DemandeMesseForm(token: widget.token, user: user),
                  MesDemandesMesseScreen(token: widget.token),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
