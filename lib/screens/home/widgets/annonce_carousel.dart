import 'package:flutter/material.dart';
import '../../../models/annonce.dart';

class AnnonceCarousel extends StatelessWidget {
  final List<Annonce>? annonces;
  final Annonce? singleAnnonce; // Pour l’infinite scroll horizontal

  const AnnonceCarousel({super.key, this.annonces, this.singleAnnonce});

  // Factory pour un seul item
  factory AnnonceCarousel.singleItem({required Annonce annonce}) {
    return AnnonceCarousel(singleAnnonce: annonce);
  }

  @override
  Widget build(BuildContext context) {
    final items = annonces ?? (singleAnnonce != null ? [singleAnnonce!] : []);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: items.map((annonce) {
        return Container(
          width: 250,
          margin: const EdgeInsets.only(right: 12),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
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
          ),
        );
      }).toList(),
    );
  }
}
