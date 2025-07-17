import 'package:flutter/material.dart';

class ProfileInfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const ProfileInfoTile({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      subtitle: Text(value),
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
    );
  }
}
