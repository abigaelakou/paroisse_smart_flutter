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

class _MesDemandesMesseScreenState extends State<MesDemandesMesseScreen> {
  late Future<List<DemandeMesse>> _futureDemandes;

  @override
  void initState() {
    super.initState();
    _futureDemandes = _chargerDemandes();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Mes Demandes de Messe"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDemandes,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: FutureBuilder<List<DemandeMesse>>(
        future: _futureDemandes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Erreur : ${snapshot.error}"),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _refreshDemandes,
                    child: const Text("Réessayer"),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshDemandes,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text("Aucune demande enregistrée.")),
                ],
              ),
            );
          }

          final demandes = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshDemandes,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: demandes.length,
              itemBuilder: (context, index) {
                final demande = demandes[index];
                return DemandeMesseCard(demande: demande);
              },
            ),
          );
        },
      ),
    );
  }
}
