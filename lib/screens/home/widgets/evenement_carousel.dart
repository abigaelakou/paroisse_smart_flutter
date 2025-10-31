import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/evenement.dart';
import 'evenement_item.dart';

class EvenementCarousel extends StatefulWidget {
  final List<Evenement> evenements;

  const EvenementCarousel({super.key, required this.evenements});

  @override
  State<EvenementCarousel> createState() => _EvenementCarouselState();
}

class _EvenementCarouselState extends State<EvenementCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  late final List<Evenement> _items;
  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _items = widget.evenements;
    _pageController = PageController(viewportFraction: 0.90, initialPage: 0);

    // Auto-scroll uniquement s'il y a plusieurs événements
    if (_items.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_isUserInteracting && mounted && _pageController.hasClients) {
        _autoScroll();
      }
    });
  }

  void _autoScroll() {
    if (!mounted || _items.isEmpty || !_pageController.hasClients) return;

    final nextPage = (_currentPage + 1) % _items.length;

    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onUserInteractionStart() {
    setState(() => _isUserInteracting = true);
    _autoScrollTimer?.cancel();
  }

  void _onUserInteractionEnd() {
    setState(() => _isUserInteracting = false);
    // Redémarre l'auto-scroll après 5 secondes d'inactivité
    if (_items.length > 1) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && !_isUserInteracting) {
          _startAutoScroll();
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Carousel d'événements
        GestureDetector(
          onPanDown: (_) => _onUserInteractionStart(),
          onPanEnd: (_) => _onUserInteractionEnd(),
          onPanCancel: () => _onUserInteractionEnd(),
          child: SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _items.length,
              onPageChanged: (index) {
                if (mounted) {
                  setState(() => _currentPage = index);
                }
              },
              itemBuilder: (context, index) {
                // Effet de parallaxe/scale basé sur la position
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
                    }
                    return Center(
                      child: SizedBox(
                        height: Curves.easeOut.transform(value) * 220,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: EvenementItem(evenement: _items[index]),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Indicateurs de page avec design amélioré
        if (_items.length > 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bouton précédent (si plus d'un élément)
                if (_items.length > 1)
                  GestureDetector(
                    onTap: () {
                      _onUserInteractionStart();
                      final prevPage =
                          (_currentPage - 1 + _items.length) % _items.length;
                      _pageController.animateToPage(
                        prevPage,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                      _onUserInteractionEnd();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                    ),
                  ),

                const SizedBox(width: 8),

                // Indicateurs de points
                ...List.generate(_items.length > 5 ? 5 : _items.length, (
                  index,
                ) {
                  // Si plus de 5 éléments, afficher uniquement 5 points avec logique intelligente
                  final displayIndex = _items.length > 5
                      ? _calculateDisplayIndex(
                          index,
                          _currentPage,
                          _items.length,
                        )
                      : index;

                  final isActive = displayIndex == _currentPage;

                  return GestureDetector(
                    onTap: () {
                      _onUserInteractionStart();
                      _pageController.animateToPage(
                        displayIndex,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                      _onUserInteractionEnd();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.orange.shade700
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),

                const SizedBox(width: 8),

                // Bouton suivant
                if (_items.length > 1)
                  GestureDetector(
                    onTap: () {
                      _onUserInteractionStart();
                      final nextPage = (_currentPage + 1) % _items.length;
                      _pageController.animateToPage(
                        nextPage,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                      _onUserInteractionEnd();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                    ),
                  ),

                const SizedBox(width: 4),

                // Compteur (ex: 1/5)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentPage + 1}/${_items.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Calcule l'index à afficher pour les indicateurs de points intelligents
  int _calculateDisplayIndex(int dotIndex, int currentPage, int totalItems) {
    if (totalItems <= 5) return dotIndex;

    // Afficher les points autour de la page actuelle
    if (currentPage < 2) {
      return dotIndex;
    } else if (currentPage > totalItems - 3) {
      return totalItems - 5 + dotIndex;
    } else {
      return currentPage - 2 + dotIndex;
    }
  }
}
