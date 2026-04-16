import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:allergyguard/core/allergen_patterns/allergen_ocr_match_extractor.dart';
import 'package:allergyguard/core/allergen_patterns/allergen_pattern_engine.dart';
import 'package:allergyguard/core/ocr/ocr_service.dart';
import 'package:allergyguard/core/allergen_patterns/pattern_repository.dart';
import 'package:allergyguard/core/scanner/barcode_scanner.dart';
import 'package:allergyguard/core/scanner/camera_controller.dart';
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
  int _analysisFrameIndex = 0;
  Set<String> _selectedAllergenKeys = <String>{};
  Map<String, List<String>> _allergenNamesByKey = <String, List<String>>{};
  Map<String, Map<String, String>> _allergenTranslationsByKey =
      <String, Map<String, String>>{};
  Map<String, String> _localizedAllergenNames = <String, String>{};

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
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: previewSize.height,
              height: previewSize.width,
              child: CameraPreview(controller),
            ),
          ),
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
        : l10n.scannerPointCamera;

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
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black54,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const HistoryScreen(),
                ),
              ),
            ),
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

  Future<void> _loadScannerConfig() async {
    final allergens = await _allergenRepository.getAllAllergens();
    final selectedKeys = await _allergenRepository.getSelectedAllergenKeys();
    final languageCode = await _preferences.getInterfaceLanguage();
    await _patternRepository.loadLocalPatterns();

    final allergenNamesByKey = <String, List<String>>{
      for (final allergen in allergens) allergen.nameKey: allergen.allNames,
    };
    final allergenTranslationsByKey = <String, Map<String, String>>{
      for (final allergen in allergens) allergen.nameKey: allergen.names,
    };
    final localizedAllergenNames = <String, String>{
      for (final allergen in allergens)
        allergen.nameKey: allergen.localizedName(languageCode),
    };

    if (!mounted) return;
    setState(() {
      _selectedAllergenKeys = selectedKeys.toSet();
      _allergenNamesByKey = allergenNamesByKey;
      _allergenTranslationsByKey = allergenTranslationsByKey;
      _localizedAllergenNames = localizedAllergenNames;
      _isLoadingScannerConfig = false;
    });

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

        final shouldAnalyzeBarcode = _analysisFrameIndex.isEven;
        _analysisFrameIndex++;

        if (shouldAnalyzeBarcode) {
          final barcodeResult = await _tryDetectBarcodeResult(
            image,
            scanner: barcodeScanner,
          );
          if (!mounted || _isPresentingResult || barcodeResult == null) {
            return;
          }
          await _presentResult(barcodeResult);
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
        barcode == _lastBarcode) {
      return null;
    }

    setState(() => _lastBarcode = barcode);
    final product = await ref.read(openFoodFactsProvider).getByBarcode(barcode);
    if (!mounted || _isPresentingResult || product == null) {
      return null;
    }

    return _buildBarcodeResult(product);
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

    return _buildOcrResult(result);
  }

  Future<ScanResult?> _buildOcrResult(OcrResult liveResult) async {
    final recognizedText = liveResult.text.trim();
    final signature = _normalizeText(recognizedText);
    if (signature.length < 12 || signature == _lastOcrSignature) {
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
      return null;
    }

    _lastOcrSignature = signature;
    final detailedResult = await _captureStillOcrResult();
    final finalOcrResult = detailedResult?.text.trim().isNotEmpty == true
        ? detailedResult!
        : liveResult;
    final finalText = finalOcrResult.text.trim();
    final finalAnalysis = engine.analyze(
      ocrText: finalText,
      userAllergenKeys: _selectedAllergenKeys.toList(),
    );
    final matches = _ocrMatchExtractor.extract(
      ocrResult: finalOcrResult,
      selectedAllergenKeys: _selectedAllergenKeys,
      allergenTranslationsByKey: _allergenTranslationsByKey,
      localizedAllergenNames: _localizedAllergenNames,
      singleBestMatchPerAllergen: true,
    );

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
      final imagePath = await _cameraController.takePicturePath();
      if (imagePath == null || imagePath.isEmpty) return null;
      return await ref.read(ocrServiceProvider).processFile(imagePath);
    } catch (_) {
      return null;
    }
  }

  ScanResult _buildBarcodeResult(Product product) {
    final directAllergens =
        product.allergenKeys.where(_selectedAllergenKeys.contains).toList();
    final traceAllergens = product.tracesKeys
        .where(
          (allergen) =>
              _selectedAllergenKeys.contains(allergen) &&
              !directAllergens.contains(allergen),
        )
        .toList();

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
    await _startAutoAnalysis();
  }

  Future<void> _stopAnalysisStream({required bool clearPreview}) async {
    await _cameraController.stopImageStream();
    if (!mounted) return;
    setState(() {
      _isAnalysisStreamActive = false;
      _analysisFrameIndex = 0;
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
        const SnackBar(
          content: Text('Luce LED non disponibile su questo dispositivo'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
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
  });

  final bool isEnabled;
  final bool isAvailable;
  final VoidCallback onPressed;

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
            ? 'Disattiva luce LED'
            : isAvailable
                ? 'Attiva luce LED'
                : 'Luce LED non disponibile',
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
