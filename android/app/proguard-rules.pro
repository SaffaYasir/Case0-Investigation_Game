# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# MultiDex
-keep class androidx.multidex.** { *; }

# Google Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep annotations
-keepattributes *Annotation*