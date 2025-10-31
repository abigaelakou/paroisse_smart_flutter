import 'package:flutter/material.dart';
import '../../../models/annonce.dart';
import 'annonce_item.dart';

class AnnonceCarousel extends StatefulWidget {
  final List<Annonce> annonces;

  const AnnonceCarousel({super.key, required this.annonces});

  @override
  State<AnnonceCarousel> createState() => _AnnonceCarouselState();
}

class _AnnonceCarouselState extends State<AnnonceCarousel> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrows);

    // Vérifier les flèches après le premier build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateArrows();
    });
  }

  void _updateArrows() {
    if (!_scrollController.hasClients) return;

    setState(() {
      // Afficher la flèche gauche si on n'est pas au début
      _showLeftArrow = _scrollController.offset > 10;

      // Afficher la flèche droite si on n'est pas à la fin
      _showRightArrow =
          _scrollController.offset <
          _scrollController.position.maxScrollExtent - 10;
    });
  }

  void _scrollLeft() {
    if (_scrollController.hasClients) {
      final currentOffset = _scrollController.offset;
      final targetOffset = (currentOffset - 260).clamp(0.0, double.infinity);

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollRight() {
    if (_scrollController.hasClients) {
      final currentOffset = _scrollController.offset;
      final maxOffset = _scrollController.position.maxScrollExtent;
      final targetOffset = (currentOffset + 260).clamp(0.0, maxOffset);

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.annonces.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        // Liste scrollable des annonces
        SizedBox(
          height: 190,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.annonces.length,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (context, index) {
              final annonce = widget.annonces[index];

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 100)),
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
                child: Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
                  child: AnnonceItem(annonce: annonce),
                ),
              );
            },
          ),
        ),

        // Flèche gauche
        if (_showLeftArrow && widget.annonces.length > 2)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: _scrollLeft,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.blue.shade700,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),

        // Flèche droite
        if (_showRightArrow && widget.annonces.length > 2)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: _scrollRight,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.blue.shade700,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),

        // Indicateur de nombre d'annonces (en bas à droite)
        if (widget.annonces.length > 1)
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.campaign, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.annonces.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
