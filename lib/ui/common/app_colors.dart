import 'package:flutter/material.dart';
import 'package:allergyguard/domain/models/scan_result.dart';

/// Colori dell'applicazione per livelli di risultato.
class AppColors {
  AppColors._();

  static const danger = Color(0xFFD32F2F);
  static const warning = Color(0xFFF57C00);
  static const safe = Color(0xFF388E3C);
  static const unknown = Color(0xFF757575);

  static const primary = Color(0xFF1976D2);
  static const background = Color(0xFFF5F5F5);

  static Color forResult(ScanResultLevel level) {
    switch (level) {
      case ScanResultLevel.danger:
        return danger;
      case ScanResultLevel.warning:
        return warning;
      case ScanResultLevel.safe:
        return safe;
      case ScanResultLevel.unknown:
        return unknown;
    }
  }
}
