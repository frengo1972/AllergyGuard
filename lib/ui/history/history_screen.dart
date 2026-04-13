import 'package:flutter/material.dart';
import 'package:allergyguard/data/local/local_scan_repository.dart';
import 'package:allergyguard/domain/models/scan_result.dart';
import 'package:allergyguard/ui/common/app_colors.dart';

/// Schermata storico scansioni.
///
/// - Lista cronologica con nome prodotto, risultato, data
/// - Filtro per livello risultato
/// - Ricerca per nome prodotto
/// - Badge colorato per risultato
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final LocalScanRepository _scanRepository = LocalScanRepository();
  ScanResultLevel? _filterLevel;
  String _searchQuery = '';
  bool _isLoading = true;
  List<ScanResult> _history = <ScanResult>[];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storico Scansioni'),
        actions: [
          PopupMenuButton<ScanResultLevel?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (level) => setState(() => _filterLevel = level),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Tutti')),
              const PopupMenuItem(
                  value: ScanResultLevel.danger, child: Text('Pericolo')),
              const PopupMenuItem(
                  value: ScanResultLevel.warning, child: Text('Attenzione')),
              const PopupMenuItem(
                  value: ScanResultLevel.safe, child: Text('Sicuro')),
              const PopupMenuItem(
                  value: ScanResultLevel.unknown, child: Text('Sconosciuto')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cerca prodotto...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (q) => setState(() => _searchQuery = q),
            ),
          ),
          Expanded(
            child: _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final filtered = _history.where((result) {
      final matchesFilter =
          _filterLevel == null || result.level == _filterLevel;
      if (!matchesFilter) return false;
      if (normalizedQuery.isEmpty) return true;

      final haystacks = [
        result.productName ?? '',
        result.brand ?? '',
        result.barcode ?? '',
        result.ocrText,
        ...result.allergens,
      ].map((value) => value.toLowerCase());

      return haystacks.any((value) => value.contains(normalizedQuery));
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('Nessuna scansione salvata'));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) => buildHistoryTile(filtered[index]),
    );
  }

  Widget buildHistoryTile(ScanResult result) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.forResult(result.level),
        child: Icon(
          switch (result.level) {
            ScanResultLevel.danger => Icons.dangerous,
            ScanResultLevel.warning => Icons.warning,
            ScanResultLevel.safe => Icons.check,
            ScanResultLevel.unknown => Icons.help,
          },
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(result.productName ?? 'Prodotto sconosciuto'),
      subtitle: Text(result.barcode ?? 'OCR'),
      trailing: Text(
        '${result.scannedAt.day}/${result.scannedAt.month}/${result.scannedAt.year}',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Future<void> _loadHistory() async {
    final history = await _scanRepository.getHistory();
    if (!mounted) return;
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }
}
