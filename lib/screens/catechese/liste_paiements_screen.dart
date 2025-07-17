import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/paiement_catechese.dart';
import '../../../services/catechese_service.dart';

class ListePaiementsCatecheseScreen extends StatefulWidget {
  final String token;

  const ListePaiementsCatecheseScreen({super.key, required this.token});

  @override
  State<ListePaiementsCatecheseScreen> createState() => _ListePaiementsCatecheseScreenState();
}

class _ListePaiementsCatecheseScreenState extends State<ListePaiementsCatecheseScreen> {
  List<PaiementCatechese> _paiements = [];
  bool _isLoading = true;
  late final CatecheseService _service;

  final _formatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _service = CatecheseService(token: widget.token);
    _loadPaiements();
  }

  Future<void> _loadPaiements() async {
    setState(() => _isLoading = true);
    try {
      final result = await _service.fetchPaiements();
      setState(() => _paiements = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes paiements catéchèse"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPaiements,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _paiements.isEmpty
              ? const Center(child: Text("Aucun paiement trouvé."))
              : ListView.builder(
                  itemCount: _paiements.length,
                  itemBuilder: (context, index) {
                    final p = _paiements[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(p.nomCatechumene),
                        subtitle: Text(
                          "${p.niveau} • ${p.session}\n"
                          "Date : ${_formatter.format(p.dateInscription)}\n"
                          "Montant : ${p.montant.toStringAsFixed(0)} FCFA",
                        ),
                        trailing: Chip(
                          label: Text(
                            p.statut,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: p.statut == 'Payé' ? Colors.green : Colors.orange,
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
