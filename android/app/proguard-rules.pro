# ─── Brawe — ProGuard / R8 rules ────────────────────────────────────────────
# Aplicadas em release builds (isMinifyEnabled = true).
#
# Só exceções com motivo real. Flutter (embedding), Firebase, Google Play
# Services, CameraX, media3, permission_handler, share_plus e
# flutter_secure_storage já trazem consumer rules nos próprios AARs — o R8
# aplica sozinho. Os `-keep class <lib>.** { *; }` genéricos que existiam aqui
# impediam otimização/ofuscação/encolhimento de quase todo o DEX e o Play
# Console marcou 18% (mínimo exigido: 25%).

# ── Crashlytics: stack trace legível ────────────────────────────────────────
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# ── rtmp_broadcaster (live streaming) ───────────────────────────────────────
# Plugin vendorizado em packages/rtmp_broadcaster (pacote Kotlin
# com.app.rtmp_publisher) + lib pedroSG94 rtplibrary 1.9.6, que usa os pacotes
# com.pedro.* e net.ossrs.rtmp (callbacks ConnectCheckerRtmp chamados pelo
# encoder/socket). Codecs/encoders são resolvidos por nome em runtime.
# Sem consumer rules — mantido inteiro.
-keep class com.app.rtmp_publisher.** { *; }
-keep class com.pedro.** { *; }
-keep class net.ossrs.rtmp.** { *; }
-keep class com.github.faucamp.simplertmp.** { *; }
-dontwarn com.app.rtmp_publisher.**
-dontwarn com.pedro.**
-dontwarn net.ossrs.**
-dontwarn com.github.faucamp.**

# ── Tencent VAP (vídeo transparente dos presentes) ──────────────────────────
# AAR sem consumer rules; lib pequena — mantida inteira por segurança.
-keep class com.tencent.qgame.animplayer.** { *; }
-dontwarn com.tencent.qgame.animplayer.**

# ── flutter_local_notifications ─────────────────────────────────────────────
# Serializa notificações agendadas com Gson (reflexão nos campos).
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# ── Kotlin coroutines ───────────────────────────────────────────────────────
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

# ── Gson (usado por plugins) ────────────────────────────────────────────────
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ── Avisos de dependências opcionais (não usadas no Android) ────────────────
-dontwarn io.flutter.embedding.**
-dontwarn javax.annotation.**
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
