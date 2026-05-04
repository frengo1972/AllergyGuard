# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ML Kit Text Recognition: Devanagari non incluso
-dontwarn com.google.mlkit.vision.text.devanagari.**

# ML Kit generale + script CJK
-keep class com.google.mlkit.** { *; }
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }
-keep class com.google.android.gms.vision.** { *; }

# Play Core: deferred components non usati
-dontwarn com.google.android.play.core.**

# Supabase / GoTrue / PostgREST usano riflessione
-keep class io.supabase.** { *; }
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
