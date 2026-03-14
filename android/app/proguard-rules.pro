# Flutter Proguard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# GetX Proguard Rules (if needed, usually not)
#-keep class com.getx.** { *; }

# Retrofit/OkHttp/Dio rules if they had issues, but Dio usually works fine.
