import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allergyguard/core/locale/locale_provider.dart';
import 'package:allergyguard/data/local/local_preferences_service.dart';

enum AppTextScale {
  small(0.85),
  medium(1.0),
  large(1.25);

  const AppTextScale(this.factor);
  final double factor;
}

class TextScaleController extends StateNotifier<AppTextScale> {
  TextScaleController(this._prefs) : super(AppTextScale.medium) {
    _hydrate();
  }

  final LocalPreferencesService _prefs;

  Future<void> _hydrate() async {
    final stored = await _prefs.getTextScaleName();
    state = AppTextScale.values.firstWhere(
      (scale) => scale.name == stored,
      orElse: () => AppTextScale.medium,
    );
  }

  Future<void> setScale(AppTextScale scale) async {
    state = scale;
    await _prefs.setTextScaleName(scale.name);
  }
}

final textScaleControllerProvider =
    StateNotifierProvider<TextScaleController, AppTextScale>((ref) {
  return TextScaleController(ref.watch(localPreferencesProvider));
});
