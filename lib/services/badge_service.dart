import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

class BadgeService {
  static const String _keyLastPainId = 'last_pain_id';
  static const String _keyLastAnnonceId = 'last_annonce_id';
  static const String _keyLastEvenementId = 'last_evenement_id';
  static const String _keyUnreadCount = 'unread_count';

  /// Vérifie s'il y a de nouveaux contenus et met à jour le badge
  Future<int> checkNewContent({
    required int? currentPainId,
    required int? currentAnnonceId,
    required int? currentEvenementId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    int unreadCount = 0;

    // Vérifier le pain du jour
    final lastPainId = prefs.getInt(_keyLastPainId);
    if (currentPainId != null &&
        lastPainId != null &&
        currentPainId > lastPainId) {
      unreadCount++;
    }

    // Vérifier les annonces
    final lastAnnonceId = prefs.getInt(_keyLastAnnonceId);
    if (currentAnnonceId != null &&
        lastAnnonceId != null &&
        currentAnnonceId > lastAnnonceId) {
      unreadCount++;
    }

    // Vérifier les événements
    final lastEvenementId = prefs.getInt(_keyLastEvenementId);
    if (currentEvenementId != null &&
        lastEvenementId != null &&
        currentEvenementId > lastEvenementId) {
      unreadCount++;
    }

    // Sauvegarder le compteur
    await prefs.setInt(_keyUnreadCount, unreadCount);

    // Mettre à jour le badge de l'icône
    await _updateAppBadge(unreadCount);

    return unreadCount;
  }

  /// Met à jour le badge de l'icône de l'application
  Future<void> _updateAppBadge(int count) async {
    try {
      if (count > 0) {
        await FlutterAppBadger.updateBadgeCount(count);
      } else {
        await FlutterAppBadger.removeBadge();
      }
    } catch (e) {
      print('Erreur mise à jour badge: $e');
    }
  }

  /// Marque le contenu comme lu et réinitialise le badge
  Future<void> markAsRead({
    int? painId,
    int? annonceId,
    int? evenementId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (painId != null) {
      await prefs.setInt(_keyLastPainId, painId);
    }
    if (annonceId != null) {
      await prefs.setInt(_keyLastAnnonceId, annonceId);
    }
    if (evenementId != null) {
      await prefs.setInt(_keyLastEvenementId, evenementId);
    }

    // Réinitialiser le compteur
    await prefs.setInt(_keyUnreadCount, 0);
    await FlutterAppBadger.removeBadge();
  }

  /// Réinitialise complètement tous les badges
  Future<void> resetAllBadges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUnreadCount, 0);
    await FlutterAppBadger.removeBadge();
  }

  /// Récupère le nombre actuel de notifications non lues
  Future<int> getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUnreadCount) ?? 0;
  }

  /// Initialise les IDs lors de la première connexion
  Future<void> initializeIds({
    required int? painId,
    required int? annonceId,
    required int? evenementId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Ne sauvegarder que si c'est la première fois
    if (!prefs.containsKey(_keyLastPainId) && painId != null) {
      await prefs.setInt(_keyLastPainId, painId);
    }
    if (!prefs.containsKey(_keyLastAnnonceId) && annonceId != null) {
      await prefs.setInt(_keyLastAnnonceId, annonceId);
    }
    if (!prefs.containsKey(_keyLastEvenementId) && evenementId != null) {
      await prefs.setInt(_keyLastEvenementId, evenementId);
    }
  }
}
