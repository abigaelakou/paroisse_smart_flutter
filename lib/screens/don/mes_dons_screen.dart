import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String _formatMontant(double montant) {
    final formatter = NumberFormat.decimalPattern("fr_FR");
    return "${formatter.format(montant)} FCFA";
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "validé":
      case "payé":
        return Colors.green;
      case "en attente":
        return Colors.orange;
      case "échoué":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Mes Dons"),
      ),
      body: FutureBuilder<List<Don>>(
        future: _futureDons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(
                    Icons.volunteer_activism,
                    color: Colors.deepPurple,
                  ),
                  title: Text(
                    "Montant : ${_formatMontant(don.montant)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Mode : ${don.modePaiement} \nLe ${don.dateDon}",
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    don.paymentStatus.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(don.paymentStatus),
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
