// screens/pain_du_jour/pain_du_jour_screen.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../models/pain_du_jour_item.dart';
import '../../services/pain_du_jour_service.dart';
import 'widgets/pain_du_jour_item.dart';

class PainDuJourScreen extends StatefulWidget {
  final String token;

  const PainDuJourScreen({super.key, required this.token});

  @override
  State<PainDuJourScreen> createState() => _PainDuJourScreenState();
}

class _PainDuJourScreenState extends State<PainDuJourScreen> {
  late final PainDuJourService _service;
  List<PainDuJourItem> _pains = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _service = PainDuJourService(
        Dio(BaseOptions(
        baseUrl: 'https://www.paroissesmart.com/api',
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      )),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    final pains = await _service.fetchHistorique();
    setState(() {
      _pains = pains;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         automaticallyImplyLeading: false,
        title: const Text('Pain du jour')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _pains.length,
                itemBuilder: (_, index) {
                  return PainDuJourItemWidget(pain: _pains[index]);
                },
              ),
            ),
    );
  }
}


