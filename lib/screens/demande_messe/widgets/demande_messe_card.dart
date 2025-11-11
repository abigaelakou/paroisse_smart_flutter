import 'package:flutter/material.dart';
import '../../../models/demande_messe.dart';
import 'package:intl/intl.dart';

class DemandeMesseCard extends StatefulWidget {
  final DemandeMesse demande;

  const DemandeMesseCard({super.key, required this.demande});

  @override
  State<DemandeMesseCard> createState() => _DemandeMesseCardState();
}

class _DemandeMesseCardState extends State<DemandeMesseCard> {
  String? _selectedDate;
  String? _selectedHeure;

  /// ✅ Formatage de la date en français
  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "Non définie";
    try {
      final dt = DateTime.parse(date);
      return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(dt);
    } catch (_) {
      return date;
    }
  }

  /// ✅ Formatage de l’heure en français
  String _formatHeure(String? heure) {
    if (heure == null || heure.isEmpty) return "Non définie";
    try {
      final dt = DateFormat("HH:mm:ss").parse(heure);
      return DateFormat('HH:mm', 'fr_FR').format(dt);
    } catch (_) {
      return heure;
    }
  }

  /// ✅ Sélecteur de date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  /// ✅ Sélecteur d’heure
  Future<void> _selectHeure(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('fr', 'FR'),
          child: child,
        );
      },
    );

    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      setState(() {
        _selectedHeure = DateFormat('HH:mm:ss').format(dt);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = _formatDate(_selectedDate ?? widget.demande.dateMesse);
    final heure = _formatHeure(_selectedHeure ?? widget.demande.heureMesse);
    final lieu = widget.demande.lieuMesse.isNotEmpty == true
        ? widget.demande.lieuMesse
        : "Non défini";
    final intentions = widget.demande.intentions.isNotEmpty == true
        ? widget.demande.intentions
        : "Aucune intention";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.deepPurple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Champ Date
            TextFormField(
              readOnly: true,
              controller: TextEditingController(text: date),
              decoration: const InputDecoration(
                labelText: "Date de la messe",
                prefixIcon: Icon(Icons.calendar_today, color: Colors.amber),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 12),

            // ✅ Champ Heure
            TextFormField(
              readOnly: true,
              controller: TextEditingController(text: heure),
              decoration: const InputDecoration(
                labelText: "Heure de la messe",
                prefixIcon: Icon(Icons.access_time, color: Colors.amber),
              ),
              onTap: () => _selectHeure(context),
            ),
            const SizedBox(height: 12),

            // ✅ Lieu
            _buildInfoRow(Icons.location_on, "Lieu", lieu, Colors.teal),
            const SizedBox(height: 12),

            // ✅ Intentions
            _buildInfoRow(
              Icons.edit_note,
              "Intentions",
              intentions,
              Colors.indigo,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color color, {
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
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
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
