import 'package:flutter/material.dart';
import '../../models/don.dart';
import '../../services/don_service.dart';

class MesDonsScreen extends StatefulWidget {
  final String token;

  const MesDonsScreen({super.key, required this.token});

  @override
  State<MesDonsScreen> createState() => _MesDonsScreenState();
}

class _MesDonsScreenState extends State<MesDonsScreen> {
  late Future<List<Don>> _futureDons;

  @override
  void initState() {
    super.initState();
    _futureDons = DonService.fetchMesDons(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         automaticallyImplyLeading: false,
        title: const Text("Mes Dons")),
      body: FutureBuilder<List<Don>>(
        future: _futureDons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun don enregistré."));
          }

          final dons = snapshot.data!;
          return ListView.builder(
            itemCount: dons.length,
            itemBuilder: (context, index) {
              final don = dons[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text("Montant : ${don.montant.toStringAsFixed(0)} FCFA"),
                  subtitle: Text("Mode : ${don.modePaiement} | ${don.dateDon}"),
                  trailing: Text(
                    don.paymentStatus.toUpperCase(),
                    style: TextStyle(
                      color: don.paymentStatus == "validé"
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
