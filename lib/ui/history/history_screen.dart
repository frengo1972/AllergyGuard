import 'package:flutter/material.dart';
import 'package:allergyguard/data/local/local_scan_repository.dart';
import 'package:allergyguard/domain/models/scan_result.dart';
import 'package:allergyguard/l10n/app_localizations.dart';
import 'package:allergyguard/ui/common/app_colors.dart';

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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        actions: [
          PopupMenuButton<ScanResultLevel?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (level) => setState(() => _filterLevel = level),
            itemBuilder: (_) => [
              PopupMenuItem(value: null, child: Text(l10n.historyFilterAll)),
              PopupMenuItem(
                value: ScanResultLevel.danger,
                child: Text(l10n.historyFilterDanger),
              ),
              PopupMenuItem(
                value: ScanResultLevel.warning,
                child: Text(l10n.historyFilterWarning),
              ),
              PopupMenuItem(
                value: ScanResultLevel.safe,
                child: Text(l10n.historyFilterSafe),
              ),
              PopupMenuItem(
                value: ScanResultLevel.unknown,
                child: Text(l10n.historyFilterUnknown),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.historySearchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
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

    final l10n = AppLocalizations.of(context);
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
      return Center(child: Text(l10n.historyEmpty));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) => buildHistoryTile(filtered[index]),
    );
  }

  Widget buildHistoryTile(ScanResult result) {
    final l10n = AppLocalizations.of(context);
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
      title: Text(result.productName ?? l10n.historyUnknownProduct),
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
