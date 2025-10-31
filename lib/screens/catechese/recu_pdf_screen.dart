import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class RecuPdfScreen extends StatefulWidget {
  final String url;
  final String token;
  final int paroisseId;

  const RecuPdfScreen({
    super.key,
    required this.url,
    required this.token,
    required this.paroisseId,
  });

  @override
  State<RecuPdfScreen> createState() => _RecuPdfScreenState();
}

class _RecuPdfScreenState extends State<RecuPdfScreen> {
  bool _downloading = false;
  late PdfViewerController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
  }

  bool get _isLocal =>
      widget.url.startsWith('/') || widget.url.startsWith('file:');

  /// 📥 Téléchargement du PDF
  Future<void> _downloadPdf() async {
    if (_downloading) return;
    setState(() => _downloading = true);

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'recu_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${dir.path}/$fileName';

      await Dio().download(
        widget.url,
        filePath,
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Reçu téléchargé avec succès !')),
      );

      await OpenFile.open(filePath);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Erreur lors du téléchargement : $e')),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  /// 🔙 Revenir à l'accueil en préservant la navigation
  void _retourAccueil() {
    // On remonte jusqu'à la route nommée '/home' ou jusqu'à ce qu'il n'y ait plus qu'une route
    Navigator.of(context).popUntil((route) {
      // Si on trouve la route '/home', on s'arrête là
      if (route.settings.name == '/home') return true;
      // Si c'est la première route (MainScaffold), on s'arrête
      if (route.isFirst) return true;
      // Sinon on continue à remonter
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pdfSource = _isLocal
        ? SfPdfViewer.file(File(widget.url), controller: _pdfController)
        : SfPdfViewer.network(widget.url, controller: _pdfController);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reçu PDF'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            tooltip: 'Télécharger le reçu',
            onPressed: _downloading ? null : _downloadPdf,
            icon: _downloading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.download),
          ),
        ],
      ),
      body: pdfSource,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _retourAccueil,
            icon: const Icon(Icons.home),
            label: const Text('Retour au menu catechèse'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }
}
