import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'ocr_service.dart';

/// Implementazione OCR on-device con Google ML Kit Text Recognition v2.
class MlKitOcr {
  MlKitOcr() {
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }
  late final TextRecognizer _textRecognizer;

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
    final inputImage = _convertCameraImage(
      image,
      rotation: rotation,
    );
    if (inputImage == null) {
      return const OcrResult(
          text: '', confidence: 0.0, source: OcrSource.mlKit);
    }
    return _recognize(inputImage);
  }

  Future<OcrResult> processFile(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    return _recognize(
      inputImage,
      imagePath: filePath,
    );
  }

  Future<OcrResult> _recognize(
    InputImage inputImage, {
    String? imagePath,
  }) async {
    final recognizedText = await _textRecognizer.processImage(inputImage);

    if (recognizedText.blocks.isEmpty) {
      return const OcrResult(
          text: '', confidence: 0.0, source: OcrSource.mlKit);
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
    _textRecognizer.close();
  }
}
