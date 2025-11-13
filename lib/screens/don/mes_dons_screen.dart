import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/don.dart';
import '../../services/don_service.dart';
import './widgets/don_card.dart';

class MesDonsScreen extends StatefulWidget {
  final String token;

  const MesDonsScreen({super.key, required this.token});

  @override
  State<MesDonsScreen> createState() => _MesDonsScreenState();
}

class _MesDonsScreenState extends State<MesDonsScreen> {
  late Future<List<Don>> _futureDons;
  String _filtreStatut = 'Tous';
  String _triOption = 'Date (récent)';

  final List<String> _statutsFiltre = [
    'Tous',
    'Validé',
    'Payé',
    'En attente',
    'Échoué',
  ];

  final List<String> _optionsTri = [
    'Date (récent)',
    'Date (ancien)',
    'Montant (croissant)',
    'Montant (décroissant)',
  ];

  @override
  void initState() {
    super.initState();
    _futureDons = DonService.fetchMesDons(widget.token);
  }

  void _rafraichir() {
    setState(() {
      _futureDons = DonService.fetchMesDons(widget.token);
    });
  }

  List<Don> _filtrerEtTrier(List<Don> dons) {
    // Filtrer par statut
    List<Don> donsFiltres = dons;
    if (_filtreStatut != 'Tous') {
      donsFiltres = dons
          .where(
            (don) =>
                don.paymentStatus.toLowerCase() == _filtreStatut.toLowerCase(),
          )
          .toList();
    }

    // Trier
    switch (_triOption) {
      case 'Date (récent)':
        donsFiltres.sort((a, b) => b.dateDon.compareTo(a.dateDon));
        break;
      case 'Date (ancien)':
        donsFiltres.sort((a, b) => a.dateDon.compareTo(b.dateDon));
        break;
      case 'Montant (croissant)':
        donsFiltres.sort((a, b) => a.montant.compareTo(b.montant));
        break;
      case 'Montant (décroissant)':
        donsFiltres.sort((a, b) => b.montant.compareTo(a.montant));
        break;
    }

    return donsFiltres;
  }

  String _formatMontant(double montant) {
    final formatter = NumberFormat.decimalPattern("fr_FR");
    return "${formatter.format(montant)} FCFA";
  }

  double _calculerTotal(List<Don> dons) {
    return dons.fold(0.0, (sum, don) => sum + don.montant);
  }

  Map<String, int> _calculerStatistiques(List<Don> dons) {
    return {
      'total': dons.length,
      'valides': dons
          .where(
            (d) =>
                d.paymentStatus.toLowerCase() == 'validé' ||
                d.paymentStatus.toLowerCase() == 'payé',
          )
          .length,
      'attente': dons
          .where((d) => d.paymentStatus.toLowerCase() == 'en attente')
          .length,
      'echoues': dons
          .where((d) => d.paymentStatus.toLowerCase() == 'échoué')
          .length,
    };
  }

  void _afficherFiltres() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filtres et tri",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Filtre par statut
                  const Text(
                    "Statut du paiement",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _statutsFiltre.map((statut) {
                      final isSelected = _filtreStatut == statut;
                      return FilterChip(
                        label: Text(statut),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            setState(() {
                              _filtreStatut = statut;
                            });
                          });
                        },
                        selectedColor: Colors.amber.shade700,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Options de tri
                  const Text(
                    "Trier par",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._optionsTri.map((option) {
                    final isSelected = _triOption == option;
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: _triOption,
                      activeColor: Colors.amber.shade700,
                      selected: isSelected,
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            setState(() {
                              _triOption = value;
                            });
                          });
                        }
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),

                  const SizedBox(height: 16),

                  // Bouton appliquer
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Appliquer",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.amber.shade700,
        title: const Text(
          "Mes Dons",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _afficherFiltres,
            tooltip: "Filtres",
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _rafraichir,
            tooltip: "Rafraîchir",
          ),
        ],
      ),
      body: FutureBuilder<List<Don>>(
        future: _futureDons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.amber.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Chargement de vos dons...",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Erreur de chargement",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${snapshot.error}",
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _rafraichir,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Réessayer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.volunteer_activism,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Aucun don enregistré",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Vos dons apparaîtront ici",
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            );
          }

          final tousDons = snapshot.data!;
          final donsFiltres = _filtrerEtTrier(tousDons);
          final total = _calculerTotal(donsFiltres);
          final stats = _calculerStatistiques(tousDons);

          return Column(
            children: [
              // Statistiques en haut
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade700, Colors.amber.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total de vos dons",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatMontant(total),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.volunteer_activism,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white38),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatChip(
                          label: "Total",
                          value: "${stats['total']}",
                          icon: Icons.receipt_long,
                        ),
                        _buildStatChip(
                          label: "Validés",
                          value: "${stats['valides']}",
                          icon: Icons.check_circle,
                        ),
                        _buildStatChip(
                          label: "En attente",
                          value: "${stats['attente']}",
                          icon: Icons.pending,
                        ),
                        _buildStatChip(
                          label: "Échoués",
                          value: "${stats['echoues']}",
                          icon: Icons.error,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Indicateur de filtre actif
              if (_filtreStatut != 'Tous' || _triOption != 'Date (récent)')
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt,
                        size: 20,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Filtré: $_filtreStatut • Trié: $_triOption",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _filtreStatut = 'Tous';
                            _triOption = 'Date (récent)';
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Réinitialiser",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_filtreStatut != 'Tous' || _triOption != 'Date (récent)')
                const SizedBox(height: 12),

              // Liste des dons
              Expanded(
                child: donsFiltres.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Aucun don trouvé",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Essayez de modifier vos filtres",
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _filtreStatut = 'Tous';
                                    _triOption = 'Date (récent)';
                                  });
                                },
                                icon: const Icon(Icons.clear_all),
                                label: const Text("Réinitialiser les filtres"),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _rafraichir(),
                        color: Colors.amber.shade700,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: donsFiltres.length,
                          itemBuilder: (context, index) {
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(
                                milliseconds: 300 + (index * 50),
                              ),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: DonCard(don: donsFiltres[index]),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
