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
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        index: 0,
                        icon: Icons.edit_note,
                        label: "Faire une demande",
                        isSelected: _tabController.index == 0,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade200,
                    ),
                    Expanded(
                      child: _buildTabButton(
                        index: 1,
                        icon: Icons.list_alt,
                        label: "Mes demandes",
                        isSelected: _tabController.index == 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
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

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Colors.deepPurple, Colors.deepPurple.shade700],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 22,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
