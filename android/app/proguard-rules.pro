# Flutter specific ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Supabase/GoTrue
-keep class io.supabase.** { *; }
-keep class com.google.gson.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelables
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# OkHttp (used by Supabase)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Prevent stripping of Google Fonts
-keep class com.google.android.gms.** { *; }

# Google Play Core (for deferred components - Flutter uses this)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }

# Flutter Play Store deferred components
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# SafetyNet is deprecated but referenced by firebase_app_check internals
# App uses Play Integrity at runtime (not SafetyNet)
-dontwarn com.google.android.gms.safetynet.**
-dontwarn com.google.firebase.appcheck.safetynet.**

# Data Models & DTO Serialization (Prevent R8 field renaming/stripping)
-keep class com.avishio.banjarabio.core.models.** { *; }
-keepclassmembers class com.avishio.banjarabio.core.models.** { *; }

# Google Sign-In & Auth APIs
-keep class io.flutter.plugins.googlesignin.** { *; }
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.gms.common.api.** { *; }

# App Links & Supabase Flutter Client
-keep class com.llfeng.app_links.** { *; }
-keep class io.supabase.flutter.** { *; }

