# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ML Kit Text Recognition: script recognizers non inclusi (usiamo solo Latin)
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# ML Kit generale
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.vision.** { *; }

# Play Core: deferred components non usati
-dontwarn com.google.android.play.core.**

# Supabase / GoTrue / PostgREST usano riflessione
-keep class io.supabase.** { *; }
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
