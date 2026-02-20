import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:paroisse_smart_flutter/navigation/main_scaffold.dart';
import 'package:paroisse_smart_flutter/screens/catechese/liste_paiements_screen.dart';
import 'package:paroisse_smart_flutter/services/catechese_service.dart';
import 'recu_pdf_screen.dart';
import '../../models/user.dart';

class ConfirmationInscriptionScreen extends StatefulWidget {
  final int inscriptionId;
  final String token;
  final int paroisseId;
  final User user;

  const ConfirmationInscriptionScreen({
    super.key,
    required this.inscriptionId,
    required this.token,
    required this.paroisseId,
    required this.user,
  });

  @override
  State<ConfirmationInscriptionScreen> createState() =>
      _ConfirmationInscriptionScreenState();
}

class _ConfirmationInscriptionScreenState
    extends State<ConfirmationInscriptionScreen> {
  bool _isSubmitting = false;
  int _montant = 0;
  String _modePaiement = 'Wave';
  String _contact = '';

  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  final _contactController = TextEditingController();

  @override
  void dispose() {
    _montantController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submitPaiement() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final service = CatecheseService(token: widget.token);
      final recuUrl = await service.payerInscription(
        inscriptionId: widget.inscriptionId,
        montant: _montant.toDouble(),
        modePaiement: _modePaiement,
        contact: _contact,
        paymentStatus: 'Payé',
      );

      if (!mounted) return;

      if (recuUrl != null && recuUrl.isNotEmpty) {
        final fullUrl = recuUrl.startsWith('http')
            ? recuUrl
            : 'https://paroissesmart.com$recuUrl';

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        final response = await http.get(Uri.parse(fullUrl));

        if (!mounted) return;
        Navigator.pop(context);

        if (response.statusCode == 200 &&
            response.contentLength != null &&
            response.contentLength! > 500) {
          final shouldViewReceipt = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/animations/success.json',
                      repeat: false,
                      height: 120,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Paiement réussi !',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Votre reçu est prêt à être consulté.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.teal,
                              side: const BorderSide(color: Colors.teal),
                              minimumSize: const Size.fromHeight(45),
                            ),
                            child: const Text('Plus tard'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              minimumSize: const Size.fromHeight(45),
                            ),
                            child: const Text('Voir le reçu'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );

          if (!mounted) return;

          if (shouldViewReceipt == true) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecuPdfScreen(
                  url: fullUrl,
                  token: widget.token,
                  paroisseId: widget.paroisseId,
                  user: widget.user,
                ),
              ),
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => MainScaffold(
                  token: widget.token,
                  user: widget.user,
                  initialIndex: 3, // ✅ Onglet Catéchèse
                ),
              ),
              (route) => false,
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Le reçu est en cours de génération...'),
              backgroundColor: Colors.orange,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ListePaiementsCatecheseScreen(
                token: widget.token,
                paroisseId: widget.paroisseId,
                user: widget.user,
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur : reçu introuvable.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).popUntil((route) => route is! DialogRoute);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur paiement : $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ important pour le clavier
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.payment, size: 24),
            SizedBox(width: 8),
            Text(
              'Paiement inscription',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 20),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade600, Colors.teal.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white, size: 32),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Veuillez renseigner les informations de paiement',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 15),
                      child: child,
                    ),
                  );
                },
                child: TextFormField(
                  controller: _montantController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Montant (FCFA)',
                    hintText: 'Entrez le montant',
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.payments,
                        color: Colors.teal.shade700,
                        size: 20,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.teal.shade600,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Montant requis';
                    final montant = int.tryParse(v);
                    if (montant == null || montant <= 0) {
                      return 'Montant invalide';
                    }
                    return null;
                  },
                  onChanged: (v) => _montant = int.tryParse(v) ?? 0,
                ),
              ),
              const SizedBox(height: 16),

              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 15),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    value: _modePaiement,
                    decoration: InputDecoration(
                      labelText: 'Mode de paiement',
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                      ),
                      border: InputBorder.none,
                    ),
                    items: ['Wave', 'Orange', 'MTN', 'Moov']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => _modePaiement = v!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 15),
                      child: child,
                    ),
                  );
                },
                child: TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    labelText: 'Numéro de téléphone',
                    hintText: 'Ex: 77 123 45 67',
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.phone,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.orange.shade600,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Contact requis';
                    if (v.length < 8) return 'Numéro invalide';
                    return null;
                  },
                  onChanged: (v) => _contact = v,
                ),
              ),
              const SizedBox(height: 32),

              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 0.95 + (value * 0.05),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade600, Colors.teal.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitPaiement,
                    icon: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_circle, size: 24),
                    label: Text(
                      _isSubmitting ? 'Traitement...' : 'Payer maintenant',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitPaiement,
          icon: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.check_circle, size: 24),
          label: Text(
            _isSubmitting ? 'Traitement...' : 'Payer maintenant',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
