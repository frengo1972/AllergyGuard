import 'package:allergyguard/core/constants.dart';
import 'package:allergyguard/core/ocr/mlkit_ocr.dart';
import 'package:allergyguard/core/ocr/cloud_vision_ocr.dart';
import 'package:camera/camera.dart';

/// Risultato di una operazione OCR.
class OcrResult {
  final String text;
  final double confidence;
  final OcrSource source;

  const OcrResult({
    required this.text,
    required this.confidence,
    required this.source,
  });

  bool get isEmpty => text.trim().isEmpty;
}

enum OcrSource { mlKit, cloudVision }

/// Facade OCR: prova ML Kit on-device, fallback a Cloud Vision.
class OcrService {
  final MlKitOcr _mlKitOcr;
  final CloudVisionOcr _cloudVisionOcr;

  OcrService({
    required MlKitOcr mlKitOcr,
    required CloudVisionOcr cloudVisionOcr,
  })  : _mlKitOcr = mlKitOcr,
        _cloudVisionOcr = cloudVisionOcr;

  /// Esegue OCR su un frame della camera.
  /// Se ML Kit restituisce confidence < soglia, usa Cloud Vision come fallback.
  Future<OcrResult> processImage(CameraImage image) async {
    final mlKitResult = await _mlKitOcr.processImage(image);

    if (mlKitResult.confidence >= AppConstants.ocrMinConfidence) {
      return mlKitResult;
    }

    // Fallback a Cloud Vision
    try {
      final cloudResult = await _cloudVisionOcr.processImage(image);
      return cloudResult;
    } catch (_) {
      // Se Cloud Vision fallisce, ritorna comunque il risultato ML Kit
      return mlKitResult;
    }
  }

  /// Esegue OCR su un file immagine (es. da galleria).
  Future<OcrResult> processFile(String filePath) async {
    final mlKitResult = await _mlKitOcr.processFile(filePath);

    if (mlKitResult.confidence >= AppConstants.ocrMinConfidence) {
      return mlKitResult;
    }

    try {
      final cloudResult = await _cloudVisionOcr.processFile(filePath);
      return cloudResult;
    } catch (_) {
      return mlKitResult;
    }
  }

  void dispose() {
    _mlKitOcr.dispose();
  }
}
