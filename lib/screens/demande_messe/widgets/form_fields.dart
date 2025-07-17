import 'package:flutter/material.dart';

/// Champ de sélection pour le type de messe
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
      decoration: const InputDecoration(labelText: "Type de messe"),
      items: types
          .map((e) => DropdownMenuItem<int>(
                value: e['id'],
                child: Text(e['lib_type_messe']),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? "Champ requis" : null,
    );
  }
}

/// Champ de sélection pour le type d’intention
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
      decoration: const InputDecoration(labelText: "Type d’intention"),
      items: types
          .map((e) => DropdownMenuItem<int>(
                value: e['id'],
                child: Text(e['lib_type_intention']),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? "Champ requis" : null,
    );
  }
}

/// Sélecteur de date
class DateMessePicker extends StatelessWidget {
  final DateTime? date;
  final ValueChanged<DateTime> onDateSelected;

  const DateMessePicker({
    super.key,
    required this.date,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      decoration: const InputDecoration(labelText: "Date messe"),
      controller: TextEditingController(
        text: date != null ? date!.toIso8601String().split('T')[0] : '',
      ),
      validator: (val) => date == null ? "Champ requis" : null,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
    );
  }
}

/// Champ pour l'heure de la messe
class HeureMesseField extends StatelessWidget {
  final void Function(TimeOfDay?) onChanged;
  final TimeOfDay? selectedTime;

const HeureMesseField({
  super.key,
  required this.onChanged,
  this.selectedTime,
});

@override
Widget build(BuildContext context) {
  return InkWell(
    onTap: () async {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime ?? TimeOfDay.now(),
      );
      if (pickedTime != null) {
        onChanged(pickedTime);
      }
    },
    child: InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Heure de la messe',
        border: OutlineInputBorder(),
      ),
      child: Text(
        selectedTime != null
            ? selectedTime!.format(context)
            : 'Appuyez pour choisir l\'heure',
        style: TextStyle(
          color: selectedTime != null ? Colors.black : Colors.grey,
        ),
      ),
    ),
  );
}

}


/// Champ pour le lieu de la messe
class LieuMesseField extends StatelessWidget {
  final TextEditingController controller;

  const LieuMesseField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(labelText: "Lieu de la messe"),
      validator: (val) => val == null || val.isEmpty ? "Champ requis" : null,
    );
  }
}

/// Champ pour les intentions
class IntentionsField extends StatelessWidget {
  final TextEditingController controller;

  const IntentionsField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: const InputDecoration(labelText: "Intentions"),
      validator: (val) => val == null || val.isEmpty ? "Champ requis" : null,
    );
  }
}

/// Dropdown pour le mode de paiement
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
      decoration: const InputDecoration(labelText: "Mode de paiement"),
      items: modes
          .map((mode) => DropdownMenuItem<String>(
                value: mode,
                child: Text(mode),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? "Champ requis" : null,
    );
  }
}

/// Champ pour le montant
class MontantField extends StatelessWidget {
  final TextEditingController controller;

  const MontantField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(labelText: "Montant (FCFA)"),
      validator: (val) {
        if (val == null || val.isEmpty) return "Champ requis";
        final parsed = double.tryParse(val);
        if (parsed == null || parsed <= 0) return "Montant invalide";
        return null;
      },
    );
  }
}

/// Champ pour le numéro mobile money
class ContactField extends StatelessWidget {
  final TextEditingController controller;

  const ContactField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(labelText: "Numéro Mobile Money"),
      validator: (val) => val == null || val.isEmpty ? "Champ requis" : null,
    );
  }
}
