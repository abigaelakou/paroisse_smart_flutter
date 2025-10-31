import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:paroisse_smart_flutter/screens/home/widgets/annonce_item.dart';
import 'package:paroisse_smart_flutter/screens/home/widgets/horizontal_carousel.dart';
import '../../models/user.dart';
import '../../models/pain_du_jour.dart';
import '../../models/annonce.dart';
import '../../models/evenement.dart';
import '../../services/home_service.dart';
import 'widgets/pain_du_jour_card.dart';
import 'widgets/banniere_spirituelle.dart';
import 'widgets/annonce_carousel.dart';
import 'widgets/evenement_carousel.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final String userName;
  final String paroisse;

  const HomeScreen({
    super.key,
    required this.token,
    required this.userName,
    required this.paroisse,
    required paroisseId,
    required userId,
    required userEmail,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final HomeService _homeService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

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
      final results = await Future.wait([
        _homeService.fetchPainDuJour(),
        _homeService.fetchAnnonces(page: 1),
        _homeService.fetchEvenements(page: 1),
      ]);

      setState(() {
        _painDuJour = results[0] as PainDuJour?;
        _annonces = results[1] as List<Annonce>;
        _evenements = results[2] as List<Evenement>;
        _isLoading = false;
        _annoncesPage = 1;
        _evenementsPage = 1;
      });

      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur de chargement : $e"),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadMoreAnnonces() async {
    if (_isLoadingMoreAnnonces ||
        !_annonceScrollController.hasClients ||
        _annonceScrollController.position.pixels <
            _annonceScrollController.position.maxScrollExtent - 100) {
      return;
    }

    setState(() => _isLoadingMoreAnnonces = true);
    try {
      _annoncesPage++;
      final more = await _homeService.fetchAnnonces(page: _annoncesPage);
      if (mounted) {
        setState(() {
          _annonces.addAll(more);
          _isLoadingMoreAnnonces = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMoreAnnonces = false);
      }
    }
  }

  Future<void> _loadMoreEvenements() async {
    if (_isLoadingMoreEvenements ||
        !_evenementScrollController.hasClients ||
        _evenementScrollController.position.pixels <
            _evenementScrollController.position.maxScrollExtent - 100) {
      return;
    }

    setState(() => _isLoadingMoreEvenements = true);
    try {
      _evenementsPage++;
      final more = await _homeService.fetchEvenements(page: _evenementsPage);
      if (mounted) {
        setState(() {
          _evenements.addAll(more);
          _isLoadingMoreEvenements = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMoreEvenements = false);
      }
    }
  }

  String _getDateDuJour() {
    final now = DateTime.now();
    final mois = [
      '',
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return "${now.day} ${mois[now.month]} ${now.year}";
  }

  String _getSalutation() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Bonjour";
    if (hour < 18) return "Bon après-midi";
    return "Bonsoir";
  }

  @override
  void dispose() {
    _annonceScrollController.dispose();
    _evenementScrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
    int? count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.9),
              ),
            ),
          ),
          if (count != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        title: const Text(
          "Accueil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _animationController.reset();
              _loadData();
            },
            tooltip: "Rafraîchir",
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Chargement des données...",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                _animationController.reset();
                await _loadData();
              },
              color: Colors.green.shade700,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // Bannière spirituelle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BanniereSpirituelle(
                        citation:
                            "« Là où deux ou trois sont réunis en mon nom, je suis au milieu d'eux. » - Matthieu 18:20",
                      ),
                    ),

                    // En-tête de bienvenue
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade700,
                            Colors.green.shade500,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade200,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${_getSalutation()} ${widget.userName} 👋",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.church,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.paroisse,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getDateDuJour(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("🙏", style: TextStyle(fontSize: 16)),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "Que la paix du Seigneur soit avec vous",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Pain du jour
                    if (_painDuJour != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildSectionHeader(
                          title: "Pain du jour",
                          icon: Icons.book_rounded,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: PainDuJourCard(pain: _painDuJour!),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Annonces
                    if (_annonces.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildSectionHeader(
                          title: "Annonces",
                          icon: Icons.campaign_rounded,
                          color: Colors.blue.shade700,
                          count: _annonces.length,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: HorizontalCarousel<Annonce>(
                          items: _annonces,
                          controller: _annonceScrollController,
                          onLoadMore: _loadMoreAnnonces,
                          itemBuilder: (context, annonce) =>
                              AnnonceItem(annonce: annonce),
                          height: 180,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Événements
                    if (_evenements.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildSectionHeader(
                          title: "Événements à venir",
                          icon: Icons.event_rounded,
                          color: Colors.orange.shade700,
                          count: _evenements.length,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: EvenementCarousel(evenements: _evenements),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // État vide
                    if (_annonces.isEmpty &&
                        _evenements.isEmpty &&
                        _painDuJour == null)
                      Container(
                        margin: const EdgeInsets.all(32),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Aucun contenu disponible",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Revenez plus tard pour découvrir de nouvelles actualités",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
