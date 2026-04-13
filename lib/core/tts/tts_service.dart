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

  Future<void> announceResult(ScanResult result, {String locale = 'it'}) async {
    final message = _buildMessage(result, locale);
    await _tts.speak(message);
  }

  String _buildMessage(ScanResult result, String locale) {
    final allergenList = result.allergens.join(', ');

    switch (locale) {
      case 'en':
        return switch (result.level) {
          ScanResultLevel.danger =>
            'Danger! This product contains $allergenList. Do not consume it.',
          ScanResultLevel.warning =>
            'Warning. Possible presence of $allergenList. Please check the label carefully.',
          ScanResultLevel.safe =>
            'Apparently safe. No allergen was detected in the declared allergen section.',
          ScanResultLevel.unknown =>
            'Unable to verify. The allergen section was not detected on the label.',
        };
      case 'de':
        return switch (result.level) {
          ScanResultLevel.danger =>
            'Gefahr! Dieses Produkt enthaelt $allergenList. Bitte nicht verzehren.',
          ScanResultLevel.warning =>
            'Achtung. Moegliche Spuren von $allergenList. Bitte Etikett pruefen.',
          ScanResultLevel.safe =>
            'Anscheinend sicher. Kein Allergen im deklarierten Allergenabschnitt erkannt.',
          ScanResultLevel.unknown =>
            'Keine sichere Pruefung moeglich. Der Allergenabschnitt wurde nicht erkannt.',
        };
      case 'fr':
        return switch (result.level) {
          ScanResultLevel.danger =>
            'Danger! Ce produit contient $allergenList. Ne le consommez pas.',
          ScanResultLevel.warning =>
            'Attention. Presence possible de $allergenList. Verifiez bien l etiquette.',
          ScanResultLevel.safe =>
            'Apparemment sur. Aucun allergene detecte dans la section declaree.',
          ScanResultLevel.unknown =>
            'Verification impossible. La section allergenes n a pas ete detectee.',
        };
      case 'es':
        return switch (result.level) {
          ScanResultLevel.danger =>
            'Peligro. Este producto contiene $allergenList. No lo consumas.',
          ScanResultLevel.warning =>
            'Atencion. Posible presencia de $allergenList. Revisa la etiqueta.',
          ScanResultLevel.safe =>
            'Aparentemente seguro. No se detectaron alergenos en la seccion declarada.',
          ScanResultLevel.unknown =>
            'No se puede verificar. No se detecto la seccion de alergenos.',
        };
      case 'it':
      default:
        return switch (result.level) {
          ScanResultLevel.danger =>
            'Pericolo! Il prodotto contiene $allergenList. Non consumare.',
          ScanResultLevel.warning =>
            'Attenzione. Possibile presenza di $allergenList. Verificare l etichetta.',
          ScanResultLevel.safe =>
            'Prodotto apparentemente sicuro. Nessun allergene rilevato nella sezione dichiarata.',
          ScanResultLevel.unknown =>
            'Impossibile verificare. La sezione allergeni non e stata rilevata sull etichetta.',
        };
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

  const TtsSpeed(this.rate);
  final double rate;
}
