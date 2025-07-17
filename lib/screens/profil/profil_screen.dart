import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../models/user.dart';
import '../../services/profile_service.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import 'widgets/profile_info_tile.dart';

class ProfileScreen extends StatefulWidget {
  final String token;

  const ProfileScreen({super.key, required this.token});

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
      Dio(BaseOptions(
        baseUrl: 'https://a9cb0983460d.ngrok-free.app/api',
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      )),
    );

    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _profileService.fetchUser();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement du profil : $e')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await AuthService().logout(); // Nettoyage local
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la déconnexion')),
      );
    }
  }

  void _goToChangePassword() {
    Navigator.pushNamed(
      context,
      AppRoutes.changePassword,
      arguments: widget.token,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profil'),
      ),
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
                        value: _user?.name ?? "",
                        icon: Icons.person,
                      ),
                      ProfileInfoTile(
                        title: "Email",
                        value: _user?.email ?? "",
                        icon: Icons.email,
                      ),
                      ProfileInfoTile(
                        title: "Contact",
                        value: _user?.contact ?? "",
                        icon: Icons.phone,
                      ),
                      ProfileInfoTile(
                        title: "Paroisse",
                        value: _user?.paroisseNom ?? "Non défini",
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
