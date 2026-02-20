import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ------------------ Type de messe ------------------
class TypeMesseDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> types;
  final int? value;
  final ValueChanged<int?> onChanged;

  const TypeMesseDropdown({
    super.key,
    required this.types,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: InputDecoration(
          labelText: "Type de messe",
          prefixIcon: const Icon(Icons.church, color: Colors.deepPurple),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
        ),
        items: types
            .map(
              (e) => DropdownMenuItem<int>(
                value: e['id'],
                child: Text(e['lib_type_messe']),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? "Champ requis" : null,
      ),
    );
  }
}

/// ------------------ Type d'intention ------------------
class TypeIntentionDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> types;
  final int? value;
  final ValueChanged<int?> onChanged;

  const TypeIntentionDropdown({
    super.key,
    required this.types,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: InputDecoration(
          labelText: "Type d'intention",
          prefixIcon: const Icon(Icons.favorite, color: Colors.pinkAccent),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
        ),
        items: types
            .map(
              (e) => DropdownMenuItem<int>(
                value: e['id'],
                child: Text(e['lib_type_intention']),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? "Champ requis" : null,
      ),
    );
  }
}

/// ------------------ Date de la messe ------------------
class DateMessePickerFrench extends StatefulWidget {
  final DateTime? date;
  final ValueChanged<DateTime> onDateSelected;

  const DateMessePickerFrench({
    super.key,
    required this.date,
    required this.onDateSelected,
  });

  @override
  State<DateMessePickerFrench> createState() => _DateMessePickerFrenchState();
}

class _DateMessePickerFrenchState extends State<DateMessePickerFrench> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.date != null ? _formatDateFrench(widget.date!) : '',
    );
  }

  @override
  void didUpdateWidget(covariant DateMessePickerFrench oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.text = widget.date != null
        ? _formatDateFrench(widget.date!)
        : '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDateFrench(DateTime date) {
    final intl = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    return intl.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: "Date de la messe",
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
          suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
        ),
        validator: (val) => widget.date == null ? "Champ requis" : null,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate:
                widget.date ?? DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
            locale: const Locale('fr', 'FR'),
            // ✅ Personnalisation complète en français
            helpText: 'SÉLECTIONNER LA DATE',
            cancelText: 'Annuler',
            confirmText: 'OK',
            fieldLabelText: 'Date',
            fieldHintText: 'jj/mm/aaaa',
            errorFormatText: 'Format invalide',
            errorInvalidText: 'Date invalide',
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null && mounted) {
            widget.onDateSelected(picked);
          }
        },
      ),
    );
  }
}

/// ------------------ Heure de la messe ------------------
class HeureMesseFieldFrench extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay?> onChanged;

  const HeureMesseFieldFrench({
    super.key,
    this.selectedTime,
    required this.onChanged,
  });

  String _formatTimeFrench(TimeOfDay time) {
    final heures = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$heures:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: selectedTime ?? TimeOfDay.now(),
            // ✅ Configuration complète en français
            helpText: 'SÉLECTIONNER L\'HEURE',
            cancelText: 'Annuler',
            confirmText: 'OK',
            hourLabelText: 'Heure',
            minuteLabelText: 'Minutes',
            errorInvalidText: 'Heure invalide',
            builder: (context, child) {
              return Localizations.override(
                context: context,
                locale: const Locale('fr', 'FR'),
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(alwaysUse24HourFormat: true),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Colors.orange,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange,
                        ),
                      ),
                    ),
                    child: child!,
                  ),
                ),
              );
            },
          );
          if (picked != null) {
            onChanged(picked);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: "Heure de la messe",
            prefixIcon: const Icon(Icons.access_time, color: Colors.orange),
            suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
          ),
          child: Text(
            selectedTime != null
                ? _formatTimeFrench(selectedTime!)
                : "Appuyez pour choisir l'heure",
            style: TextStyle(
              color: selectedTime != null ? Colors.black87 : Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------ Lieu de la messe ------------------
class LieuMesseField extends StatelessWidget {
  final TextEditingController controller;

  const LieuMesseField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: "Lieu de la messe",
          prefixIcon: const Icon(Icons.location_on, color: Colors.teal),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
        ),
        validator: (val) => val == null || val.isEmpty ? "Champ requis" : null,
      ),
    );
  }
}

/// ------------------ Intentions ------------------
class IntentionsField extends StatelessWidget {
  final TextEditingController controller;

  const IntentionsField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: "Intentions de prière",
          prefixIcon: const Padding(
            padding: EdgeInsets.only(bottom: 60),
            child: Icon(Icons.edit_note, color: Colors.indigo),
          ),
          hintText: "Décrivez vos intentions de prière...",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.indigo, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
        ),
        validator: (val) => val == null || val.isEmpty ? "Champ requis" : null,
      ),
    );
  }
}

/// ------------------ Mode de paiement ------------------
class ModePaiementDropdown extends StatelessWidget {
  final List<String> modes;
  final String? selectedMode;
  final ValueChanged<String?> onChanged;

  const ModePaiementDropdown({
    super.key,
    required this.modes,
    required this.selectedMode,
    required this.onChanged,
  });

  IconData _getPaymentIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'moov':
        return Icons.phone_android;
      case 'orange':
        return Icons.phone_iphone;
      case 'mtn':
        return Icons.smartphone;
      case 'wave':
        return Icons.waves;
      default:
        return Icons.payment;
    }
  }

  Color _getPaymentColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'moov':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'mtn':
        return Colors.yellow.shade700;
      case 'wave':
        return Colors.cyan;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedMode,
        decoration: InputDecoration(
          labelText: "Mode de paiement",
          prefixIcon: Icon(
            selectedMode != null
                ? _getPaymentIcon(selectedMode!)
                : Icons.payment,
            color: selectedMode != null
                ? _getPaymentColor(selectedMode!)
                : Colors.green,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
        ),
        items: modes
            .map(
              (m) => DropdownMenuItem(
                value: m,
                child: Row(
                  children: [
                    Icon(
                      _getPaymentIcon(m),
                      color: _getPaymentColor(m),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(m),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? "Champ requis" : null,
      ),
    );
  }
}

/// ------------------ Montant ------------------
class MontantField extends StatelessWidget {
  final TextEditingController controller;

  const MontantField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: "Montant",
          prefixIcon: const Icon(Icons.attach_money, color: Colors.amber),
          suffixText: "FCFA",
          suffixStyle: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.amber, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return "Champ requis";
          final parsed = double.tryParse(val);
          if (parsed == null || parsed <= 0) return "Montant invalide";
          return null;
        },
      ),
    );
  }
}

/// ------------------ Numéro Mobile Money ------------------
class ContactField extends StatelessWidget {
  final TextEditingController controller;

  const ContactField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: "Numéro Mobile Money",
          prefixIcon: const Icon(Icons.phone, color: Colors.deepPurple),
          hintText: "Ex: 01 23 45 67 89",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
        ),
        validator: (val) => val == null || val.isEmpty ? "Champ requis" : null,
      ),
    );
  }
}
