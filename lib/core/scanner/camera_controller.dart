import 'dart:async';
import 'package:camera/camera.dart';
import 'package:allergyguard/core/constants.dart';

/// Gestione camera con throttling dei frame per OCR/barcode.
class AppCameraController {
  CameraController? _controller;
  Timer? _ocrTimer;
  bool _isProcessing = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
  }

  /// Avvia lo stream di frame per OCR con intervallo di 800ms.
  void startImageStream(Future<void> Function(CameraImage) onFrame) {
    _controller?.startImageStream((image) {
      if (_isProcessing) return;
      _isProcessing = true;

      _ocrTimer?.cancel();
      _ocrTimer = Timer(
        const Duration(milliseconds: AppConstants.cameraOcrIntervalMs),
        () async {
          try {
            await onFrame(image);
          } finally {
            _isProcessing = false;
          }
        },
      );
    });
  }

  void stopImageStream() {
    _controller?.stopImageStream();
    _ocrTimer?.cancel();
    _isProcessing = false;
  }

  Future<void> dispose() async {
    _ocrTimer?.cancel();
    await _controller?.dispose();
  }
}
