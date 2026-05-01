import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allergyguard/data/local/local_preferences_service.dart';

const List<Locale> kSupportedLocales = [
  Locale('it'),
  Locale('en'),
  Locale('de'),
  Locale('fr'),
  Locale('es'),
  Locale('zh'),
  Locale('ja'),
];

const String _fallbackLanguageCode = 'en';

String resolveSupportedLanguageCode(String? candidate) {
  if (candidate == null || candidate.isEmpty) return _fallbackLanguageCode;
  final normalized = candidate.toLowerCase().split(RegExp(r'[-_]')).first;
  for (final locale in kSupportedLocales) {
    if (locale.languageCode == normalized) return normalized;
  }
  return _fallbackLanguageCode;
}

class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._prefs) : super(_initialLocale()) {
    _hydrate();
  }

  final LocalPreferencesService _prefs;

  static Locale _initialLocale() {
    final systemLang = PlatformDispatcher.instance.locale.languageCode;
    return Locale(resolveSupportedLanguageCode(systemLang));
  }

  Future<void> _hydrate() async {
    final stored = await _prefs.getInterfaceLanguage();
    final resolved = resolveSupportedLanguageCode(stored);
    if (resolved != state.languageCode) {
      state = Locale(resolved);
    }
  }

  Future<void> setLanguage(String languageCode) async {
    final resolved = resolveSupportedLanguageCode(languageCode);
    await _prefs.setInterfaceLanguage(resolved);
    state = Locale(resolved);
  }
}

final localPreferencesProvider = Provider<LocalPreferencesService>(
  (ref) => LocalPreferencesService(),
);

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController(ref.watch(localPreferencesProvider));
});
