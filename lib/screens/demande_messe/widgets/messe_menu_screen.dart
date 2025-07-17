import 'package:flutter/material.dart';
import '../faire_demande_screen.dart'; 
import '../mes_demandes_messe_screen.dart';

class MesseTabScreen extends StatelessWidget {
  final String token;
  final String userName;
  final String paroisse;
  final int paroisseId;

  const MesseTabScreen({
    super.key,
    required this.token,
    required this.userName,
    required this.paroisse,
    required this.paroisseId,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Messe"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Faire une demande", icon: Icon(Icons.edit_note)),
              Tab(text: "Mes demandes", icon: Icon(Icons.list_alt)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FaireUneDemandeMesseScreen(
              token: token,
              paroisseId: paroisseId,
              userName: userName,
              paroisse: paroisse,
            ),
            MesDemandesMesseScreen(token: token),
          ],
        ),
      ),
    );
  }
}
