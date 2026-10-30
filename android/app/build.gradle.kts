import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Firebase: aplicação condicional. Só ativa os plugins se o
// `google-services.json` existir, pra não quebrar builds de dev sem credenciais.
// Em release publicado, o arquivo OBRIGATORIAMENTE deve estar presente.
val hasGoogleServices = file("google-services.json").exists()
if (hasGoogleServices) {
    apply(plugin = "com.google.gms.google-services")
    apply(plugin = "com.google.firebase.crashlytics")
}

// ── Release signing config ──────────────────────────────────────────────────
// O keystore real NÃO é commitado. Em CI/local de release, criar
// `android/key.properties` baseado em `android/key.properties.example`.
// Se o arquivo não existir, o release cai pro debug signing (útil em CI de PR).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "app.brawe.connect"
    // Play Store exige targetSdk 36 (Android 16); compila com o mesmo nível.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Necessário para libs modernas (Firebase 4.x, java.time, etc.) com minSdk 24.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "app.brawe.connect"
        // Pinado explicitamente: várias deps (firebase 4.x, permission_handler 11,
        // flutter_local_notifications 21) exigem minSdk 24+. targetSdk 35 é
        // exigência do Google Play em 2025.
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Camera + Firebase + video_player passam de 64K métodos.
        multiDexEnabled = true
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            // Usa release keystore se configurada; senão cai pra debug (CI/PR).
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // ── R8 / Minificação (configuração segura) ──────────────────────
            // Minificação + shrink de recursos habilitados. Regras customizadas
            // ficam apenas em proguard-rules.pro (mínimas, justificadas por
            // dependência real). Não usamos regras agressivas de otimização
            // (optimizationpasses, repackageclasses, mergeinterfacesaggressively)
            // pois aumentam risco de regressão sem ganho comprovado — ver
            // ANDROID_R8_SAFE_IMPLEMENTATION_REPORT.md.
            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // `WindowCompat.setDecorFitsSystemWindows()` (usado na MainActivity para
    // edge-to-edge) vem de androidx.core. Fixamos explicitamente uma versão
    // estável recente em vez de depender da versão transitiva do embedding
    // do Flutter, evitando quebra silenciosa caso o Flutter baixe outra
    // versão da dependência.
    implementation("androidx.core:core-ktx:1.15.0")
    // enableEdgeToEdge() (edge-to-edge oficial do Android 15)
    implementation("androidx.activity:activity-ktx:1.9.3")
}

flutter {
    source = "../.."
}
