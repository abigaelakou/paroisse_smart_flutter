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
    final data = await DemandeMesseService.fetchMesDemandes(widget.token);
    return data.map((json) => DemandeMesse.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Mes Demandes de Messe")),
      body: FutureBuilder<List<DemandeMesse>>(
        future: _futureDemandes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune demande enregistrée."));
          }

          final demandes = snapshot.data!;
          return ListView.builder(
            itemCount: demandes.length,
            itemBuilder: (context, index) {
              return DemandeMesseCard(demande: demandes[index]);
            },
          );
        },
      ),
    );
  }
}
