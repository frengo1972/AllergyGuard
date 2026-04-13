import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:allergyguard/core/constants.dart';

/// Gestione camera con throttling dei frame per OCR/barcode.
class AppCameraController {
  CameraController? _controller;
  Timer? _ocrTimer;
  bool _isProcessing = false;

  CameraController? get controller => _controller;
  CameraDescription? get description => _controller?.description;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  bool get isStreamingImages => _controller?.value.isStreamingImages ?? false;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final selectedCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();
  }

  /// Avvia lo stream di frame per OCR con intervallo di 800ms.
  Future<void> startImageStream(
      Future<void> Function(CameraImage) onFrame) async {
    if (_controller == null || isStreamingImages) return;

    await _controller!.startImageStream((image) async {
      if (_isProcessing) return;
      _isProcessing = true;

      try {
        await onFrame(image);
      } finally {
        _ocrTimer?.cancel();
        _ocrTimer = Timer(
          const Duration(milliseconds: AppConstants.cameraOcrIntervalMs),
          () {
            _isProcessing = false;
          },
        );
      }
    });
  }

  Future<void> stopImageStream() async {
    if (_controller == null || !isStreamingImages) {
      _ocrTimer?.cancel();
      _isProcessing = false;
      return;
    }

    await _controller!.stopImageStream();
    _ocrTimer?.cancel();
    _isProcessing = false;
  }

  Future<String?> takePicturePath() async {
    if (_controller == null || !isInitialized) return null;
    if (isStreamingImages) {
      await stopImageStream();
    }

    final file = await _controller!.takePicture();
    return file.path;
  }

  Future<void> dispose() async {
    await stopImageStream();
    await _controller?.dispose();
  }
}
