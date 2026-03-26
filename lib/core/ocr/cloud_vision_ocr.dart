import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'ocr_service.dart';

/// Implementazione OCR cloud con Google Cloud Vision API.
/// Usato come fallback quando ML Kit ha confidence < 60%.
class CloudVisionOcr {
  final Dio _dio;
  final String _apiKey;

  CloudVisionOcr({
    required Dio dio,
    required String apiKey,
  })  : _dio = dio,
        _apiKey = apiKey;

  Future<OcrResult> processImage(CameraImage image) async {
    // TODO: Convertire CameraImage in base64 per l'API
    return const OcrResult(text: '', confidence: 0.0, source: OcrSource.cloudVision);
  }

  Future<OcrResult> processFile(String filePath) async {
    final bytes = await _readFileBytes(filePath);
    final base64Image = base64Encode(bytes);

    final response = await _dio.post(
      'https://vision.googleapis.com/v1/images:annotate?key=$_apiKey',
      data: {
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'TEXT_DETECTION'}
            ],
          }
        ],
      },
    );

    final annotations = response.data['responses']?[0]?['textAnnotations'];
    if (annotations == null || (annotations as List).isEmpty) {
      return const OcrResult(
          text: '', confidence: 0.0, source: OcrSource.cloudVision);
    }

    final fullText = annotations[0]['description'] as String? ?? '';
    // Cloud Vision non restituisce confidence per il testo completo,
    // usiamo un valore alto come default dato che è il cloud.
    return OcrResult(
      text: fullText,
      confidence: 0.90,
      source: OcrSource.cloudVision,
    );
  }

  Future<List<int>> _readFileBytes(String filePath) async {
    final file = await Future.value(filePath);
    // TODO: Leggere file bytes dal path
    return [];
  }
}
