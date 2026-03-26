import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

/// Wrapper attorno a ML Kit Barcode Scanning.
class BarcodeScannerService {
  late final BarcodeScanner _scanner;

  BarcodeScannerService() {
    _scanner = BarcodeScanner(formats: [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upca,
      BarcodeFormat.upce,
      BarcodeFormat.qrCode,
    ]);
  }

  /// Scansiona un frame della camera per barcode.
  /// Ritorna il primo barcode trovato o null.
  Future<String?> scanFromCamera(CameraImage image) async {
    final inputImage = _convertCameraImage(image);
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

  InputImage? _convertCameraImage(CameraImage image) {
    // TODO: Implementare conversione CameraImage -> InputImage
    return null;
  }

  void dispose() {
    _scanner.close();
  }
}
