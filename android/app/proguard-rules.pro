# Flutter specific ProGuard rules

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dart specific rules
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Keep your app's classes
-keep class com.metalmetric.metal_metric.** { *; }

# Keep annotations
-keepattributes *Annotation*

# Keep line numbers for better stack traces
-keepattributes SourceFile,LineNumberTable

# HTTP client (for network requests)
-keep class android.net.http.** { *; }
-dontwarn android.net.http.**

# OkHttp (used by http package)
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep HTTP package classes
-keep class io.flutter.plugins.http.** { *; }

# Keep Gson (for JSON parsing)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep network-related classes
-keep class java.net.** { *; }
-keep class javax.net.** { *; }
-dontwarn javax.net.**

# Connectivity Plus
-dontwarn dev.fluttercommunity.**

# URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Google Play Core (for app bundles)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
