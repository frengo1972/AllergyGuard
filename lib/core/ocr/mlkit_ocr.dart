import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'ocr_service.dart';

/// Implementazione OCR on-device con Google ML Kit Text Recognition v2.
///
/// Strategia automatica:
/// - Stream camera (frame preview, real-time): solo Latin per restare reattivo.
/// - Still capture (foto piena risoluzione): tutti gli script principali
///   (Latin + Chinese + Japanese + Korean) per coprire l'utente in viaggio
///   senza richiedere configurazione.
/// I recognizer non-latin sono creati lazy alla prima richiesta.
class MlKitOcr {
  MlKitOcr() {
    _recognizers[TextRecognitionScript.latin] =
        TextRecognizer(script: TextRecognitionScript.latin);
  }

  final Map<TextRecognitionScript, TextRecognizer> _recognizers = {};

  /// Script attivati per still capture. I recognizer CJK sono creati lazy e
  /// ignorati silenziosamente se i modelli non sono installati sul device.
  static const List<TextRecognitionScript> _stillCaptureScripts = [
    TextRecognitionScript.latin,
    TextRecognitionScript.chinese,
    TextRecognitionScript.japanese,
    TextRecognitionScript.korean,
  ];

  Future<OcrResult> processImage(CameraImage image) async {
    return processImageWithRotation(
      image,
      rotation: InputImageRotation.rotation0deg,
    );
  }

  /// OCR su frame stream (preview): solo Latin, ottimizzato per latenza.
  Future<OcrResult> processImageWithRotation(
    CameraImage image, {
    required InputImageRotation rotation,
  }) async {
    final inputImage = _convertCameraImage(
      image,
      rotation: rotation,
    );
    if (inputImage == null) {
      return const OcrResult(
          text: '', confidence: 0.0, source: OcrSource.mlKit);
    }
    return _runScripts(
      inputImage,
      const [TextRecognitionScript.latin],
    );
  }

  /// OCR su file (still capture o galleria): multi-script Latin+CJK.
  Future<OcrResult> processFile(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    return _runScripts(
      inputImage,
      _stillCaptureScripts,
      imagePath: filePath,
    );
  }

  /// Esegue gli script richiesti, sceglie il risultato migliore
  /// (testo non vuoto, lunghezza/confidence maggiori).
  Future<OcrResult> _runScripts(
    InputImage inputImage,
    List<TextRecognitionScript> scripts, {
    String? imagePath,
  }) async {

    OcrResult? best;
    for (final script in scripts) {
      try {
        final recognizer = _recognizers.putIfAbsent(
          script,
          () => TextRecognizer(script: script),
        );
        final result = await _recognize(
          inputImage,
          recognizer,
          imagePath: imagePath,
        );
        if (best == null || _isBetterResult(result, best)) {
          best = result;
        }
      } catch (_) {
        // Recognizer puo' fallire se script non installato sul device
        // (es. Chinese/Japanese/Korean non disponibili).
        continue;
      }
    }

    return best ??
        const OcrResult(text: '', confidence: 0.0, source: OcrSource.mlKit);
  }

  bool _isBetterResult(OcrResult candidate, OcrResult current) {
    final candidateLen = candidate.text.trim().length;
    final currentLen = current.text.trim().length;
    if (candidateLen == 0) return false;
    if (currentLen == 0) return true;
    // Preferisci il risultato con piu' testo significativo.
    if (candidateLen > currentLen * 1.2) return true;
    if (currentLen > candidateLen * 1.2) return false;
    // A parita' di lunghezza, vince la confidence piu' alta.
    return candidate.confidence > current.confidence;
  }

  Future<OcrResult> _recognize(
    InputImage inputImage,
    TextRecognizer recognizer, {
    String? imagePath,
  }) async {
    final recognizedText = await recognizer.processImage(inputImage);

    if (recognizedText.blocks.isEmpty) {
      return OcrResult(
        text: '',
        confidence: 0.0,
        source: OcrSource.mlKit,
        imagePath: imagePath,
      );
    }

    final fullText =
        recognizedText.blocks.map((block) => block.text).join('\n');

    double totalConfidence = 0;
    int lineCount = 0;
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        totalConfidence += line.confidence ?? 0.0;
        lineCount++;
      }
    }
    final avgConfidence = lineCount > 0 ? totalConfidence / lineCount : 0.0;
    final lines = recognizedText.blocks
        .expand(
          (block) => block.lines.map(
            (line) => OcrTextLineData(
              text: line.text,
              boundingBox: line.boundingBox,
              elements: line.elements
                  .map(
                    (element) => OcrTextElementData(
                      text: element.text,
                      boundingBox: element.boundingBox,
                    ),
                  )
                  .toList(),
            ),
          ),
        )
        .toList();

    return OcrResult(
      text: fullText,
      confidence: avgConfidence,
      source: OcrSource.mlKit,
      lines: lines,
      imagePath: imagePath,
    );
  }

  InputImage? _convertCameraImage(
    CameraImage image, {
    required InputImageRotation rotation,
  }) {
    final inputImageFormat = InputImageFormatValue.fromRawValue(
      image.format.raw,
    );
    if (inputImageFormat == null) {
      return null;
    }

    if (Platform.isAndroid &&
        inputImageFormat != InputImageFormat.nv21 &&
        inputImageFormat != InputImageFormat.yuv_420_888) {
      return null;
    }

    if (Platform.isIOS &&
        inputImageFormat != InputImageFormat.bgra8888 &&
        inputImageFormat != InputImageFormat.yuv420) {
      return null;
    }

    final bytes = _concatenatePlanes(image.planes);
    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: inputImageFormat,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  void dispose() {
    for (final recognizer in _recognizers.values) {
      recognizer.close();
    }
    _recognizers.clear();
  }
}
