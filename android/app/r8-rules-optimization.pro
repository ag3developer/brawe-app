# ─── Brawe — Advanced R8 Optimization Rules ─────────────────────────────────
# Configurações agressivas para maximizar:
# - Taxa de otimização (90%+)
# - Taxa de ofuscação (90%+)
# - Taxa de redução (90%+)
# - Redução otimizada de recursos (ativada)
#
# Aplicadas APENAS em release builds (isMinifyEnabled = true).

# ═══════════════════════════════════════════════════════════════════════════
# 1. OTIMIZAÇÕES AGRESSIVAS DE CÓDIGO (90%+ optimization rate)
# ═══════════════════════════════════════════════════════════════════════════

# Remover logs de debug completamente
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Remover chamadas de logging customizadas (se existirem)
-assumenosideeffects class io.flutter.util.PathUtils {
    public static *** d(...);
    public static *** v(...);
}

# Agressiva inlinização de métodos
-optimizationpasses 7
-allowaccessmodification
-mergeinterfacesaggressively

# Otimizações suportadas pelo R8
-optimizations code/*
-optimizations class/marking/removable
-optimizations class/unboxing/enum
-optimizations class/merging/vertical
-optimizations class/merging/horizontal
-optimizations method/inlining/*

# ═══════════════════════════════════════════════════════════════════════════
# 2. OFUSCAÇÃO AGRESSIVA (90%+ obfuscation rate)
# ═══════════════════════════════════════════════════════════════════════════

# Renomear agressivamente com nomes curtos
-repackageclasses 'a'

# Permitir renomeação de atributos de campo mesmo que publicamente acessados
-allowaccessmodification

# Manter SourceFile e LineNumberTable para stack traces legíveis no Crashlytics

# ═══════════════════════════════════════════════════════════════════════════
# 3. REDUÇÃO AGRESSIVA (90%+ reduction rate)
# ═══════════════════════════════════════════════════════════════════════════

# Remover recursos não utilizados (já habilitado via isShrinkResources = true)
# O R8 automaticamente remove classes não utilizadas

# Reduzir recursos de layout não utilizados
# Isso é controlado pelo Gradle com isShrinkResources = true,
# mas podemos otimizar ainda mais removendo recursos genéricos.

# ═══════════════════════════════════════════════════════════════════════════
# 4. PRESERVAÇÕES MÍNIMAS (apenas o essencial para funcionamento)
# ═══════════════════════════════════════════════════════════════════════════

# ── Flutter Engine (mínimo necessário) ───────────────────────────────────
-keep class io.flutter.app.FlutterActivity { *; }
-keep class io.flutter.view.FlutterView { *; }
-keep class io.flutter.embedding.engine.FlutterEngine { *; }
-keep class io.flutter.embedding.engine.FlutterEngineCache { *; }
-keepclasseswithmembers class io.flutter.** {
    native <methods>;
}

# ── Firebase (crítico) ──────────────────────────────────────────────────
-keep class com.google.firebase.messaging.FirebaseMessaging {
    public static *** getInstance();
    public *** getToken(...);
    public *** send(...);
}
-keep class com.google.firebase.crashlytics.FirebaseCrashlytics {
    public static *** getInstance();
    public *** recordException(...);
}

# Preservar annotations do Firebase
-keepattributes Signature,RuntimeVisibleAnnotations

# ── ExoPlayer (para video_player) ───────────────────────────────────────
-keep class com.google.android.exoplayer2.ExoPlayer
-keep interface com.google.android.exoplayer2.Player

# ── RTMP Broadcaster (para live streaming) ──────────────────────────────
-keep class com.takusemba.rtmppublisher.RtmpPublisher
-keep class com.pedro.encoder.input.gl.render.filters.* { *; }

# ── Permissões ──────────────────────────────────────────────────────────
-keep class com.baseflow.permissionhandler.** { *; }

# ── Kotlin Metadata (necessário para interop Kotlin/Java) ──────────────
-keepattributes Signature,RuntimeVisibleAnnotations,*Annotation*

# ── Gson (se usado) ─────────────────────────────────────────────────────
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
-keepclasseswithmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ── Package names (preservar nomes de pacotes de bibliotecas críticas) ──
-keeppackagenames com.google.firebase.**
-keeppackagenames io.flutter.**
-keeppackagenames com.google.android.exoplayer2.**

# ═══════════════════════════════════════════════════════════════════════════
# 5. CONFIGURAÇÕES FINAIS DE PERFORMANCE
# ═══════════════════════════════════════════════════════════════════════════

# Permitir que o R8 faça inlining agressivo
-mergeinterfacesaggressively
-allowaccessmodification
