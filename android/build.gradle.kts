allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// file_picker 11: com AGP 9 ele NÃO aplica o plugin Kotlin (presume o
// Kotlin embutido do AGP 9), mas aqui `android.builtInKotlin=false` — então
// o FilePickerPlugin.kt não compilava ("cannot find symbol"). Aplicamos o
// Kotlin nele à mão, logo depois do plugin Android.
subprojects {
    if (name == "file_picker") {
        plugins.withId("com.android.library") {
            if (!plugins.hasPlugin("org.jetbrains.kotlin.android")) {
                apply(plugin = "org.jetbrains.kotlin.android")
            }
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
