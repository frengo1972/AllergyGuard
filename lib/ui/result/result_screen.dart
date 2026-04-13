import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:allergyguard/core/tts/tts_service.dart';
import 'package:allergyguard/data/local/local_scan_repository.dart';
import 'package:allergyguard/data/local/local_preferences_service.dart';
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
  const ResultScreen({super.key, required this.result});
  final ScanResult result;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final LocalPreferencesService _preferences = LocalPreferencesService();
  final LocalScanRepository _scanRepository = LocalScanRepository();
  final TtsService _ttsService = TtsService();
  bool _isLabelExpanded = false;
  String _languageCode = 'it';
  bool _isAutoPlayEnabled = true;
  TtsSpeed _ttsSpeed = TtsSpeed.normal;
  bool _isTtsReady = false;

  @override
  void initState() {
    super.initState();
    _triggerHapticFeedback();
    unawaited(_initializeTts());
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
            onPressed: _isTtsReady ? _replayTts : null,
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
            if (widget.result.matches.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildMatchesList(),
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            child: SelectableText.rich(
              _buildHighlightedLabelText(),
              style: const TextStyle(fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.result.matches
          .map(
            (match) => Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          match.localizedAllergenName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _buildMatchChip(
                          match.isPartial ? 'Match parziale' : 'Match completo',
                          color: match.isPartial
                              ? const Color(0xFFFFF3CD)
                              : const Color(0xFFD1E7DD),
                        ),
                        _buildMatchChip(
                          match.languageLabel,
                          color: const Color(0xFFE2E3FF),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Riconosciuto: "${match.matchedText}"',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style.copyWith(
                              color: Colors.black87,
                              height: 1.4,
                            ),
                        children: [
                          const TextSpan(
                            text: 'Trovato in: ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          _buildHighlightedContainingText(match),
                        ],
                      ),
                    ),
                    if ((match.lineText ?? '').trim().isNotEmpty &&
                        match.lineText!.trim() !=
                            match.containingText.trim()) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Contesto OCR: ${match.lineText}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                    if (widget.result.referenceImagePath != null &&
                        match.boundingBox != null) ...[
                      const SizedBox(height: 12),
                      _MatchPreview(
                        imagePath: widget.result.referenceImagePath!,
                        match: match,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMatchChip(String label, {required Color color}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  TextSpan _buildHighlightedContainingText(ScanResultMatch match) {
    final containingText = match.containingText;
    final matchedText = match.matchedText.trim();
    if (matchedText.isEmpty) {
      return TextSpan(text: containingText);
    }

    final regex = RegExp(
      RegExp.escape(matchedText),
      caseSensitive: false,
    );
    final result = regex.firstMatch(containingText);
    if (result == null) {
      return TextSpan(text: containingText);
    }

    return TextSpan(
      children: [
        TextSpan(text: containingText.substring(0, result.start)),
        TextSpan(
          text: containingText.substring(result.start, result.end),
          style: const TextStyle(
            color: Color(0xFF8B0000),
            backgroundColor: Color(0xFFFFCDD2),
            fontWeight: FontWeight.w700,
          ),
        ),
        TextSpan(text: containingText.substring(result.end)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showReportDialog,
            icon: const Icon(Icons.flag, color: Colors.white),
            label: const Text('Segnala errore',
                style: TextStyle(color: Colors.white)),
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveToHistory,
            icon: const Icon(Icons.save),
            label: const Text('Salva'),
          ),
        ),
      ],
    );
  }

  Future<void> _initializeTts() async {
    final languageCode = await _preferences.getInterfaceLanguage();
    final autoPlayEnabled = await _preferences.isResultAutoPlayEnabled();
    final speedName = await _preferences.getTtsSpeedName();
    final speed = TtsSpeed.values.firstWhere(
      (value) => value.name == speedName,
      orElse: () => TtsSpeed.normal,
    );

    await _ttsService.initialize();
    await _ttsService.setLanguage(languageCode);
    await _ttsService.setSpeed(speed);

    if (!mounted) return;
    setState(() {
      _languageCode = languageCode;
      _isAutoPlayEnabled = autoPlayEnabled;
      _ttsSpeed = speed;
      _isTtsReady = true;
    });

    if (_isAutoPlayEnabled) {
      await _ttsService.announceResult(
        widget.result,
        locale: _languageCode,
      );
    }
  }

  Future<void> _replayTts() async {
    await _ttsService.stop();
    await _ttsService.setLanguage(_languageCode);
    await _ttsService.setSpeed(_ttsSpeed);
    await _ttsService.announceResult(
      widget.result,
      locale: _languageCode,
    );
  }

  Future<void> _saveToHistory() async {
    await _scanRepository.saveScan(widget.result);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Risultato salvato nello storico'),
      ),
    );
  }

  Future<void> _showReportDialog() async {
    final noteController = TextEditingController();
    var selectedType = 'wrong_detection';

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Segnala un problema'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo segnalazione',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'wrong_detection',
                        child: Text('Rilevamento errato'),
                      ),
                      DropdownMenuItem(
                        value: 'missing_allergen',
                        child: Text('Allergene non rilevato'),
                      ),
                      DropdownMenuItem(
                        value: 'ocr_problem',
                        child: Text('Problema OCR'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => selectedType = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Nota facoltativa',
                      hintText: 'Descrivi cosa non ti convince',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Annulla'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Salva segnalazione'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave != true) return;

    await _scanRepository.savePendingReport(
      result: widget.result,
      reportType: selectedType,
      note: noteController.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Segnalazione salvata localmente'),
      ),
    );
  }

  TextSpan _buildHighlightedLabelText() {
    final labelText = widget.result.ocrText;
    final highlightTerms = <String>{
      ...widget.result.highlightTerms,
      ...widget.result.matches.map((match) => match.matchedText),
    }
        .map((term) => term.trim())
        .where((term) => term.isNotEmpty)
        .toSet()
        .toList()
      ..sort((left, right) => right.length.compareTo(left.length));

    final effectiveHighlightTerms = highlightTerms
        .map((term) => term.trim())
        .where((term) => term.isNotEmpty)
        .toSet()
        .toList()
      ..sort((left, right) => right.length.compareTo(left.length));

    if (labelText.isEmpty || effectiveHighlightTerms.isEmpty) {
      return TextSpan(
        text: labelText,
        style: const TextStyle(color: Colors.black87),
      );
    }

    final regex = RegExp(
      effectiveHighlightTerms.map(RegExp.escape).join('|'),
      caseSensitive: false,
    );
    final spans = <TextSpan>[];
    var currentIndex = 0;

    for (final match in regex.allMatches(labelText)) {
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: labelText.substring(currentIndex, match.start),
            style: const TextStyle(color: Colors.black87),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: labelText.substring(match.start, match.end),
          style: const TextStyle(
            color: Color(0xFF8B0000),
            backgroundColor: Color(0xFFFFCDD2),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      currentIndex = match.end;
    }

    if (currentIndex < labelText.length) {
      spans.add(
        TextSpan(
          text: labelText.substring(currentIndex),
          style: const TextStyle(color: Colors.black87),
        ),
      );
    }

    return TextSpan(children: spans);
  }

  @override
  void dispose() {
    unawaited(_ttsService.dispose());
    super.dispose();
  }
}

class _MatchPreview extends StatelessWidget {
  const _MatchPreview({
    required this.imagePath,
    required this.match,
  });

  final String imagePath;
  final ScanResultMatch match;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Size>(
      future: _loadImageSize(imagePath),
      builder: (context, snapshot) {
        if (!snapshot.hasData || match.boundingBox == null) {
          return const SizedBox.shrink();
        }

        final imageSize = snapshot.data!;
        final box = match.boundingBox!;
        final cropRect = Rect.fromLTRB(
          (box.left - box.width * 1.2).clamp(0, imageSize.width),
          (box.top - box.height * 2.0).clamp(0, imageSize.height),
          (box.right + box.width * 1.2).clamp(0, imageSize.width),
          (box.bottom + box.height * 2.0).clamp(0, imageSize.height),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Area immagine ingrandita',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ColoredBox(
                color: Colors.black,
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final scale = [
                        constraints.maxWidth / cropRect.width,
                        constraints.maxHeight / cropRect.height,
                      ].reduce((left, right) => left < right ? left : right);
                      final imageWidth = imageSize.width * scale;
                      final imageHeight = imageSize.height * scale;
                      final dx = -cropRect.left * scale +
                          (constraints.maxWidth - cropRect.width * scale) / 2;
                      final dy = -cropRect.top * scale +
                          (constraints.maxHeight - cropRect.height * scale) / 2;

                      return Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Positioned(
                            left: dx,
                            top: dy,
                            width: imageWidth,
                            height: imageHeight,
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.fill,
                            ),
                          ),
                          Positioned(
                            left: dx + box.left * scale,
                            top: dy + box.top * scale,
                            width: box.width * scale,
                            height: box.height * scale,
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.redAccent,
                                    width: 3,
                                  ),
                                  color: const Color(0x33FF1744),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<ui.Size> _loadImageSize(String path) async {
    final bytes = await File(path).readAsBytes();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, completer.complete);
    final image = await completer.future;
    return ui.Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );
  }
}
