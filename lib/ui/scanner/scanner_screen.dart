import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:allergyguard/core/allergen_patterns/allergen_ocr_match_extractor.dart';
import 'package:allergyguard/core/allergen_patterns/allergen_pattern_engine.dart';
import 'package:allergyguard/core/constants.dart';
import 'package:allergyguard/core/ocr/ocr_service.dart';
import 'package:allergyguard/core/allergen_patterns/pattern_repository.dart';
import 'package:allergyguard/core/scanner/barcode_scanner.dart';
import 'package:allergyguard/core/scanner/camera_controller.dart';
import 'package:allergyguard/core/scanner/product_image_ocr_service.dart';
import 'package:allergyguard/data/local/local_allergen_repository.dart';
import 'package:allergyguard/data/local/local_preferences_service.dart';
import 'package:allergyguard/domain/models/product.dart';
import 'package:allergyguard/domain/models/scan_result.dart';
import 'package:allergyguard/l10n/app_localizations.dart';
import 'package:allergyguard/providers.dart';
import 'package:allergyguard/ui/history/history_screen.dart';
import 'package:allergyguard/ui/result/result_screen.dart';
import 'package:allergyguard/ui/settings/settings_screen.dart';

/// Schermata principale dello scanner.
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final AppCameraController _cameraController = AppCameraController();
  final AllergenOcrMatchExtractor _ocrMatchExtractor =
      const AllergenOcrMatchExtractor();
  final PatternRepository _patternRepository = PatternRepository();
  final LocalAllergenRepository _allergenRepository = LocalAllergenRepository();
  final LocalPreferencesService _preferences = LocalPreferencesService();

  bool _isInitializingCamera = true;
  bool _isAnalysisStreamActive = false;
  bool _isLoadingScannerConfig = true;
  bool _isPresentingResult = false;
  bool _hasCameraPermissionIssue = false;
  bool _isTorchAvailable = false;
  bool _isTorchEnabled = false;
  String? _cameraError;
  String? _lastBarcode;
  String? _lastOcrSignature;
  DateTime? _lastBarcodeSeenAt;
  DateTime? _lastOcrSeenAt;
  String? _liveFeedback;
  String _languageCode = 'it';
  int _analysisFrameIndex = 0;
  Set<String> _selectedAllergenKeys = <String>{};
  Map<String, List<String>> _allergenNamesByKey = <String, List<String>>{};
  Map<String, Map<String, List<String>>> _allergenTermsByKey =
      <String, Map<String, List<String>>>{};
  Map<String, String> _localizedAllergenNames = <String, String>{};

  // Auto-still capture state
  Timer? _autoStillTimer;
  bool _isAutoStillRunning = false;
  String? _lastStillImagePath;
  String? _lastStillOcrText;
  double? _lastStillOcrConfidence;
  bool _isManualCaptureBusy = false;
  Offset? _focusIndicatorPoint;
  Timer? _focusIndicatorTimer;

  @override
  void initState() {
    super.initState();
    _loadScannerConfig();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildCameraPreview(),
          _buildTopBar(),
          _buildStatusOverlay(),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isInitializingCamera) {
      return const ColoredBox(
        color: Color(0xFF111827),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final l10n = AppLocalizations.of(context);
    if (_cameraController.isInitialized &&
        _cameraController.controller != null) {
      final controller = _cameraController.controller!;
      final previewSize = controller.value.previewSize;

      if (previewSize == null) {
        return const ColoredBox(
          color: Colors.black,
          child: SizedBox.expand(),
        );
      }

      return ColoredBox(
        color: Colors.black,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => _handlePreviewTap(
                details.localPosition,
                Size(constraints.maxWidth, constraints.maxHeight),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: previewSize.height,
                      height: previewSize.width,
                      child: CameraPreview(controller),
                    ),
                  ),
                  if (_focusIndicatorPoint != null)
                    Positioned(
                      left: _focusIndicatorPoint!.dx - 32,
                      top: _focusIndicatorPoint!.dy - 32,
                      child: IgnorePointer(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.amberAccent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );
    }

    return ColoredBox(
      color: const Color(0xFF111827),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 72,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.scannerNoCamera,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _cameraError ?? l10n.scannerCameraErrorDefault,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _initializeCamera,
                child: Text(l10n.scannerRetry),
              ),
              if (_hasCameraPermissionIssue) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: openAppSettings,
                  child: Text(l10n.scannerOpenAppSettings),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final l10n = AppLocalizations.of(context);
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 64),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                _ScannerPill(
                  icon: Icons.qr_code_scanner,
                  label: l10n.scannerPillAuto,
                ),
                _ScannerPill(
                  icon: Icons.document_scanner_outlined,
                  label: l10n.scannerPillBarcodeOcr,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _TorchButton(
              isEnabled: _isTorchEnabled,
              isAvailable: _isTorchAvailable,
              onPressed: _toggleTorch,
              tooltipOn: l10n.scannerTorchToggleOff,
              tooltipOff: l10n.scannerTorchToggleOn,
              tooltipUnavailable: l10n.scannerTorchUnavailable,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOverlay() {
    final l10n = AppLocalizations.of(context);
    final text = _selectedAllergenKeys.isEmpty
        ? l10n.scannerNoAllergenSelected
        : _buildLiveStatusText(l10n);

    return Positioned(
      bottom: 120,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          maxLines: 8,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black54,
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const HistoryScreen(),
                ),
              ),
            ),
            _buildLastStillThumbnail(),
            _buildManualCaptureButton(),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () async {
                await _stopAnalysisStream(clearPreview: false);
                if (!mounted) return;
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
                await _loadScannerConfig();
                await _startAutoAnalysis();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastStillThumbnail() {
    final path = _lastStillImagePath;
    if (path == null) {
      return const SizedBox(width: 56, height: 56);
    }
    return GestureDetector(
      onTap: _openStillReview,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white70, width: 1),
          image: DecorationImage(
            image: FileImage(File(path)),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildManualCaptureButton() {
    return GestureDetector(
      onTap: _isManualCaptureBusy ? null : _handleManualCapture,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: _isManualCaptureBusy ? Colors.amber : Colors.white,
            width: 4,
          ),
        ),
        child: _isManualCaptureBusy
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Colors.amber),
                ),
              )
            : const Icon(Icons.camera_alt, color: Colors.black, size: 28),
      ),
    );
  }

  Future<void> _loadScannerConfig() async {
    final allergens = await _allergenRepository.getAllAllergens();
    final selectedKeys = await _allergenRepository.getSelectedAllergenKeys();
    final languageCode = await _preferences.getInterfaceLanguage();
    await _patternRepository.loadLocalPatterns();

    final allergenNamesByKey = <String, List<String>>{
      for (final allergen in allergens) allergen.nameKey: allergen.allNames,
    };
    final allergenTermsByKey = <String, Map<String, List<String>>>{
      for (final allergen in allergens)
        allergen.nameKey: allergen.searchableTermsByLanguage,
    };
    final localizedAllergenNames = <String, String>{
      for (final allergen in allergens)
        allergen.nameKey: allergen.localizedName(languageCode),
    };

    if (!mounted) return;
    setState(() {
      _selectedAllergenKeys = selectedKeys.toSet();
      _allergenNamesByKey = allergenNamesByKey;
      _allergenTermsByKey = allergenTermsByKey;
      _localizedAllergenNames = localizedAllergenNames;
      _languageCode = languageCode;
      _isLoadingScannerConfig = false;
    });
    _clearRecentDetections();

    if (_selectedAllergenKeys.isNotEmpty) {
      _setLiveFeedback(AppLocalizations.of(context).scannerAnalysisActive);
    }

    await _startAutoAnalysis();
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializingCamera = true;
      _hasCameraPermissionIssue = false;
      _cameraError = null;
    });

    final l10n = AppLocalizations.of(context);
    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      if (!mounted) return;
      setState(() {
        _isInitializingCamera = false;
        _hasCameraPermissionIssue = true;
        _cameraError = permission.isPermanentlyDenied
            ? l10n.scannerCameraPermissionPermanent
            : l10n.scannerCameraPermissionNeeded;
      });
      return;
    }

    try {
      await _cameraController.initialize();
      if (!mounted) return;
      setState(() {
        _isInitializingCamera = false;
        _hasCameraPermissionIssue = false;
        _syncTorchState();
        if (!_cameraController.isInitialized) {
          _cameraError = l10n.scannerCameraNone;
        }
      });
      _clearRecentDetections();
      _setLiveFeedback(AppLocalizations.of(context).scannerAnalysisActive);
      await _startAutoAnalysis();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isInitializingCamera = false;
        _hasCameraPermissionIssue = false;
        _isTorchAvailable = false;
        _isTorchEnabled = false;
        _cameraError = l10n.scannerCameraInitError(error.toString());
      });
    }
  }

  Future<void> _startAutoAnalysis() async {
    if (_isInitializingCamera ||
        _isLoadingScannerConfig ||
        !_cameraController.isInitialized ||
        _isPresentingResult ||
        _isAnalysisStreamActive) {
      return;
    }

    final barcodeScanner = ref.read(barcodeScannerProvider);
    final ocrService = ref.read(ocrServiceProvider);

    setState(() {
      _isAnalysisStreamActive = true;
      _analysisFrameIndex = 0;
    });

    try {
      await _cameraController.startImageStream((image) async {
        if (!mounted || _isPresentingResult || _selectedAllergenKeys.isEmpty) {
          return;
        }

        final shouldAnalyzeOcr = _analysisFrameIndex.isEven;
        _analysisFrameIndex++;

        final barcodeResult = await _tryDetectBarcodeResult(
          image,
          scanner: barcodeScanner,
        );
        if (!mounted || _isPresentingResult) {
          return;
        }
        if (barcodeResult != null) {
          await _presentResult(barcodeResult);
          return;
        }

        if (!shouldAnalyzeOcr) {
          return;
        }
        final ocrResult = await _tryDetectOcrResult(
          image,
          ocrService: ocrService,
        );
        if (!mounted || _isPresentingResult || ocrResult == null) {
          return;
        }
        await _presentResult(ocrResult);
      });
      _startAutoStillTimer();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isAnalysisStreamActive = false;
        _hasCameraPermissionIssue = false;
        _cameraError = AppLocalizations.of(context).scannerAutoAnalysisError(
          error.toString(),
        );
      });
    }
  }

  Future<ScanResult?> _tryDetectBarcodeResult(
    CameraImage image, {
    required BarcodeScannerService scanner,
  }) async {
    final barcode = await scanner.scanFromCamera(
      image,
      rotation: _currentInputImageRotation(),
    );

    if (!mounted ||
        _isPresentingResult ||
        barcode == null ||
        barcode.isEmpty ||
        _shouldSkipRecentBarcode(barcode)) {
      return null;
    }

    _setLiveFeedback(
      AppLocalizations.of(context).scannerLiveBarcodeDetected(barcode),
    );
    final product = await ref.read(openFoodFactsProvider).getByBarcode(barcode);
    if (!mounted || _isPresentingResult) {
      return null;
    }
    if (product == null) {
      _rememberBarcode(barcode);
      _setLiveFeedback(
        AppLocalizations.of(context).scannerLiveBarcodeUnknown,
      );
      return null;
    }

    _rememberBarcode(barcode);
    return await _buildBarcodeResult(product);
  }

  Future<ScanResult?> _tryDetectOcrResult(
    CameraImage image, {
    required OcrService ocrService,
  }) async {
    final result = await ocrService.processImageWithRotation(
      image,
      rotation: _currentInputImageRotation(),
    );

    if (!mounted || _isPresentingResult) {
      return null;
    }

    final recognizedText = result.text.trim();
    if (recognizedText.isEmpty) {
      return null;
    }

    _setLiveFeedback(
      AppLocalizations.of(context)
          .scannerLiveTextRead(_truncatePreview(recognizedText)),
    );

    return _buildOcrResult(result);
  }

  Future<ScanResult?> _buildOcrResult(OcrResult liveResult) async {
    final recognizedText = liveResult.text.trim();
    final signature = _normalizeText(recognizedText);
    if (signature.length < 12 || _shouldSkipRecentOcrSignature(signature)) {
      return null;
    }

    final engine = AllergenPatternEngine(
      verifiedPatterns: _patternRepository.verifiedPatterns,
      allergenNames: _allergenNamesByKey,
    );
    final analysis = engine.analyze(
      ocrText: recognizedText,
      userAllergenKeys: _selectedAllergenKeys.toList(),
    );

    if (analysis.level != ScanResultLevel.danger &&
        analysis.level != ScanResultLevel.warning) {
      _setLiveFeedback(
        AppLocalizations.of(context).scannerLiveNoAllergenInText,
      );
      return null;
    }

    _rememberOcrSignature(signature);
    final liveMatches = _ocrMatchExtractor.extract(
      ocrResult: liveResult,
      selectedAllergenKeys: _selectedAllergenKeys,
      allergenTermsByKey: _allergenTermsByKey,
      localizedAllergenNames: _localizedAllergenNames,
      singleBestMatchPerAllergen: true,
    );

    OcrResult finalOcrResult = liveResult;
    ScanResult finalAnalysis = analysis;
    List<ScanResultMatch> matches = liveMatches;

    if (_shouldCaptureStillConfirmation(
      liveResult: liveResult,
      liveMatches: liveMatches,
    )) {
      _setLiveFeedback(
        AppLocalizations.of(context).scannerLivePossibleAllergen,
      );
      final detailedResult = await _captureStillOcrResult();
      if (detailedResult?.text.trim().isNotEmpty == true) {
        finalOcrResult = detailedResult!;
        final finalText = finalOcrResult.text.trim();
        finalAnalysis = engine.analyze(
          ocrText: finalText,
          userAllergenKeys: _selectedAllergenKeys.toList(),
        );
        matches = _ocrMatchExtractor.extract(
          ocrResult: finalOcrResult,
          selectedAllergenKeys: _selectedAllergenKeys,
          allergenTermsByKey: _allergenTermsByKey,
          localizedAllergenNames: _localizedAllergenNames,
          singleBestMatchPerAllergen: true,
        );
      }
    }

    final finalText = finalOcrResult.text.trim();
    if (finalAnalysis.level != ScanResultLevel.danger &&
        finalAnalysis.level != ScanResultLevel.warning) {
      if (!mounted) return null;
      _setLiveFeedback(
        AppLocalizations.of(context).scannerLiveConfirmedNoMatch,
      );
      return null;
    }

    if (matches.isEmpty) {
      matches = _ocrMatchExtractor.extract(
        ocrResult: finalOcrResult,
        selectedAllergenKeys: _selectedAllergenKeys,
        allergenTermsByKey: _allergenTermsByKey,
        localizedAllergenNames: _localizedAllergenNames,
        singleBestMatchPerAllergen: true,
      );
    }

    return ScanResult(
      level: finalAnalysis.level,
      allergens: _localizeAllergenKeys(finalAnalysis.allergens),
      ocrText: finalText,
      highlightTerms: matches.map((match) => match.matchedText).toSet().toList()
        ..sort((left, right) => right.length.compareTo(left.length)),
      matches: matches,
      referenceImagePath: finalOcrResult.imagePath,
      confidence: finalOcrResult.confidence,
    );
  }

  Future<OcrResult?> _captureStillOcrResult() async {
    try {
      final imagePath = await _cameraController.takePicturePath().timeout(
            const Duration(
              milliseconds: AppConstants.scannerStillCaptureTimeoutMs,
            ),
          );
      if (imagePath == null || imagePath.isEmpty) return null;
      return await ref.read(ocrServiceProvider).processFile(imagePath).timeout(
            const Duration(
              milliseconds: AppConstants.scannerStillCaptureTimeoutMs,
            ),
          );
    } catch (_) {
      return null;
    }
  }

  Future<ScanResult> _buildBarcodeResult(Product product) async {
    final directAllergens =
        product.allergenKeys.where(_selectedAllergenKeys.contains).toList();
    final traceAllergens = product.tracesKeys
        .where(
          (allergen) =>
              _selectedAllergenKeys.contains(allergen) &&
              !directAllergens.contains(allergen),
        )
        .toList();

    if (directAllergens.isEmpty &&
        traceAllergens.isEmpty &&
        product.labelImageCandidates.isNotEmpty) {
      _setLiveFeedback(
        AppLocalizations.of(context).scannerLiveProductTagsIncomplete,
      );
      final imageOcrResult = await _buildProductImageOcrBarcodeResult(product);
      if (imageOcrResult != null) {
        return imageOcrResult;
      }
    }

    return _buildStructuredBarcodeResult(
      product,
      directAllergens: directAllergens,
      traceAllergens: traceAllergens,
    );
  }

  ScanResult _buildStructuredBarcodeResult(
    Product product, {
    required List<String> directAllergens,
    required List<String> traceAllergens,
  }) {
    final level = directAllergens.isNotEmpty
        ? ScanResultLevel.danger
        : traceAllergens.isNotEmpty
            ? ScanResultLevel.warning
            : ScanResultLevel.safe;

    final detectedAllergens =
        directAllergens.isNotEmpty ? directAllergens : traceAllergens;

    return ScanResult(
      level: level,
      allergens: _localizeAllergenKeys(detectedAllergens),
      ocrText: product.ingredientsText,
      highlightTerms: _extractHighlightTerms(
        detectedAllergens,
        product.ingredientsText,
      ),
      barcode: product.barcode,
      productName: product.name.isEmpty ? null : product.name,
      brand: product.brand.isEmpty ? null : product.brand,
      confidence: 1.0,
    );
  }

  Future<ScanResult?> _buildProductImageOcrBarcodeResult(
    Product product,
  ) async {
    final imageResults = await _readProductLabelImages(product);
    if (imageResults.isEmpty) return null;

    final engine = AllergenPatternEngine(
      verifiedPatterns: _patternRepository.verifiedPatterns,
      allergenNames: _allergenNamesByKey,
    );

    for (final imageResult in imageResults) {
      final imageText = imageResult.ocrResult.text.trim();
      if (imageText.isEmpty) continue;

      final analysis = engine.analyze(
        ocrText: imageText,
        userAllergenKeys: _selectedAllergenKeys.toList(),
      );
      if (analysis.level != ScanResultLevel.danger &&
          analysis.level != ScanResultLevel.warning) {
        continue;
      }

      var matches = _ocrMatchExtractor.extract(
        ocrResult: imageResult.ocrResult,
        selectedAllergenKeys: _selectedAllergenKeys,
        allergenTermsByKey: _allergenTermsByKey,
        localizedAllergenNames: _localizedAllergenNames,
        singleBestMatchPerAllergen: true,
      );
      if (matches.isEmpty) {
        matches = const <ScanResultMatch>[];
      }

      final highlightTerms = matches
          .map((match) => match.matchedText)
          .where((term) => term.trim().isNotEmpty)
          .toSet()
          .toList()
        ..addAll(analysis.highlightTerms)
        ..sort((left, right) => right.length.compareTo(left.length));

      return ScanResult(
        level: analysis.level,
        allergens: _localizeAllergenKeys(analysis.allergens),
        ocrText: _mergeProductAndImageText(
          product.ingredientsText,
          imageText,
        ),
        highlightTerms: highlightTerms,
        matches: matches,
        referenceImagePath: imageResult.ocrResult.imagePath,
        barcode: product.barcode,
        productName: product.name.isEmpty ? null : product.name,
        brand: product.brand.isEmpty ? null : product.brand,
        confidence: imageResult.ocrResult.confidence,
      );
    }

    if (!mounted) return null;
    _setLiveFeedback(
      AppLocalizations.of(context).scannerLiveImageNoMatch,
    );
    return null;
  }

  Future<List<ProductImageOcrResult>> _readProductLabelImages(
    Product product,
  ) async {
    try {
      return await ref
          .read(productImageOcrServiceProvider)
          .processLabelImages(
            product,
            maxImages: AppConstants.offImageOcrMaxImages,
            preferredLanguageCode: _languageCode,
          )
          .timeout(
            const Duration(milliseconds: AppConstants.offImageOcrTimeoutMs),
          );
    } catch (_) {
      return const <ProductImageOcrResult>[];
    }
  }

  String _mergeProductAndImageText(String productText, String imageText) {
    final structuredText = productText.trim();
    final ocrText = imageText.trim();
    if (structuredText.isEmpty) return ocrText;
    if (ocrText.isEmpty ||
        _normalizeText(structuredText) == _normalizeText(ocrText)) {
      return structuredText;
    }
    final header = AppLocalizations.of(context).scannerOffImageTextHeader;
    return '$structuredText\n\n$header\n$ocrText';
  }

  Future<void> _presentResult(ScanResult result) async {
    if (_isPresentingResult) return;

    setState(() {
      _isPresentingResult = true;
    });
    await _stopAnalysisStream(clearPreview: false);
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(result: result),
      ),
    );

    if (!mounted) return;
    setState(() {
      _isPresentingResult = false;
    });
    _setLiveFeedback(AppLocalizations.of(context).scannerAnalysisActive);
    await _startAutoAnalysis();
  }

  Future<void> _stopAnalysisStream({required bool clearPreview}) async {
    _stopAutoStillTimer();
    await _cameraController.stopImageStream();
    if (!mounted) return;
    setState(() {
      _isAnalysisStreamActive = false;
      _analysisFrameIndex = 0;
    });
  }

  void _startAutoStillTimer() {
    _autoStillTimer?.cancel();
    _autoStillTimer = Timer.periodic(
      const Duration(milliseconds: AppConstants.scannerAutoStillIntervalMs),
      (_) => _runAutoStillCapture(),
    );
  }

  void _stopAutoStillTimer() {
    _autoStillTimer?.cancel();
    _autoStillTimer = null;
  }

  Future<void> _runAutoStillCapture() async {
    if (!mounted ||
        _isPresentingResult ||
        _isAutoStillRunning ||
        _isManualCaptureBusy ||
        _selectedAllergenKeys.isEmpty ||
        !_cameraController.isInitialized) {
      return;
    }
    _isAutoStillRunning = true;
    try {
      final scanResult = await _captureAndAnalyzeStill();
      if (!mounted || _isPresentingResult) return;
      if (scanResult != null) {
        await _presentResult(scanResult);
      }
    } finally {
      _isAutoStillRunning = false;
    }
  }

  Future<void> _handleManualCapture() async {
    if (_isManualCaptureBusy ||
        _isPresentingResult ||
        !_cameraController.isInitialized) {
      return;
    }
    setState(() => _isManualCaptureBusy = true);
    try {
      final scanResult = await _captureAndAnalyzeStill(forceReview: true);
      if (!mounted) return;
      if (scanResult != null && !_isPresentingResult) {
        await _presentResult(scanResult);
      } else {
        _setLiveFeedback(
          AppLocalizations.of(context).scannerLiveStillCapturedReview,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isManualCaptureBusy = false);
      }
    }
  }

  /// Esegue uno scatto a piena risoluzione, salva path/OCR per la review,
  /// e prova a costruire un ScanResult se vengono rilevati allergeni utente.
  Future<ScanResult?> _captureAndAnalyzeStill({bool forceReview = false}) async {
    try {
      final imagePath = await _cameraController
          .captureStillKeepingStream()
          .timeout(
            const Duration(
              milliseconds: AppConstants.scannerAutoStillTimeoutMs,
            ),
          );
      if (imagePath == null || imagePath.isEmpty || !mounted) return null;

      final ocrResult = await ref
          .read(ocrServiceProvider)
          .processFile(imagePath)
          .timeout(
            const Duration(
              milliseconds: AppConstants.scannerAutoStillTimeoutMs,
            ),
          );
      if (!mounted) return null;

      setState(() {
        _lastStillImagePath = imagePath;
        _lastStillOcrText = ocrResult.text;
        _lastStillOcrConfidence = ocrResult.confidence;
      });

      if (_selectedAllergenKeys.isEmpty) return null;

      final recognizedText = ocrResult.text.trim();
      if (recognizedText.isEmpty) return null;

      final engine = AllergenPatternEngine(
        verifiedPatterns: _patternRepository.verifiedPatterns,
        allergenNames: _allergenNamesByKey,
      );
      final analysis = engine.analyze(
        ocrText: recognizedText,
        userAllergenKeys: _selectedAllergenKeys.toList(),
      );

      if (analysis.level != ScanResultLevel.danger &&
          analysis.level != ScanResultLevel.warning) {
        if (forceReview) {
          _setLiveFeedback(
            AppLocalizations.of(context).scannerLiveStillNoMatch,
          );
        }
        return null;
      }

      final signature = _normalizeText(recognizedText);
      if (!forceReview &&
          signature.length >= 12 &&
          _shouldSkipRecentOcrSignature(signature)) {
        return null;
      }
      _rememberOcrSignature(signature);

      final matches = _ocrMatchExtractor.extract(
        ocrResult: ocrResult,
        selectedAllergenKeys: _selectedAllergenKeys,
        allergenTermsByKey: _allergenTermsByKey,
        localizedAllergenNames: _localizedAllergenNames,
        singleBestMatchPerAllergen: true,
      );

      return ScanResult(
        level: analysis.level,
        allergens: _localizeAllergenKeys(analysis.allergens),
        ocrText: recognizedText,
        highlightTerms: matches.map((m) => m.matchedText).toSet().toList()
          ..sort((a, b) => b.length.compareTo(a.length)),
        matches: matches,
        referenceImagePath: imagePath,
        confidence: ocrResult.confidence,
      );
    } catch (_) {
      return null;
    }
  }

  void _openStillReview() {
    final path = _lastStillImagePath;
    if (path == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _StillReviewScreen(
          imagePath: path,
          ocrText: _lastStillOcrText ?? '',
          confidence: _lastStillOcrConfidence,
        ),
      ),
    );
  }

  Future<void> _handlePreviewTap(Offset localPosition, Size widgetSize) async {
    if (!_cameraController.isInitialized || widgetSize.shortestSide <= 0) {
      return;
    }
    final normalized = Offset(
      (localPosition.dx / widgetSize.width).clamp(0.0, 1.0),
      (localPosition.dy / widgetSize.height).clamp(0.0, 1.0),
    );
    await _cameraController.setFocusAndExposurePoint(normalized);
    if (!mounted) return;
    setState(() => _focusIndicatorPoint = localPosition);
    _focusIndicatorTimer?.cancel();
    _focusIndicatorTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _focusIndicatorPoint = null);
    });
  }

  List<String> _localizeAllergenKeys(List<String> allergenKeys) {
    return allergenKeys
        .map((key) => _localizedAllergenNames[key] ?? key)
        .toList();
  }

  String _normalizeText(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _buildLiveStatusText(AppLocalizations l10n) {
    final headline = _liveFeedback ?? l10n.scannerAnalysisActive;
    return '$headline\n${l10n.scannerPointCamera}';
  }

  void _setLiveFeedback(String message) {
    if (!mounted || _liveFeedback == message) return;
    setState(() => _liveFeedback = message);
  }

  String _truncatePreview(String value) {
    final compact = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= 48) return compact;
    return '${compact.substring(0, 48)}...';
  }

  bool _shouldCaptureStillConfirmation({
    required OcrResult liveResult,
    required List<ScanResultMatch> liveMatches,
  }) {
    if (liveResult.confidence <
        AppConstants.scannerStillCaptureConfidenceThreshold) {
      return true;
    }
    if (liveMatches.isEmpty) {
      return true;
    }
    if (liveMatches
        .any((match) => match.boundingBox == null || match.isPartial)) {
      return true;
    }
    return false;
  }

  bool _shouldSkipRecentBarcode(String barcode) {
    if (_lastBarcode != barcode || _lastBarcodeSeenAt == null) {
      return false;
    }
    return DateTime.now().difference(_lastBarcodeSeenAt!).inMilliseconds <
        AppConstants.scannerDuplicateCooldownMs;
  }

  bool _shouldSkipRecentOcrSignature(String signature) {
    if (_lastOcrSignature != signature || _lastOcrSeenAt == null) {
      return false;
    }
    return DateTime.now().difference(_lastOcrSeenAt!).inMilliseconds <
        AppConstants.scannerDuplicateCooldownMs;
  }

  void _rememberBarcode(String barcode) {
    _lastBarcode = barcode;
    _lastBarcodeSeenAt = DateTime.now();
  }

  void _rememberOcrSignature(String signature) {
    _lastOcrSignature = signature;
    _lastOcrSeenAt = DateTime.now();
  }

  void _clearRecentDetections() {
    _lastBarcode = null;
    _lastOcrSignature = null;
    _lastBarcodeSeenAt = null;
    _lastOcrSeenAt = null;
  }

  List<String> _extractHighlightTerms(
    List<String> allergenKeys,
    String text,
  ) {
    if (text.trim().isEmpty) return const <String>[];

    final normalizedText = _normalizeText(text);
    final matches = <String>{};

    for (final key in allergenKeys) {
      for (final name in _allergenNamesByKey[key] ?? const <String>[]) {
        final normalizedName = _normalizeText(name);
        if (normalizedName.isNotEmpty &&
            _containsWholeNormalizedTerm(normalizedText, normalizedName)) {
          matches.add(name);
        }
      }
    }

    return matches.toList()
      ..sort((left, right) => right.length.compareTo(left.length));
  }

  InputImageRotation _currentInputImageRotation() {
    final sensorOrientation =
        _cameraController.description?.sensorOrientation ?? 0;
    return InputImageRotationValue.fromRawValue(sensorOrientation) ??
        InputImageRotation.rotation0deg;
  }

  bool _containsWholeNormalizedTerm(String text, String term) {
    var searchStart = 0;
    while (true) {
      final index = text.indexOf(term, searchStart);
      if (index < 0) return false;

      final beforeIndex = index - 1;
      final afterIndex = index + term.length;
      final isStartBoundary =
          beforeIndex < 0 || !_isAsciiLetterOrDigit(text[beforeIndex]);
      final isEndBoundary =
          afterIndex >= text.length || !_isAsciiLetterOrDigit(text[afterIndex]);

      if (isStartBoundary && isEndBoundary) {
        return true;
      }
      searchStart = index + 1;
    }
  }

  bool _isAsciiLetterOrDigit(String char) {
    final codeUnit = char.codeUnitAt(0);
    return (codeUnit >= 48 && codeUnit <= 57) ||
        (codeUnit >= 65 && codeUnit <= 90) ||
        (codeUnit >= 97 && codeUnit <= 122);
  }

  void _syncTorchState() {
    _isTorchAvailable = _cameraController.isTorchAvailable;
    _isTorchEnabled = _cameraController.isTorchEnabled;
  }

  Future<void> _toggleTorch() async {
    final success = await _cameraController.setTorchEnabled(!_isTorchEnabled);
    if (!mounted) return;

    setState(_syncTorchState);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).scannerTorchUnavailable),
        ),
      );
    }
  }

  @override
  void dispose() {
    _autoStillTimer?.cancel();
    _focusIndicatorTimer?.cancel();
    _cameraController.dispose();
    super.dispose();
  }
}

class _StillReviewScreen extends StatelessWidget {
  const _StillReviewScreen({
    required this.imagePath,
    required this.ocrText,
    required this.confidence,
  });

  final String imagePath;
  final String ocrText;
  final double? confidence;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final confidenceLabel = confidence == null
        ? '-'
        : '${(confidence! * 100).clamp(0, 100).toStringAsFixed(0)}%';
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n.scannerStillReviewTitle),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 6,
              child: Center(
                child: Image.file(File(imagePath)),
              ),
            ),
          ),
          Container(
            color: const Color(0xFF111827),
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.scannerStillReviewConfidence(confidenceLabel),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.scannerStillReviewRecognizedText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: SingleChildScrollView(
                    child: Text(
                      ocrText.isEmpty
                          ? l10n.scannerStillReviewEmptyText
                          : ocrText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerPill extends StatelessWidget {
  const _ScannerPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TorchButton extends StatelessWidget {
  const _TorchButton({
    required this.isEnabled,
    required this.isAvailable,
    required this.onPressed,
    required this.tooltipOn,
    required this.tooltipOff,
    required this.tooltipUnavailable,
  });

  final bool isEnabled;
  final bool isAvailable;
  final VoidCallback onPressed;
  final String tooltipOn;
  final String tooltipOff;
  final String tooltipUnavailable;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isEnabled
            ? const Color(0xFFFFF3CD)
            : isAvailable
                ? Colors.black54
                : Colors.black38,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isEnabled
              ? const Color(0xFFFFD54F)
              : isAvailable
                  ? Colors.white24
                  : Colors.white12,
        ),
      ),
      child: IconButton(
        constraints: const BoxConstraints.tightFor(width: 52, height: 52),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        tooltip: isEnabled
            ? tooltipOn
            : isAvailable
                ? tooltipOff
                : tooltipUnavailable,
        icon: Icon(
          isEnabled ? Icons.flash_on : Icons.flash_off,
          color: isEnabled
              ? const Color(0xFF8B5E00)
              : isAvailable
                  ? Colors.white
                  : Colors.white54,
          size: 20,
        ),
      ),
    );
  }
}
