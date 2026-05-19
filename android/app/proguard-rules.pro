# ─── Brawe — ProGuard / R8 rules ────────────────────────────────────────────
# Aplicadas em release builds (isMinifyEnabled = true).
# Mantém classes que são acessadas via reflexão por bibliotecas nativas.

# ── Flutter Engine ──────────────────────────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ── Firebase ────────────────────────────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
# Crashlytics: preservar nomes de linhas pro stack trace ser legível.
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# ── camera plugin ───────────────────────────────────────────────────────────
-keep class io.flutter.plugins.camera.** { *; }
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# ── video_player + ExoPlayer ────────────────────────────────────────────────
-keep class com.google.android.exoplayer2.** { *; }
-keep class androidx.media3.** { *; }
-dontwarn com.google.android.exoplayer2.**
-dontwarn androidx.media3.**

# ── rtmp_broadcaster (live streaming) ───────────────────────────────────────
# Plugin usa reflexão pra carregar codecs nativos.
-keep class com.takusemba.rtmppublisher.** { *; }
-keep class com.pedro.encoder.** { *; }
-keep class com.pedro.rtplibrary.** { *; }
-keep class com.pedro.rtmp.** { *; }
-dontwarn com.takusemba.**
-dontwarn com.pedro.**

# ── flutter_local_notifications ─────────────────────────────────────────────
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# ── permission_handler ──────────────────────────────────────────────────────
-keep class com.baseflow.permissionhandler.** { *; }

# ── share_plus / url_launcher ───────────────────────────────────────────────
-keep class dev.fluttercommunity.plus.share.** { *; }

# ── flutter_secure_storage ──────────────────────────────────────────────────
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# ── Kotlin coroutines ───────────────────────────────────────────────────────
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

# ── Models JSON (freezed/json_serializable) ─────────────────────────────────
# Geralmente desnecessário (Dart-side), mas se houver platform channels
# com Map<String,dynamic>, manter classes geradas.
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ── Suprimir warnings benignos ──────────────────────────────────────────────
-dontwarn javax.annotation.**
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
