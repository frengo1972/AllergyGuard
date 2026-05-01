import 'package:flutter/material.dart';
import 'package:allergyguard/domain/models/allergen.dart';

String languageFlagForCode(String languageCode) {
  switch (languageCode) {
    case 'it':
      return '🇮🇹';
    case 'en':
      return '🇬🇧';
    case 'de':
      return '🇩🇪';
    case 'fr':
      return '🇫🇷';
    case 'es':
      return '🇪🇸';
    default:
      return '🌐';
  }
}

String allergenEmojiForKey(String allergenKey) {
  switch (allergenKey) {
    case 'gluten':
      return '🌾';
    case 'peanut':
      return '🥜';
    case 'milk':
      return '🥛';
    case 'egg':
      return '🥚';
    case 'tree_nut':
      return '🌰';
    case 'soy':
      return '🫘';
    case 'fish':
      return '🐟';
    case 'crustacean':
      return '🦐';
    case 'mollusc':
      return '🦪';
    case 'celery':
      return '🥬';
    case 'mustard':
      return '🟡';
    case 'sesame':
      return '⚪';
    case 'sulphite':
      return '🧪';
    case 'lupin':
      return '🌼';
    default:
      return '⚠️';
  }
}

Color allergenColorForKey(String allergenKey, BuildContext context) {
  switch (allergenKey) {
    case 'gluten':
      return const Color(0xFFC27C1D);
    case 'peanut':
      return const Color(0xFFB45F06);
    case 'milk':
      return const Color(0xFF3D85C6);
    case 'egg':
      return const Color(0xFFE0B400);
    case 'tree_nut':
      return const Color(0xFF6F4E37);
    case 'soy':
      return const Color(0xFF4F8A10);
    case 'fish':
      return const Color(0xFF0077B6);
    case 'crustacean':
      return const Color(0xFFCC4125);
    case 'mollusc':
      return const Color(0xFF674EA7);
    case 'celery':
      return const Color(0xFF6AA84F);
    case 'mustard':
      return const Color(0xFFE69138);
    case 'sesame':
      return const Color(0xFF8E7C68);
    case 'sulphite':
      return const Color(0xFF8E24AA);
    case 'lupin':
      return const Color(0xFF38761D);
    default:
      return Theme.of(context).colorScheme.primary;
  }
}

Color allergenColorForAllergen(Allergen allergen, BuildContext context) {
  if (allergen.iconColor != null && allergen.iconColor!.isNotEmpty) {
    final parsed = _colorFromHex(allergen.iconColor!);
    if (parsed != null) return parsed;
  }
  return allergenColorForKey(allergen.nameKey, context);
}

Widget allergenBadgeForKey(String allergenKey, BuildContext context) {
  final color = allergenColorForKey(allergenKey, context);
  return CircleAvatar(
    backgroundColor: color.withValues(alpha: 0.16),
    child: Text(
      allergenEmojiForKey(allergenKey),
      style: const TextStyle(fontSize: 18),
    ),
  );
}

Widget allergenBadgeForAllergen(Allergen allergen, BuildContext context) {
  if (allergen.iconType == AllergenIconType.bundle) {
    return allergenBadgeForKey(allergen.nameKey, context);
  }

  final color = allergenColorForAllergen(allergen, context);
  final emoji = allergen.iconType == AllergenIconType.emoji &&
          allergen.iconEmoji != null &&
          allergen.iconEmoji!.isNotEmpty
      ? allergen.iconEmoji!
      : '!';

  return CircleAvatar(
    backgroundColor: color.withValues(alpha: 0.16),
    child: Text(
      emoji,
      style: TextStyle(
        fontSize: allergen.iconType == AllergenIconType.emoji ? 18 : 16,
        fontWeight:
            allergen.iconType == AllergenIconType.emoji ? null : FontWeight.w700,
        color:
            allergen.iconType == AllergenIconType.emoji ? null : color,
      ),
    ),
  );
}

Color? _colorFromHex(String value) {
  final normalized = value.trim().replaceFirst('#', '');
  if (normalized.length != 6 && normalized.length != 8) return null;
  final buffer = StringBuffer();
  if (normalized.length == 6) {
    buffer.write('FF');
  }
  buffer.write(normalized);
  final parsed = int.tryParse(buffer.toString(), radix: 16);
  if (parsed == null) return null;
  return Color(parsed);
}
