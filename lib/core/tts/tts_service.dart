import 'package:flutter_tts/flutter_tts.dart';
import 'package:allergyguard/domain/models/scan_result.dart';

/// Servizio Text-to-Speech per annunciare i risultati della scansione.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  TtsSpeed _speed = TtsSpeed.normal;

  Future<void> initialize() async {
    await _tts.setLanguage('it-IT');
    await _tts.setSpeechRate(_speed.rate);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> setLanguage(String languageCode) async {
    // Mappa codice lingua → locale TTS
    final localeMap = {
      'it': 'it-IT',
      'en': 'en-US',
      'de': 'de-DE',
      'fr': 'fr-FR',
      'es': 'es-ES',
      'pt': 'pt-PT',
      'nl': 'nl-NL',
      'pl': 'pl-PL',
      'ja': 'ja-JP',
      'zh': 'zh-CN',
      'ko': 'ko-KR',
      'ar': 'ar-SA',
      'tr': 'tr-TR',
      'sv': 'sv-SE',
      'da': 'da-DK',
      'fi': 'fi-FI',
    };
    final locale = localeMap[languageCode] ?? 'en-US';
    await _tts.setLanguage(locale);
  }

  Future<void> setSpeed(TtsSpeed speed) async {
    _speed = speed;
    await _tts.setSpeechRate(speed.rate);
  }

  /// Annuncia il risultato della scansione.
  Future<void> announceResult(ScanResult result, {String locale = 'it'}) async {
    final message = _buildMessage(result, locale);
    await _tts.speak(message);
  }

  String _buildMessage(ScanResult result, String locale) {
    final allergenList = result.allergens.join(', ');

    // TODO: Localizzare i messaggi per tutte le lingue supportate
    switch (result.level) {
      case ScanResultLevel.danger:
        return 'Pericolo! Il prodotto contiene $allergenList. Non consumare.';
      case ScanResultLevel.warning:
        return 'Attenzione. Possibile presenza di $allergenList. Verificare l\'etichetta.';
      case ScanResultLevel.safe:
        return 'Prodotto apparentemente sicuro. Nessun allergene rilevato nella sezione dichiarata.';
      case ScanResultLevel.unknown:
        return 'Impossibile verificare. La sezione allergeni non è stata rilevata sull\'etichetta.';
    }
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}

enum TtsSpeed {
  slow(0.3),
  normal(0.5),
  fast(0.7);

  final double rate;
  const TtsSpeed(this.rate);
}
