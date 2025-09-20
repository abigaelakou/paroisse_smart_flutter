import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../models/pain_du_jour.dart';
import '../../models/annonce.dart';
import '../../models/evenement.dart';
import '../../services/home_service.dart';
import 'widgets/pain_du_jour_card.dart';
import 'widgets/banniere_spirituelle.dart';
import 'widgets/horizontal_carousel.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final String userName;
  final String paroisse;

  const HomeScreen({
    super.key,
    required this.token,
    required this.userName,
    required this.paroisse,
    required int paroisseId,
    required String userEmail,
    required int userId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeService _homeService;

  PainDuJour? _painDuJour;
  List<Annonce> _annonces = [];
  List<Evenement> _evenements = [];

  bool _isLoading = true;
  bool _isLoadingMoreAnnonces = false;
  bool _isLoadingMoreEvenements = false;

  int _annoncesPage = 1;
  int _evenementsPage = 1;

  final ScrollController _annonceScrollController = ScrollController();
  final ScrollController _evenementScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _homeService = HomeService(
      Dio(
        BaseOptions(
          baseUrl: 'https://www.paroissesmart.com/api',
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          },
        ),
      ),
    );

    _loadData();

    _annonceScrollController.addListener(_loadMoreAnnonces);
    _evenementScrollController.addListener(_loadMoreEvenements);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final pain = await _homeService.fetchPainDuJour();
      final annonces = await _homeService.fetchAnnonces(page: 1);
      final evenements = await _homeService.fetchEvenements(page: 1);

      setState(() {
        _painDuJour = pain;
        _annonces = annonces;
        _evenements = evenements;
        _isLoading = false;
        _annoncesPage = 1;
        _evenementsPage = 1;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur chargement : $e")));
    }
  }

  Future<void> _loadMoreAnnonces() async {
    if (_isLoadingMoreAnnonces ||
        _annonceScrollController.position.pixels >=
            _annonceScrollController.position.maxScrollExtent - 100)
      return;

    setState(() => _isLoadingMoreAnnonces = true);
    _annoncesPage++;
    final more = await _homeService.fetchAnnonces(page: _annoncesPage);
    setState(() {
      _annonces.addAll(more);
      _isLoadingMoreAnnonces = false;
    });
  }

  Future<void> _loadMoreEvenements() async {
    if (_isLoadingMoreEvenements ||
        _evenementScrollController.position.pixels >=
            _evenementScrollController.position.maxScrollExtent - 100)
      return;

    setState(() => _isLoadingMoreEvenements = true);
    _evenementsPage++;
    final more = await _homeService.fetchEvenements(page: _evenementsPage);
    setState(() {
      _evenements.addAll(more);
      _isLoadingMoreEvenements = false;
    });
  }

  String _getDateDuJour() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }

  @override
  void dispose() {
    _annonceScrollController.dispose();
    _evenementScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Accueil"),
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
                  const SizedBox(height: 8),
                  Text(
                    "Bonjour ${widget.userName} 👋",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Paroisse : ${widget.paroisse}",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  Text(
                    _getDateDuJour(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "🙏 Que la paix du Seigneur soit avec vous.",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pain du jour
                  if (_painDuJour != null) ...[
                    Row(
                      children: const [
                        Icon(Icons.book, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          "Pain du jour",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    PainDuJourCard(pain: _painDuJour!),
                    const SizedBox(height: 24),
                  ],

                  // Annonces
                  if (_annonces.isNotEmpty) ...[
                    Row(
                      children: const [
                        Icon(Icons.campaign, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          "Annonces",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    HorizontalCarousel<Annonce>(
                      items: _annonces,
                      controller: _annonceScrollController,
                      onLoadMore: _loadMoreAnnonces,
                      itemBuilder: (context, annonce) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.lightBlue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  annonce.titre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Text(
                                    annonce.contenu,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Événements
                  if (_evenements.isNotEmpty) ...[
                    Row(
                      children: const [
                        Icon(Icons.event, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          "Événements à venir",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    HorizontalCarousel<Evenement>(
                      items: _evenements,
                      controller: _evenementScrollController,
                      onLoadMore: _loadMoreEvenements,
                      autoScroll: true,
                      itemBuilder: (context, evenement) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.green[50],
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  evenement.libelle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "📅 ${evenement.dateEvenement.day}/${evenement.dateEvenement.month}/${evenement.dateEvenement.year} à ${evenement.heureEvenement}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: Text(
                                    evenement.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  if (_annonces.isEmpty &&
                      _evenements.isEmpty &&
                      _painDuJour == null)
                    const Center(
                      child: Text(
                        "Aucun contenu disponible pour le moment.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
