import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

/// Wrapper attorno a ML Kit Barcode Scanning.
class BarcodeScannerService {

  BarcodeScannerService() {
    _scanner = BarcodeScanner(formats: [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upca,
      BarcodeFormat.upce,
      BarcodeFormat.qrCode,
    ]);
  }
  late final BarcodeScanner _scanner;

  /// Scansiona un frame della camera per barcode.
  /// Ritorna il primo barcode trovato o null.
  Future<String?> scanFromCamera(
    CameraImage image, {
    required InputImageRotation rotation,
  }) async {
    final inputImage = _convertCameraImage(
      image,
      rotation: rotation,
    );
    if (inputImage == null) return null;
    return _scan(inputImage);
  }

  Future<String?> scanFromFile(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    return _scan(inputImage);
  }

  Future<String?> _scan(InputImage inputImage) async {
    final barcodes = await _scanner.processImage(inputImage);
    if (barcodes.isEmpty) return null;
    return barcodes.first.rawValue;
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
    _scanner.close();
  }
}
