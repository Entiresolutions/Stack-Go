# Flutter R8 / ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Core (deferred components referenced by Flutter embedding)
-dontwarn com.google.android.play.core.**

# Keep native methods and callbacks
-keepclasseswithmembers class * {
    native <methods>;
}

# Google Mobile Ads SDK
-keep public class com.google.android.gms.ads.** {
   public *;
}
-keep public class com.google.ads.** {
   public *;
}
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-dontwarn com.google.ads.**

# AndroidX WorkManager (required by Google Mobile Ads SDK for background work)
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.impl.WorkDatabase {
    public <init>();
    *;
}
-keep class androidx.work.impl.WorkDatabase_Impl {
    public <init>();
    *;
}
-keep class * extends androidx.work.Worker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}
-keep class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}
-dontwarn androidx.work.**

# AndroidX Startup / InitializationProvider
-keep class androidx.startup.** { *; }
-keep class * extends androidx.startup.Initializer {
    public <init>();
    *;
}

# AndroidX Room & SQLite (used by WorkDatabase)
-keep class * extends androidx.room.RoomDatabase {
    public <init>();
    *;
}
-keep class * extends androidx.room.RoomDatabase$Callback
-dontwarn androidx.room.**
-dontwarn androidx.sqlite.**

# Audioplayers
-dontwarn xyz.luan.audioplayers.**
-keep class xyz.luan.audioplayers.** { *; }

# Video Player
-dontwarn io.flutter.plugins.videoplayer.**
-keep class io.flutter.plugins.videoplayer.** { *; }

# Shared Preferences
-dontwarn io.flutter.plugins.sharedpreferences.**
-keep class io.flutter.plugins.sharedpreferences.** { *; }
