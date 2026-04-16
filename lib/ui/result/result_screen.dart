import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allergyguard/core/tts/tts_service.dart';
import 'package:allergyguard/data/feedback/feedback_submission_service.dart';
import 'package:allergyguard/data/local/local_scan_repository.dart';
import 'package:allergyguard/data/local/local_preferences_service.dart';
import 'package:allergyguard/data/remote/feedback_remote_repo.dart';
import 'package:allergyguard/domain/models/scan_result.dart';
import 'package:allergyguard/l10n/app_localizations.dart';
import 'package:allergyguard/providers.dart';
import 'package:allergyguard/ui/common/app_colors.dart';
import 'package:allergyguard/ui/common/disclaimer_widget.dart';
import 'package:allergyguard/ui/feedback/feedback_screen.dart';

/// Schermata risultato scansione.
///
/// - Colore sfondo = livello risultato (rosso/arancione/verde/grigio)
/// - Nome prodotto e brand
/// - Allergeni trovati con evidenziazione
/// - Testo etichetta completo in accordion
/// - Disclaimer visibile
/// - Bottone 'Segnala errore' e 'Salva'
/// - TTS automatico all'apertura
class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.result});
  final ScanResult result;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final LocalPreferencesService _preferences = LocalPreferencesService();
  final LocalScanRepository _scanRepository = LocalScanRepository();
  final TtsService _ttsService = TtsService();
  bool _isLabelExpanded = false;
  String _languageCode = 'it';
  bool _isAutoPlayEnabled = true;
  TtsSpeed _ttsSpeed = TtsSpeed.normal;
  bool _isTtsReady = false;
  bool _isSubmittingPositiveFeedback = false;
  bool _hasSubmittedPositiveFeedback = false;

  @override
  void initState() {
    super.initState();
    _triggerHapticFeedback();
    unawaited(_initializeTts());
    unawaited(ref.read(feedbackSubmissionServiceProvider).flushPending());
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
            if (widget.result.referenceImagePath != null &&
                _previewableMatches.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildZoomedMatchesSection(),
            ],
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
            const SizedBox(height: 12),
            _buildFeedbackCard(),
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
    final l10n = AppLocalizations.of(context);
    final title = switch (widget.result.level) {
      ScanResultLevel.danger => l10n.resultLevelDanger,
      ScanResultLevel.warning => l10n.resultLevelWarning,
      ScanResultLevel.safe => l10n.resultLevelSafe,
      ScanResultLevel.unknown => l10n.resultLevelUnknown,
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
            Text(
              AppLocalizations.of(context).resultAllergensDetected,
              style: const TextStyle(fontWeight: FontWeight.bold),
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

  List<ScanResultMatch> get _previewableMatches => widget.result.matches
      .where((match) => match.boundingBox != null)
      .toList(growable: false);

  Widget _buildZoomedMatchesSection() {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.resultZoomedArea,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 244,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _previewableMatches.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final match = _previewableMatches[index];
                  return SizedBox(
                    width: 260,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.localizedAllergenName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '"${match.matchedText}"',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: _MatchPreview(
                            imagePath: widget.result.referenceImagePath!,
                            match: match,
                            showTitle: false,
                            previewHeight: 180,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard() {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.feedbackWasCorrectQuestion,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: (_isSubmittingPositiveFeedback ||
                            _hasSubmittedPositiveFeedback)
                        ? null
                        : _submitPositiveFeedback,
                    icon: _isSubmittingPositiveFeedback
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _hasSubmittedPositiveFeedback
                                ? Icons.check_circle
                                : Icons.thumb_up_alt_outlined,
                          ),
                    label: Text(
                      _isSubmittingPositiveFeedback
                          ? l10n.commonSending
                          : l10n.feedbackWasCorrectYes,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _hasSubmittedPositiveFeedback
                          ? const Color(0xFF2E7D32)
                          : null,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openFeedback(initialIsCorrect: false),
                    icon: const Icon(Icons.thumb_down_alt_outlined),
                    label: Text(l10n.feedbackWasCorrectNo),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => _openFeedback(),
              icon: const Icon(Icons.rate_review_outlined),
              label: Text(l10n.resultFeedbackCta),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPositiveFeedback() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isSubmittingPositiveFeedback = true);

    final submissionService = ref.read(feedbackSubmissionServiceProvider);
    final outcome = await submissionService.submit(
      type: FeedbackType.scanAccuracy,
      resultLevel: widget.result.level.name,
      isCorrect: true,
      productBarcode: widget.result.barcode,
      allergenKeys: widget.result.allergens,
    );

    if (!mounted) return;
    setState(() {
      _isSubmittingPositiveFeedback = false;
      _hasSubmittedPositiveFeedback =
          outcome == FeedbackSubmitOutcome.submitted ||
              outcome == FeedbackSubmitOutcome.queued;
    });

    if (_hasSubmittedPositiveFeedback) {
      _snack(l10n.feedbackThankYouTitle);
    } else {
      _snack(l10n.feedbackSubmitError);
    }
  }

  Future<void> _openFeedback({bool? initialIsCorrect}) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FeedbackScreen(
          prefilledResultLevel: widget.result.level.name,
          prefilledBarcode: widget.result.barcode,
          prefilledAllergenKeys: widget.result.allergens,
          initialIsCorrect: initialIsCorrect,
        ),
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildLabelAccordion() {
    return Card(
      child: ExpansionTile(
        title: Text(AppLocalizations.of(context).resultLabelAccordion),
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
    final l10n = AppLocalizations.of(context);
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
                          match.isPartial
                              ? l10n.resultPartialMatch
                              : l10n.resultFullMatch,
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
                      '${l10n.resultRecognizedPrefix} "${match.matchedText}"',
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
                          TextSpan(
                            text: '${l10n.resultFoundInPrefix} ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
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
                        '${l10n.resultOcrContext} ${match.lineText}',
                        style: TextStyle(color: Colors.grey.shade700),
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
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showReportDialog,
            icon: const Icon(Icons.flag, color: Colors.white),
            label: Text(
              l10n.resultReportError,
              style: const TextStyle(color: Colors.white),
            ),
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveToHistory,
            icon: const Icon(Icons.save),
            label: Text(l10n.commonSave),
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
      SnackBar(
        content: Text(AppLocalizations.of(context).resultSaveToHistory),
      ),
    );
  }

  Future<void> _showReportDialog() async {
    final l10n = AppLocalizations.of(context);
    final noteController = TextEditingController();
    var selectedType = 'wrong_detection';

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.resultReportDialogTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: InputDecoration(
                      labelText: l10n.resultReportTypeLabel,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'wrong_detection',
                        child: Text(l10n.resultReportWrongDetection),
                      ),
                      DropdownMenuItem(
                        value: 'missing_allergen',
                        child: Text(l10n.resultReportMissingAllergen),
                      ),
                      DropdownMenuItem(
                        value: 'ocr_problem',
                        child: Text(l10n.resultReportOcrProblem),
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
                    decoration: InputDecoration(
                      labelText: l10n.resultReportOptionalNote,
                      hintText: l10n.resultReportNoteHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.commonCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.resultReportSaveAction),
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
      SnackBar(
        content: Text(AppLocalizations.of(context).resultReportSaved),
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
    this.showTitle = true,
    this.previewHeight = 180,
  });

  final String imagePath;
  final ScanResultMatch match;
  final bool showTitle;
  final double previewHeight;

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
            if (showTitle) ...[
              Text(
                AppLocalizations.of(context).resultZoomedArea,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ColoredBox(
                color: Colors.black,
                child: SizedBox(
                  height: previewHeight,
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
