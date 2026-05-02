import 'dart:ui';

import 'package:allergyguard/core/constants.dart';
import 'package:allergyguard/core/ocr/mlkit_ocr.dart';
import 'package:allergyguard/core/ocr/cloud_vision_ocr.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrTextElementData {
  const OcrTextElementData({
    required this.text,
    this.boundingBox,
  });

  final String text;
  final Rect? boundingBox;
}

class OcrTextLineData {
  const OcrTextLineData({
    required this.text,
    this.boundingBox,
    this.elements = const <OcrTextElementData>[],
  });

  final String text;
  final Rect? boundingBox;
  final List<OcrTextElementData> elements;
}

/// Risultato di una operazione OCR.
class OcrResult {
  const OcrResult({
    required this.text,
    required this.confidence,
    required this.source,
    this.lines = const <OcrTextLineData>[],
    this.imagePath,
  });
  final String text;
  final double confidence;
  final OcrSource source;
  final List<OcrTextLineData> lines;
  final String? imagePath;

  bool get isEmpty => text.trim().isEmpty;
}

enum OcrSource { mlKit, cloudVision }

/// Facade OCR: prova ML Kit on-device, fallback a Cloud Vision.
class OcrService {
  OcrService({
    required MlKitOcr mlKitOcr,
    required CloudVisionOcr cloudVisionOcr,
  })  : _mlKitOcr = mlKitOcr,
        _cloudVisionOcr = cloudVisionOcr;
  final MlKitOcr _mlKitOcr;
  final CloudVisionOcr _cloudVisionOcr;

  /// Esegue OCR su un frame della camera.
  /// Se ML Kit restituisce confidence < soglia, usa Cloud Vision come fallback.
  Future<OcrResult> processImage(CameraImage image) async {
    return processImageWithRotation(
      image,
      rotation: InputImageRotation.rotation0deg,
    );
  }

  Future<OcrResult> processImageWithRotation(
    CameraImage image, {
    required InputImageRotation rotation,
  }) async {
    final mlKitResult = await _mlKitOcr.processImageWithRotation(
      image,
      rotation: rotation,
    );

    // ML Kit affidabile: nessun fallback necessario.
    if (mlKitResult.confidence >= AppConstants.ocrMinConfidence) {
      return mlKitResult;
    }

    // ML Kit poco affidabile e Cloud Vision non configurato: ritorna ML Kit.
    if (!_cloudVisionOcr.isConfigured) {
      return mlKitResult;
    }

    // Fallback a Cloud Vision per testo a bassa confidence o assente.
    try {
      final cloudResult = await _cloudVisionOcr.processImage(image);
      // Se Cloud Vision restituisce piu' testo o testo non vuoto, preferiscilo.
      if (cloudResult.text.trim().length > mlKitResult.text.trim().length) {
        return cloudResult;
      }
      return cloudResult.text.trim().isNotEmpty ? cloudResult : mlKitResult;
    } catch (_) {
      return mlKitResult;
    }
  }

  /// Esegue OCR su un file immagine (es. da galleria o still capture).
  Future<OcrResult> processFile(String filePath) async {
    final mlKitResult = await _mlKitOcr.processFile(filePath);

    if (mlKitResult.confidence >= AppConstants.ocrMinConfidence) {
      return mlKitResult;
    }
    if (!_cloudVisionOcr.isConfigured) {
      return mlKitResult;
    }

    try {
      final cloudResult = await _cloudVisionOcr.processFile(filePath);
      if (cloudResult.text.trim().length > mlKitResult.text.trim().length) {
        return cloudResult;
      }
      return cloudResult.text.trim().isNotEmpty ? cloudResult : mlKitResult;
    } catch (_) {
      return mlKitResult;
    }
  }

  void dispose() {
    _mlKitOcr.dispose();
  }
}
