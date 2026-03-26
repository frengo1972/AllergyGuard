import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:allergyguard/domain/models/scan_result.dart';
import 'package:allergyguard/ui/common/app_colors.dart';
import 'package:allergyguard/ui/common/disclaimer_widget.dart';

/// Schermata risultato scansione.
///
/// - Colore sfondo = livello risultato (rosso/arancione/verde/grigio)
/// - Nome prodotto e brand
/// - Allergeni trovati con evidenziazione
/// - Testo etichetta completo in accordion
/// - Disclaimer visibile
/// - Bottone 'Segnala errore' e 'Salva'
/// - TTS automatico all'apertura
class ResultScreen extends StatefulWidget {
  final ScanResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isLabelExpanded = false;

  @override
  void initState() {
    super.initState();
    _triggerHapticFeedback();
    // TODO: TTS automatico all'apertura (se abilitato)
  }

  void _triggerHapticFeedback() {
    switch (widget.result.level) {
      case ScanResultLevel.danger:
        HapticFeedback.heavyImpact();
      case ScanResultLevel.warning:
        HapticFeedback.mediumImpact();
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.forResult(widget.result.level);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay),
            onPressed: () {
              // TODO: Replay TTS
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildResultIcon(),
            const SizedBox(height: 16),
            _buildResultTitle(),
            if (widget.result.productName != null) ...[
              const SizedBox(height: 8),
              _buildProductInfo(),
            ],
            if (widget.result.allergens.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildAllergensList(),
            ],
            const SizedBox(height: 16),
            const DisclaimerWidget(),
            const SizedBox(height: 16),
            _buildLabelAccordion(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultIcon() {
    final iconData = switch (widget.result.level) {
      ScanResultLevel.danger => Icons.dangerous,
      ScanResultLevel.warning => Icons.warning_amber,
      ScanResultLevel.safe => Icons.check_circle,
      ScanResultLevel.unknown => Icons.help_outline,
    };

    return Icon(iconData, size: 80, color: Colors.white);
  }

  Widget _buildResultTitle() {
    final title = switch (widget.result.level) {
      ScanResultLevel.danger => 'PERICOLO',
      ScanResultLevel.warning => 'ATTENZIONE',
      ScanResultLevel.safe => 'APPARENTEMENTE SICURO',
      ScanResultLevel.unknown => 'NON VERIFICABILE',
    };

    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildProductInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (widget.result.productName != null)
              Text(
                widget.result.productName!,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            if (widget.result.brand != null)
              Text(
                widget.result.brand!,
                style: TextStyle(color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergensList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Allergeni rilevati:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...widget.result.allergens.map((a) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Text(a, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelAccordion() {
    return Card(
      child: ExpansionTile(
        title: const Text('Testo etichetta completo'),
        initiallyExpanded: _isLabelExpanded,
        onExpansionChanged: (v) => setState(() => _isLabelExpanded = v),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              widget.result.ocrText,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Segnala errore
            },
            icon: const Icon(Icons.flag, color: Colors.white),
            label: const Text('Segnala errore',
                style: TextStyle(color: Colors.white)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Salva nello storico
            },
            icon: const Icon(Icons.save),
            label: const Text('Salva'),
          ),
        ),
      ],
    );
  }
}
