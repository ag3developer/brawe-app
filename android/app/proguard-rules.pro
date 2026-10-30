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

# ── video_player (androidx.media3) ──────────────────────────────────────────
# Projeto usa video_player_android 2.11.0, que depende de androidx.media3
# (media3-exoplayer). O pacote legado com.google.android.exoplayer2 NÃO é
# usado — não há essa dependência no projeto. androidx.media3 já traz suas
# próprias consumer-rules embutidas no AAR; o -keep abaixo é redundante em
# teoria, mas mantido por segurança pois o plugin faz chamadas via reflexão
# em alguns fallbacks de codec.
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**

# ── rtmp_broadcaster (live streaming) ───────────────────────────────────────
# Plugin vendorizado em packages/rtmp_broadcaster (pacote Kotlin
# com.app.rtmp_publisher) + lib pedroSG94 rtplibrary 1.9.6, que usa os pacotes
# com.pedro.* e net.ossrs.rtmp (callbacks ConnectCheckerRtmp chamados pelo
# encoder/socket). Codecs/encoders são resolvidos por nome em runtime.
-keep class com.app.rtmp_publisher.** { *; }
-keep class com.pedro.** { *; }
-keep class net.ossrs.rtmp.** { *; }
-keep class com.github.faucamp.simplertmp.** { *; }
-dontwarn com.app.rtmp_publisher.**
-dontwarn com.pedro.**
-dontwarn net.ossrs.**
-dontwarn com.github.faucamp.**

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
