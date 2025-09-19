import 'package:flutter/material.dart';

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
    return DropdownButtonFormField<int>(
      value: value,
      decoration: const InputDecoration(
        labelText: "Type de messe",
        border: OutlineInputBorder(),
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
    );
  }
}

/// ------------------ Type d’intention ------------------
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
    return DropdownButtonFormField<int>(
      value: value,
      decoration: const InputDecoration(
        labelText: "Type d’intention",
        border: OutlineInputBorder(),
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
    );
  }
}

/// ------------------ Date de la messe ------------------
class DateMessePicker extends StatefulWidget {
  final DateTime? date;
  final ValueChanged<DateTime> onDateSelected;

  const DateMessePicker({
    super.key,
    required this.date,
    required this.onDateSelected,
  });

  @override
  State<DateMessePicker> createState() => _DateMessePickerState();
}

class _DateMessePickerState extends State<DateMessePicker> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.date != null
          ? widget.date!.toIso8601String().split('T')[0]
          : '',
    );
  }

  @override
  void didUpdateWidget(covariant DateMessePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.text = widget.date != null
        ? widget.date!.toIso8601String().split('T')[0]
        : '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: "Date de la messe",
        border: OutlineInputBorder(),
      ),
      validator: (val) => widget.date == null ? "Champ requis" : null,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate:
              widget.date ?? DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (picked != null && mounted) {
          widget.onDateSelected(picked);
        }
      },
    );
  }
}

/// ------------------ Heure de la messe ------------------
class HeureMesseField extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay?> onChanged;

  const HeureMesseField({
    super.key,
    this.selectedTime,
    required this.onChanged,
  });

  bool? get mounted => null;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (picked != null && mounted!) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: "Heure de la messe",
          border: OutlineInputBorder(),
        ),
        child: Text(
          selectedTime != null
              ? selectedTime!.format(context)
              : "Appuyez pour choisir l'heure",
          style: TextStyle(
            color: selectedTime != null ? Colors.black : Colors.grey[600],
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
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: "Lieu de la messe",
        border: OutlineInputBorder(),
      ),
      validator: (val) => val == null || val.isEmpty ? "Champ requis" : null,
    );
  }
}

/// ------------------ Intentions ------------------
class IntentionsField extends StatelessWidget {
  final TextEditingController controller;

  const IntentionsField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: "Intentions",
        border: OutlineInputBorder(),
      ),
      validator: (val) => val == null || val.isEmpty ? "Champ requis" : null,
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

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedMode,
      decoration: const InputDecoration(
        labelText: "Mode de paiement",
        border: OutlineInputBorder(),
      ),
      items: modes
          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? "Champ requis" : null,
    );
  }
}

/// ------------------ Montant ------------------
class MontantField extends StatelessWidget {
  final TextEditingController controller;

  const MontantField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Montant (FCFA)",
        border: OutlineInputBorder(),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return "Champ requis";
        final parsed = double.tryParse(val);
        if (parsed == null || parsed <= 0) return "Montant invalide";
        return null;
      },
    );
  }
}

/// ------------------ Numéro Mobile Money ------------------
class ContactField extends StatelessWidget {
  final TextEditingController controller;

  const ContactField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: "Numéro Mobile Money",
        border: OutlineInputBorder(),
      ),
      validator: (val) => val == null || val.isEmpty ? "Champ requis" : null,
    );
  }
}
