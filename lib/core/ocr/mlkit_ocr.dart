import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'ocr_service.dart';

/// Implementazione OCR on-device con Google ML Kit Text Recognition v2.
class MlKitOcr {
  late final TextRecognizer _textRecognizer;

  MlKitOcr() {
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  Future<OcrResult> processImage(CameraImage image) async {
    final inputImage = _convertCameraImage(image);
    if (inputImage == null) {
      return const OcrResult(text: '', confidence: 0.0, source: OcrSource.mlKit);
    }
    return _recognize(inputImage);
  }

  Future<OcrResult> processFile(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    return _recognize(inputImage);
  }

  Future<OcrResult> _recognize(InputImage inputImage) async {
    final recognizedText = await _textRecognizer.processImage(inputImage);

    if (recognizedText.blocks.isEmpty) {
      return const OcrResult(text: '', confidence: 0.0, source: OcrSource.mlKit);
    }

    final fullText =
        recognizedText.blocks.map((block) => block.text).join('\n');

    // Calcola confidence media dai blocchi
    double totalConfidence = 0;
    int lineCount = 0;
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        totalConfidence += line.confidence ?? 0.0;
        lineCount++;
      }
    }
    final avgConfidence = lineCount > 0 ? totalConfidence / lineCount : 0.0;

    return OcrResult(
      text: fullText,
      confidence: avgConfidence,
      source: OcrSource.mlKit,
    );
  }

  InputImage? _convertCameraImage(CameraImage image) {
    // TODO: Implementare conversione CameraImage -> InputImage
    // La conversione dipende dalla piattaforma (Android NV21/YUV420, iOS BGRA8888)
    return null;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
