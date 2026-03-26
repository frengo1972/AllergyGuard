import 'package:flutter/material.dart';

/// Schermata principale dello scanner.
///
/// - Preview camera a schermo intero
/// - Toggle barcode / OCR
/// - In modalità OCR: mirino con rettangolo di focus
/// - Feedback visivo in tempo reale: testo OCR in overlay
/// - FAB per TTS
/// - Accesso rapido a storico e impostazioni
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

enum ScanMode { barcode, ocr }

class _ScannerScreenState extends State<ScannerScreen> {
  ScanMode _scanMode = ScanMode.barcode;
  String _ocrPreviewText = '';
  bool _isTtsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera preview
          _buildCameraPreview(),

          // Top bar con toggle
          _buildTopBar(),

          // OCR overlay text
          if (_scanMode == ScanMode.ocr && _ocrPreviewText.isNotEmpty)
            _buildOcrOverlay(),

          // Bottom bar
          _buildBottomBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _isTtsEnabled = !_isTtsEnabled),
        child: Icon(_isTtsEnabled ? Icons.volume_up : Icons.volume_off),
      ),
    );
  }

  Widget _buildCameraPreview() {
    // TODO: Integrare CameraController
    return Container(color: Colors.black);
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black54,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModeButton('Barcode', ScanMode.barcode),
            const SizedBox(width: 16),
            _buildModeButton('OCR', ScanMode.ocr),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String label, ScanMode mode) {
    final isActive = _scanMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _scanMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildOcrOverlay() {
    return Positioned(
      bottom: 120,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _ocrPreviewText,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black54,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () {
                // TODO: Navigare a storico
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                // TODO: Navigare a impostazioni
              },
            ),
          ],
        ),
      ),
    );
  }
}
