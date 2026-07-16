# Android R8 Safe Implementation Report — Brawe App

**Data**: 2026-07-15  
**Status**: ✅ Build local gerado com sucesso — **NADA PUBLICADO**  
**Baseado em**: `ANDROID_R8_SAFE_OPTIMIZATION_PLAN.md`

---

## 1. Resumo

Implementada a configuração R8 **mínima e segura** recomendada pelo diagnóstico anterior. A configuração agressiva (`r8-rules-optimization.pro`, com `repackageclasses`, `optimizationpasses 7`, `mergeinterfacesaggressively`, keeps obsoletos de Flutter/ExoPlayer legado) foi **removida da pipeline de build** — o arquivo permanece no disco, não referenciado, para rollback.

Nenhum objetivo de "atingir 90% de taxa" foi perseguido. Prioridade seguida: estabilidade → compatibilidade → observabilidade de crashes → redução segura → desempenho.

---

## 2. Diagnóstico Utilizado

Documento-base: `ANDROID_R8_SAFE_OPTIMIZATION_PLAN.md` (análise somente leitura, produzida antes desta implementação).

## 3. Divergências Encontradas entre o Relatório e o Código Real

| Item | Relatório dizia | Confirmado agora |
|---|---|---|
| Versão do Flutter | Não informada | **3.44.6** (stable), Dart 3.12.2 |
| Flavors | Não mencionado | **Não existem flavors** — build único |
| Código nativo customizado | Não mencionado | **Existe**: `MainActivity.kt` + `AudioProcessor.kt` com `MethodChannel("com.brawe/audioProcessor")` — referenciado estaticamente, não via reflexão, portanto **não precisa de `-keep` manual** |
| `com.google.android.exoplayer2.*` | Classificado como "desatualizada/remover" | **Confirmado**: `video_player_android 2.11.0` depende exclusivamente de `androidx.media3:media3-exoplayer:1.9.2`. Pacote legado não existe no classpath. |
| `-allowaccessmodification` | Classificado como "possivelmente necessária, testar" | **Já vem por padrão** dentro de `proguard-android-optimize.txt` (linha 14 do `configuration.txt` mesclado) — adicioná-la de novo manualmente seria redundante |
| `missing_rules.txt` | Fase 11 pedia para analisar | **Não foi gerado** — R8 não reportou nenhuma regra keep faltante durante o build |

---

## 4. Configuração Anterior

```kotlin
// android/app/build.gradle.kts (antes)
release {
    isMinifyEnabled = true
    isShrinkResources = true
    proguardFiles(
        getDefaultProguardFile("proguard-android-optimize.txt"),
        "r8-rules-optimization.pro",   // ← configuração agressiva
        "proguard-rules.pro"
    )
}
```

```properties
# android/gradle.properties (antes)
android.r8.optimizedResourceShrinking=false   # ← deprecated no AGP 9.1.1
```

## 5. Configuração Nova

```kotlin
// android/app/build.gradle.kts (depois)
release {
    isMinifyEnabled = true
    isShrinkResources = true
    proguardFiles(
        getDefaultProguardFile("proguard-android-optimize.txt"),
        "proguard-rules.pro"    // único arquivo customizado
    )
}
```

```properties
# android/gradle.properties (depois)
# linha android.r8.optimizedResourceShrinking=false REMOVIDA
```

---

## 6. Arquivos Alterados

| Arquivo | Alteração | Motivo | Risco |
|---|---|---|---|
| `android/app/build.gradle.kts` | Removida referência a `r8-rules-optimization.pro` da lista `proguardFiles()` | Arquivo continha regras agressivas/perigosas não validadas (repackageclasses, optimizationpasses, keeps obsoletos) | Baixo — arquivo mantido no disco para rollback imediato |
| `android/gradle.properties` | Removida linha `android.r8.optimizedResourceShrinking=false` | Propriedade **deprecated** no AGP 9.1.1; sendo ignorada, apenas gerava confusão/warning | Nulo |
| `android/app/proguard-rules.pro` | Substituído `-keep class com.google.android.exoplayer2.** { *; }` e `-dontwarn com.google.android.exoplayer2.**` por comentário explicativo; mantido apenas `androidx.media3.**` | Pacote `com.google.android.exoplayer2` não existe no classpath do projeto (confirmado via `video_player_android-2.11.0/android/build.gradle.kts`) | Nulo — pacote inexistente, regra era morta |
| `android/app/r8-rules-optimization.pro` | **Não removido do disco.** Apenas desreferenciado do build. | Preservar rollback | — |

**Não alterados** (mantidos exatamente como estavam, por serem justificados e funcionais):
- `proguard-rules.pro`: keeps de Flutter, Firebase, camera, RTMP, notifications, permission_handler, secure_storage, coroutines, Gson — todos cobrindo dependências reais e/ou reflexão real do projeto.

---

## 7. Regras Removidas (da pipeline — arquivo mantido em disco)

| Regra R8 | Ação | Justificativa |
|---|---|---|
| `-optimizationpasses 7` | Removida | Redundante — R8 já aplica múltiplas passes automaticamente; explicitar não muda comportamento em versões modernas |
| `-allowaccessmodification` (duplicada) | Removida | Já presente em `proguard-android-optimize.txt` padrão |
| `-mergeinterfacesaggressively` | Removida | Alto risco de quebrar type-checks de interface sem ganho comprovado |
| `-optimizations code/*`, `class/*`, `method/inlining/*` | Removida | R8 já faz essas otimizações por padrão; forçar explicitamente não é suportado/necessário nesta versão |
| `-repackageclasses 'a'` | Removida | Alto risco — pode quebrar recursos/reflexão acessados por nome de pacote; nunca testado em produção |
| `-keep class io.flutter.app.FlutterActivity` | Removida | Classe do embedding **antigo** do Flutter (1.x). Projeto usa `io.flutter.embedding.android.FlutterActivity` (confirmado em `MainActivity.kt`) |
| `-keep class io.flutter.view.FlutterView` | Removida | Idem — embedding antigo, não usado |
| `-assumenosideeffects class io.flutter.util.PathUtils {...}` | Removida | **Regra falsa**: essa classe não expõe métodos `d()/v()` públicos. Regra sem efeito real, apenas ruído |
| `-keep class com.google.android.exoplayer2.ExoPlayer` | Removida | Pacote legado inexistente no projeto (confirmado — projeto usa `androidx.media3`) |
| `-keep class com.google.firebase.messaging.FirebaseMessaging {...}` (assinatura manual de métodos) | Removida | Firebase Messaging já traz consumer-rules embutidas no próprio AAR; regra manual parcial era redundante e frágil (poderia ficar desatualizada em upgrades) |
| `-keep class com.google.firebase.crashlytics.FirebaseCrashlytics {...}` (assinatura manual) | Removida | Idem — consumer-rules do Crashlytics já cobrem isso |
| `-keeppackagenames com.google.firebase.**` / `io.flutter.**` / `com.google.android.exoplayer2.**` | Removida | `-keeppackagenames` genérico não tem função prática aqui e o pacote ExoPlayer2 nem existe |

## 8. Regras Adicionadas

**Nenhuma regra nova foi adicionada.** A configuração final usa apenas o `proguard-rules.pro` pré-existente (já era mínimo e justificado por dependência real), com uma correção textual (remoção do pacote ExoPlayer2 legado inexistente).

## 9. Justificativa por Regra Mantida em `proguard-rules.pro`

| Regra mantida | Motivo | Evidência |
|---|---|---|
| `-keep class io.flutter.** { *; }` | Flutter Engine moderno, entry points via reflexão do embedding | Padrão obrigatório em todos os apps Flutter |
| `-keep class com.google.firebase.** { *; }` | Firebase usa reflexão em alguns componentes internos (mesmo com consumer-rules, manter reduz risco de regressão silenciosa em upgrades) | `firebase_core`, `firebase_messaging`, `firebase_crashlytics` no pubspec.yaml |
| `-keepattributes SourceFile,LineNumberTable` | Crashlytics precisa desofuscar stack traces | Plugin `firebase_crashlytics` ativo + `mapping.txt` gerado |
| `-keep class io.flutter.plugins.camera.**` + `androidx.camera.**` | Plugin `camera: ^0.12.0+1` (CameraX) | `pubspec.yaml` |
| `-keep class androidx.media3.**` | `video_player_android` depende de `media3-exoplayer` | Confirmado no `build.gradle.kts` do plugin |
| `-keep class com.takusemba.rtmppublisher.**`, `com.pedro.encoder.**`, etc | `rtmp_broadcaster: ^2.3.4` **não fornece** `consumer-rules.pro` — regra manual é obrigatória | Verificado: nenhum consumer-rules.pro no pacote |
| `-keep class com.dexterous.**` | `flutter_local_notifications: ^21.0.0` | pubspec.yaml |
| `-keep class com.baseflow.permissionhandler.**` | `permission_handler: ^11.3.1` | pubspec.yaml |
| `-keep class com.it_nomads.fluttersecurestorage.**` | `flutter_secure_storage: ^10.0.0` | pubspec.yaml |
| `-keepnames kotlinx.coroutines.*` | Coroutines Kotlin usadas internamente pelas libs Android | Padrão recomendado |
| `-keepclassmembers ... @SerializedName` | Precaução para platform channels com Gson (baixo custo, sem risco) | Comentário original do arquivo |
| `-dontwarn` diversos (bouncycastle, conscrypt, openjsse, javax.annotation) | Suprime apenas *warnings* de build, não afeta o código gerado | Prática padrão, não é `-dontwarn **` genérico |

**Nenhuma dessas regras usa `-keep class ** { *; }` genérico.**

---

## 10. Consumer Rules Identificadas (fornecidas automaticamente pelos AARs)

| Biblioteca | Consumer rules existentes | Regra customizada necessária? | Motivo |
|---|---:|---:|---|
| Firebase Core/Messaging/Crashlytics | ✅ Sim (embutidas no AAR) | Mantida por precaução (baixo custo) | Reflexão interna em componentes de inicialização |
| androidx.media3 (video_player) | ✅ Sim | Mantida por precaução | Fallbacks de codec via reflexão |
| androidx.camera (CameraX) | ✅ Sim | Não | — |
| mobile_scanner (ML Kit) | ✅ Sim | Não | — |
| jni / jni_flutter | ✅ Sim (`consumer-rules.pro` explícito) | Não | Bindings JNI já cobertos |
| rtmp_broadcaster | ❌ Não | ✅ Sim | Único plugin sem consumer-rules — regra manual obrigatória |
| permission_handler_android | ⚠️ Não verificado diretamente, mas plugin simples | Mantida por precaução (já existia) | Baixo custo, sem risco |
| flutter_local_notifications | ⚠️ Não verificado diretamente | Mantida por precaução (já existia) | Baixo custo, sem risco |

---

## 11. Reflection / JNI Encontrados

| Classe/Pacote | Tipo | Motivo | Evidência | Risco sem keep |
|---|---|---|---|---|
| `app.brawe.connect.AudioProcessor` | MethodChannel (referência estática) | Chamado diretamente por `MainActivity.kt`, sem reflexão | `MainActivity.kt` linha 15: `val processor = AudioProcessor.instance` | **Nenhum** — R8 mantém automaticamente código alcançável a partir da Activity (entry point via Manifest) |
| `app.brawe.connect.MainActivity` | Entry point Android | Declarada no `AndroidManifest.xml` | `<activity android:name=".MainActivity">` | Nenhum — Activities declaradas no Manifest são mantidas automaticamente pelas regras padrão do AGP |
| `com.github.dart_lang.jni.**` / `jni_flutter.**` | JNI bindings | Usado por `jni`/`jni_flutter` (dependências transitivas) | `consumer-rules.pro` dos próprios pacotes | Nenhum — já coberto por consumer-rules |

**Conclusão**: Não foi necessário adicionar nenhuma regra keep nova para reflexão/JNI. O código nativo customizado do projeto (`AudioProcessor`) é 100% alcançável estaticamente a partir do entry point `MainActivity`, que por sua vez é mantido pelas regras padrão do Android/AGP para componentes declarados no Manifest.

---

## 12. Resultado do Build

```
Comando: flutter build appbundle --release
Tempo total: 149,2s (Gradle) / ~158s (incluindo flutter pub get e tree-shaking de fontes)
Resultado: ✓ Built build/app/outputs/bundle/release/app-release.aab (133.5MB conforme reportado pelo Flutter tool)
Tamanho real no disco: 127M (ls -lh)
```

### Warnings Encontrados (não relacionados ao R8)
1. **Kotlin Gradle Plugin (KGP) deprecation**: Flutter avisa que plugins (`app_badge_plus`, `flutter_native_video_trimmer`, `mobile_scanner`, `package_info_plus`, `record_android`, `rtmp_broadcaster`, `share_plus`, `wakelock_plus`) aplicam KGP diretamente — isso é uma migração futura do Flutter tooling, **não relacionado à configuração R8**.
2. Nenhum warning do R8/ProGuard foi impresso durante o build (diferente das tentativas anteriores com `r8-rules-optimization.pro`, que geravam erros de opção desconhecida).
3. Nenhum `missing_rules.txt` foi gerado — indica que R8 não identificou nenhuma keep rule faltante.

---

## 13. Artefatos do R8

| Artefato | Localização | Linhas | Observação |
|---|---|---:|---|
| `mapping.txt` | `build/app/outputs/mapping/release/mapping.txt` | 471.687 | Gerado com sucesso — permite desofuscação no Crashlytics |
| `mapping.prt` | `build/app/outputs/mapping/release/mapping.prt` | — | Formato de partição do mapping (AGP moderno) |
| `seeds.txt` | `build/app/outputs/mapping/release/seeds.txt` | 114.611 | Classes/membros mantidos por regras `-keep` |
| `usage.txt` | `build/app/outputs/mapping/release/usage.txt` | 45.156 | Código efetivamente removido pelo R8 |
| `configuration.txt` | `build/app/outputs/mapping/release/configuration.txt` | 1.378 | Configuração R8 mesclada final (padrão + consumer-rules + proguard-rules.pro) |
| `resources.txt` | `build/app/outputs/mapping/release/resources.txt` | 1.609 | Log de resource shrinking |
| `missing_rules.txt` | — | **Não gerado** | R8 não reportou nenhuma regra keep faltante |

### Resource Shrinking — Métrica Real
```
Recursos marcados "is not reachable" (removidos): 988
Recursos marcados "reachable from" (mantidos):     621
```

### Confirmação de Otimizações Padrão Já Ativas
O `configuration.txt` mesclado confirma que `proguard-android-optimize.txt` já inclui, **sem necessidade de regra manual**:
```
-allowaccessmodification
-keepattributes AnnotationDefault, EnclosingMethod, InnerClasses,
                RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations,
                RuntimeVisibleTypeAnnotations, Signature
-keep public class com.google.vending.licensing.ILicensingService
-keepclasseswithmembernames,includedescriptorclasses class * { native <methods>; }
```

### Regras Customizadas Confirmadas no Merge Final
```
150: -keep class com.takusemba.rtmppublisher.** { *; }
158: -keep class com.dexterous.** { *; }
159: -dontwarn com.dexterous.**
162: -keep class com.baseflow.permissionhandler.** { *; }
168: -keep class com.it_nomads.fluttersecurestorage.** { *; }
```
Confirma que `proguard-rules.pro` foi corretamente incorporado à configuração final do R8.

---

## 14. Comparação Antes e Depois

| Métrica | Antes (r8-rules-optimization.pro ativo) | Depois (configuração segura) | Diferença |
|---|---:|---:|---:|
| Tamanho do AAB | Não foi possível gerar — **build falhava** com `R8: Unknown option "-deletedebuglambdas"` e depois `R8: Unknown option "-stripattributes"` | **127 MB** (133.5MB conforme Flutter) | N/A — não havia baseline funcional para comparar |
| Tempo de build | N/A (build falhava antes de completar) | 149,2s (Gradle) | N/A |
| Recursos removidos | N/A | 988 recursos "not reachable" | N/A |
| Classes removidas (code shrinking) | N/A | usage.txt com 45.156 linhas de código removido | N/A |
| mapping.txt gerado | N/A | ✅ Sim, 471.687 linhas | N/A |

**Nota importante**: A configuração agressiva anterior (`r8-rules-optimization.pro`) **nunca chegou a gerar um build de release funcional** nas tentativas anteriores desta sessão — falhou por opções inválidas do R8 (`-deletedebuglambdas`, `-stripattributes`, `-useuniqueclassmembernames`). Portanto, **não existe uma baseline real "antes" para comparação de tamanho** — apenas a suposição teórica do relatório de diagnóstico. Este é o **primeiro build de release bem-sucedido** desde que a otimização agressiva foi introduzida.

---

## 15. Testes Executados

| Teste | Resultado | Evidência |
|---|---|---|
| `flutter pub get` | ✅ Sucesso | "Got dependencies!" |
| `flutter build appbundle --release` | ✅ Sucesso | AAB gerado em 149,2s, 127MB |
| Geração de `mapping.txt` | ✅ Sucesso | 471.687 linhas |
| Geração de `seeds.txt` | ✅ Sucesso | 114.611 linhas |
| Merge de `proguard-rules.pro` na configuração final | ✅ Confirmado | Regras RTMP/permission_handler/dexterous presentes em `configuration.txt` |
| Resource shrinking ativo | ✅ Confirmado | 988 recursos removidos, 621 mantidos |
| Ausência de `missing_rules.txt` | ✅ Confirmado | Nenhuma regra keep faltante detectada pelo R8 |

## 16. Testes NÃO Executados (Fase 13 — Smoke Test Real)

Conforme a Fase 15 da tarefa ("Não publicar"), **não instalei o APK em dispositivo físico nem executei o app**. Os 30 fluxos críticos da Fase 13 (abertura, login, cadastro, feed, For You, vídeos, Stories, música, RTMP/lives, câmera, notificações push, deep links, Crashlytics, background, Android 15, etc.) **não foram testados em runtime** nesta etapa.

**Motivo**: a tarefa distingue explicitamente build local (Fase 10, executado) de smoke test em aparelho (Fase 13, requer instalação e interação manual). Não gerei/instalei o APK em device físico como parte desta entrega automatizada.

**Recomendação**: antes de qualquer promoção para Internal Testing, executar manualmente o checklist completo dos 30 fluxos críticos listados no prompt original, especialmente:
- RTMP/lives (regra manual keep, único plugin sem consumer-rules)
- Áudio (`AudioProcessor`/MethodChannel customizado)
- Firebase Messaging + Crashlytics (validar que crash de teste aparece desofuscado no console)
- Vídeos (media3)

---

## 17. Riscos

| Risco | Probabilidade | Mitigação |
|---|---|---|
| RTMP quebrar em runtime | Baixa | Regra `-keep com.takusemba.rtmppublisher.**` mantida intacta (não alterada) |
| Firebase Messaging/Crashlytics quebrar | Muito baixa | Regras mantidas + consumer-rules do próprio AAR + `-keepattributes SourceFile,LineNumberTable` preservado |
| `AudioProcessor` (MethodChannel nativo) parar de funcionar | Muito baixa | Código alcançável estaticamente a partir de `MainActivity` (entry point mantido pelo Manifest) |
| Regressão por remoção de regras "extras" de Firebase (assinaturas manuais de método) | Baixa | Consumer-rules do Firebase AAR cobrem os mesmos métodos de forma mais robusta e atualizada |
| Resource shrinking remover recurso usado dinamicamente por nome (string) | Não avaliado em runtime | **Não confirmado** — requer smoke test real, especialmente em ícones de notificação, splash e deep links |

---

## 18. Plano de Rollback

1. **Reverter `build.gradle.kts`**: readicionar `"r8-rules-optimization.pro"` à lista `proguardFiles()` (arquivo permanece intacto no disco em `android/app/r8-rules-optimization.pro`).
2. **Reverter `gradle.properties`**: readicionar `android.r8.optimizedResourceShrinking=false` (embora deprecated, é inofensivo se readicionado).
3. **Reverter `proguard-rules.pro`**: usar o diff git abaixo para restaurar a versão anterior.

### Diff Completo Aplicado (para referência/rollback)
```diff
diff --git a/android/app/build.gradle.kts b/android/app/build.gradle.kts
@@ -76,9 +76,16 @@ android {
             } else {
                 signingConfigs.getByName("debug")
             }
-            // Shrinking + obfuscação. ProGuard rules em proguard-rules.pro.
+            // ── R8 / Minificação (configuração segura) ──────────────────
+            // [...comentário explicativo...]
             isMinifyEnabled = true
             isShrinkResources = true
+
             proguardFiles(
                 getDefaultProguardFile("proguard-android-optimize.txt"),
-                "r8-rules-optimization.pro",
                 "proguard-rules.pro"
             )

diff --git a/android/app/proguard-rules.pro b/android/app/proguard-rules.pro
@@ -25,10 +25,14 @@
--keep class com.google.android.exoplayer2.** { *; }
+# [comentário explicativo sobre androidx.media3]
 -keep class androidx.media3.** { *; }
--dontwarn com.google.android.exoplayer2.**
 -dontwarn androidx.media3.**

diff --git a/android/gradle.properties b/android/gradle.properties
@@ -10,6 +10,5 @@
 android.r8.strictFullModeForKeepRules=false
-android.r8.optimizedResourceShrinking=false
 android.builtInKotlin=false
```

Rollback pode ser feito via `git checkout -- android/app/build.gradle.kts android/gradle.properties android/app/proguard-rules.pro` (comando **não executado**, apenas documentado como opção do usuário).

---

## 19. Recomendação para Internal Testing

**Antes de promover para Internal Testing:**
1. Instalar o AAB/APK gerado (`build/app/outputs/bundle/release/app-release.aab`) em pelo menos 1 dispositivo físico Android real
2. Executar o checklist completo de 30 fluxos críticos da Fase 13 do prompt original
3. Forçar um crash de teste e confirmar que aparece **desofuscado** no Firebase Crashlytics Console (usando o `mapping.txt` gerado)
4. Validar especificamente RTMP/live streaming (único plugin com regra manual obrigatória) e o `AudioProcessor` nativo (MethodChannel customizado)
5. Monitorar Android Vitals por 24-48h após publicação em Internal Testing, antes de qualquer rollout gradual

**Somente após essas validações**, proceder para upload no Play Console (não incluído nesta entrega).

---

## 20. Confirmações Finais

- ✅ Diagnóstico do `ANDROID_R8_SAFE_OPTIMIZATION_PLAN.md` foi lido e validado
- ✅ Divergências identificadas e documentadas (seção 3)
- ✅ Configuração agressiva **não foi aplicada** — removida da pipeline
- ✅ Minificação configurada com segurança (`isMinifyEnabled = true`, sem flags agressivas extras)
- ✅ Resource shrinking configurado com segurança (`isShrinkResources = true`)
- ✅ Propriedade deprecated de optimized resource shrinking removida (AGP 9.1.1 já lida automaticamente sem essa flag)
- ✅ Regras customizadas mínimas — nenhuma regra nova adicionada, apenas correção textual
- ✅ `mapping.txt` gerado com sucesso (471.687 linhas)
- ✅ Build release gerado localmente com sucesso
- ❌ **AAB NÃO foi publicado** — apenas gerado localmente em `build/app/outputs/bundle/release/app-release.aab`
- ⚠️ Smoke test manual em dispositivo físico **não foi executado** nesta entrega — pendente antes de Internal Testing
- ⚠️ Investigação de "fechamentos inesperados" **não foi feita** nesta tarefa (Crashlytics/Android Vitals requerem acesso a dados de produção reais que não estão disponíveis neste ambiente local) — ver seção 21
- ✅ Nenhum commit foi feito
- ✅ `versionCode`/`versionName` inalterados
- ✅ `applicationId` inalterado
- ✅ Assinatura release inalterada (usa keystore existente ou fallback debug, sem mudanças)

## 21. Limitação Documentada — Investigação de Fechamentos

Conforme instruído na Fase 14, **não foi assumido que o R8 é a causa dos fechamentos inesperados**. Esta tarefa **não teve acesso** a:
- Console do Firebase Crashlytics (dados de produção)
- Android Vitals do Google Play Console
- Logs de `ApplicationExitInfo` de dispositivos reais em campo

**Portanto, a causa dos fechamentos permanece não diagnosticada por esta tarefa.** Recomenda-se, como próximo passo separado desta otimização R8, revisar diretamente o Firebase Crashlytics Console e Android Vitals para identificar padrões de ANR, OutOfMemoryError ou crashes nativos antes de atribuir qualquer causa.

---

**Fim do Relatório de Implementação**
