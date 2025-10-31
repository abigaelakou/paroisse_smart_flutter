import 'package:flutter/material.dart';
import '../../models/demande_messe.dart';
import '../../services/demande_messe_service.dart';
import 'widgets/demande_messe_card.dart';

class MesDemandesMesseScreen extends StatefulWidget {
  final String token;

  const MesDemandesMesseScreen({super.key, required this.token});

  @override
  State<MesDemandesMesseScreen> createState() => _MesDemandesMesseScreenState();
}

class _MesDemandesMesseScreenState extends State<MesDemandesMesseScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<DemandeMesse>> _futureDemandes;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _futureDemandes = _chargerDemandes();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<List<DemandeMesse>> _chargerDemandes() async {
    try {
      final data = await DemandeMesseService.fetchMesDemandes(widget.token);
      if (data.isEmpty) return [];
      return data.map((json) => DemandeMesse.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Erreur chargement demandes: $e");
      throw Exception("Impossible de charger vos demandes.");
    }
  }

  Future<void> _refreshDemandes() async {
    setState(() {
      _futureDemandes = _chargerDemandes();
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.deepPurple.shade50, Colors.white],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurple.shade700],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.list_alt,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "Mes Demandes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _refreshDemandes,
                    tooltip: 'Rafraîchir',
                    iconSize: 28,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<DemandeMesse>>(
              future: _futureDemandes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Chargement...",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.red.shade400,
                              size: 60,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Erreur de chargement",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _refreshDemandes,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Réessayer"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refreshDemandes,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 100),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.inbox_outlined,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Aucune demande",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Vous n'avez pas encore de demandes de messe",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final demandes = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: _refreshDemandes,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 16, bottom: 20),
                    itemCount: demandes.length,
                    itemBuilder: (context, index) {
                      return FadeTransition(
                        opacity: _animationController,
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(
                                    index * 0.1,
                                    1.0,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              ),
                          child: DemandeMesseCard(demande: demandes[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
