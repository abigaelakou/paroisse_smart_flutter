import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../models/pain_du_jour.dart';
import '../../models/annonce.dart';
import '../../models/evenement.dart';
import '../../services/home_service.dart';

import 'widgets/annonce_carousel.dart';
import 'widgets/evenement_carousel.dart';
import 'widgets/pain_du_jour_card.dart';
import 'widgets/banniere_spirituelle.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final String userName;
  final String paroisse;

  const HomeScreen({
    Key? key,
    required this.token,
    required this.userName,
    required this.paroisse,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeService _homeService;

  PainDuJour? _painDuJour;
  List<Annonce> _annonces = [];
  List<Evenement> _evenements = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _homeService = HomeService(Dio(BaseOptions(
      baseUrl: 'https://a9cb0983460d.ngrok-free.app/api',
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    )));
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final pain = await _homeService.fetchPainDuJour();
    final annonces = await _homeService.fetchAnnonces();
    final evenements = await _homeService.fetchEvenements();

    setState(() {
      _painDuJour = pain;
      _annonces = annonces;
      _evenements = evenements;
      _isLoading = false;
    });
  }

  String _getDateDuJour() {
    final now = DateTime.now();
    final formatter = DateFormat("EEEE d MMMM yyyy", "fr_FR");
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Accueil"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: "Rafraîchir",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const BanniereSpirituelle(
                    citation:
                        "« Là où deux ou trois sont réunis en mon nom, je suis au milieu d’eux. » - Matthieu 18:20",
                  ),
                  Text(
                    "Bonjour ${widget.userName} 👋",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text("Paroisse : ${widget.paroisse}",
                      style: const TextStyle(color: Colors.black87)),
                  Text(
                    _getDateDuJour(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "🙏 Que la paix du Seigneur soit avec vous.",
                    style:
                        TextStyle(fontStyle: FontStyle.italic, color: Colors.green),
                  ),
                  const SizedBox(height: 24),

                  /// Pain du jour
                  if (_painDuJour != null) ...[
                    Row(
                      children: const [
                        Icon(Icons.book, color: Colors.green),
                        SizedBox(width: 8),
                        Text("Pain du jour",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    PainDuJourCard(pain: _painDuJour!),
                    const SizedBox(height: 24),
                  ],

                  /// Annonces
                  if (_annonces.isNotEmpty) ...[
                    Row(
                      children: const [
                        Icon(Icons.campaign, color: Colors.blue),
                        SizedBox(width: 8),
                        Text("Annonces",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnnonceCarousel(annonces: _annonces),
                    const SizedBox(height: 24),
                  ],

                  /// Événements
                  if (_evenements.isNotEmpty) ...[
                    Row(
                      children: const [
                        Icon(Icons.event, color: Colors.orange),
                        SizedBox(width: 8),
                        Text("Événements à venir",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    EvenementCarousel(evenements: _evenements),
                  ],
                ],
              ),
            ),
    );
  }
}
