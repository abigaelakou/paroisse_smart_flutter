import 'package:flutter/material.dart';
import '../../../models/evenement.dart';
import 'package:intl/intl.dart';

class EvenementCarousel extends StatefulWidget {
  final List<Evenement>? evenements;
  final Evenement? singleEvenement;

  const EvenementCarousel({super.key, this.evenements, this.singleEvenement});

  factory EvenementCarousel.singleItem({required Evenement evenement}) {
    return EvenementCarousel(singleEvenement: evenement);
  }

  @override
  State<EvenementCarousel> createState() => _EvenementCarouselState();
}

class _EvenementCarouselState extends State<EvenementCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  late final List<Evenement> _items;

  @override
  void initState() {
    super.initState();
    _items =
        widget.evenements ??
        (widget.singleEvenement != null ? [widget.singleEvenement!] : []);
    _pageController = PageController(viewportFraction: 0.8);

    if (_items.length > 1) {
      Future.delayed(const Duration(seconds: 3), _autoScroll);
    }
  }

  void _autoScroll() {
    if (!mounted || _items.isEmpty) return;

    _currentPage = (_currentPage + 1) % _items.length;
    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(seconds: 3), _autoScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();

    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final evenement = _items[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
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
                          "📅 ${dateFormat.format(evenement.dateEvenement)} à ${evenement.heureEvenement}",
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
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _items.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 12 : 8,
              height: _currentPage == index ? 12 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.green[800] : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
