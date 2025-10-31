import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/paiement_catechese.dart';
import '../../../services/catechese_service.dart';
import 'recu_pdf_screen.dart';

class ListePaiementsCatecheseScreen extends StatefulWidget {
  final String token;
  final int paroisseId;

  const ListePaiementsCatecheseScreen({
    super.key,
    required this.token,
    required this.paroisseId,
  });

  @override
  State<ListePaiementsCatecheseScreen> createState() =>
      _ListePaiementsCatecheseScreenState();
}

class _ListePaiementsCatecheseScreenState
    extends State<ListePaiementsCatecheseScreen> {
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
      result.sort((a, b) => b.dateInscription.compareTo(a.dateInscription));
      setState(() => _paiements = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur : ${e.toString()}")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _ouvrirRecu(String recuUrl) {
    final fullUrl = recuUrl.startsWith('http')
        ? recuUrl
        : 'https://paroissesmart.com$recuUrl';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecuPdfScreen(
          url: fullUrl,
          token: widget.token,
          paroisseId: widget.paroisseId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.payment, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              "Mes paiements catéchèse",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Rafraîchir la liste',
            onPressed: _loadPaiements,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _paiements.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.green.shade300,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Aucun paiement trouvé",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Vos paiements apparaîtront ici",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPaiements,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _paiements.length,
                    itemBuilder: (context, index) {
                      final p = _paiements[index];
                      final statutPayer = p.statut.toLowerCase() == 'payé';
                      final nom = p.nomCatechumene.isNotEmpty
                          ? p.nomCatechumene
                          : "Inconnu";
                      final niveau = p.niveau.isNotEmpty
                          ? p.niveau
                          : "Niveau N/A";
                      final session = p.session.isNotEmpty
                          ? p.session
                          : "Session N/A";

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 400 + (index * 80)),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, (1 - value) * 20),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: statutPayer
                                  ? [Colors.white, Colors.green.shade50]
                                  : [Colors.white, Colors.orange.shade50],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: statutPayer
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.orange.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: statutPayer
                                              ? [
                                                  Colors.green.shade400,
                                                  Colors.green.shade600,
                                                ]
                                              : [
                                                  Colors.orange.shade400,
                                                  Colors.orange.shade600,
                                                ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: statutPayer
                                                ? Colors.green.withOpacity(0.3)
                                                : Colors.orange.withOpacity(
                                                    0.3,
                                                  ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        statutPayer
                                            ? Icons.check_circle
                                            : Icons.pending_outlined,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nom,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: statutPayer
                                                    ? [
                                                        Colors.green.shade600,
                                                        Colors.green.shade700,
                                                      ]
                                                    : [
                                                        Colors.orange.shade600,
                                                        Colors.orange.shade700,
                                                      ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: statutPayer
                                                      ? Colors.green
                                                            .withOpacity(0.3)
                                                      : Colors.orange
                                                            .withOpacity(0.3),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              p.statut,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildInfoRow(
                                        Icons.school,
                                        Colors.blue,
                                        "Niveau",
                                        niveau,
                                      ),
                                      const Divider(height: 16),
                                      _buildInfoRow(
                                        Icons.calendar_today,
                                        Colors.purple,
                                        "Session",
                                        session,
                                      ),
                                      const Divider(height: 16),
                                      _buildInfoRow(
                                        Icons.event,
                                        Colors.teal,
                                        "Date",
                                        _formatter.format(p.dateInscription),
                                      ),
                                      const Divider(height: 16),
                                      _buildInfoRow(
                                        Icons.attach_money,
                                        Colors.green,
                                        "Montant",
                                        "${p.montant.toStringAsFixed(0)} FCFA",
                                      ),
                                    ],
                                  ),
                                ),
                                if (statutPayer &&
                                    p.recuUrl != null &&
                                    p.recuUrl!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: InkWell(
                                      onTap: () => _ouvrirRecu(p.recuUrl!),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.blue.shade600,
                                              Colors.blue.shade700,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.picture_as_pdf,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Télécharger le reçu",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, Color color, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
