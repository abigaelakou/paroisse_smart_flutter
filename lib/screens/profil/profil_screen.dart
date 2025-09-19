import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../models/user.dart';
import '../../services/profile_service.dart';
import '../../services/auth_service.dart';
import 'widgets/profile_info_tile.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  final String token;

  const ProfileScreen({super.key, required this.token, required paroisseId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileService _profileService;
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(
      Dio(
        BaseOptions(
          baseUrl: 'https://www.paroissesmart.com/api',
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          },
        ),
      ),
    );
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _profileService.fetchUser();
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  void _goToChangePassword() {
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      AppRoutes.changePassword,
      arguments: widget.token,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? const Center(child: Text('Utilisateur introuvable'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  ProfileInfoTile(
                    title: "Nom",
                    value: _user!.name,
                    icon: Icons.person,
                  ),
                  ProfileInfoTile(
                    title: "Email",
                    value: _user!.email,
                    icon: Icons.email,
                  ),
                  ProfileInfoTile(
                    title: "Contact",
                    value: _user!.contact ?? 'Non défini',
                    icon: Icons.phone,
                  ),
                  ProfileInfoTile(
                    title: "Paroisse",
                    value: _user!.paroisseNom ?? 'Non défini',
                    icon: Icons.church,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _goToChangePassword,
                    icon: const Icon(Icons.lock_reset),
                    label: const Text('Changer le mot de passe'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Se déconnecter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
