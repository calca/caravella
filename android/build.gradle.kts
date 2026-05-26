allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Inject a buildscript resolution strategy into every subproject BEFORE its own
// build.gradle evaluates.  Flutter plugin subprojects (e.g. file_picker,
// home_widget) still declare older AGP/Kotlin in their own buildscript blocks.
// The force() ensures Gradle resolves AGP 9.1.0 even when the plugin requests
// an older version, preventing silent compilation failures under Gradle 9.x.
gradle.beforeProject {
    buildscript {
        repositories {
            google()
            mavenCentral()
        }
        configurations.all {
            resolutionStrategy {
                force("com.android.tools.build:gradle:9.1.0")
                force("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Force compileSdk = 37 for all Android library subprojects (e.g. home_widget)
// so they satisfy transitive dependencies on glance-appwidget:1.3.0-alpha01 and
// remote-creation-android:1.0.0-alpha11 that require API 37.
// Also force namespace on plugins that still declare it only in AndroidManifest.xml,
// which AGP 9.x no longer supports for namespace resolution.
// AGP 9.x provides built-in Kotlin support, so plugins that skip kotlin-android
// on AGP 9+ are correct — do NOT force-apply it (causes lifecycle errors).
gradle.afterProject {
    extensions.findByType<com.android.build.gradle.LibraryExtension>()?.let { lib ->
        lib.compileSdk = 37

        // AGP 9.x requires namespace in build.gradle; inject from manifest if missing.
        // Accessing lib.namespace throws if not set in AGP 9.x, so use try-catch.
        val hasNamespace = try { !lib.namespace.isNullOrEmpty() } catch (_: Exception) { false }
        if (!hasNamespace) {
            val manifest = file("src/main/AndroidManifest.xml")
            if (manifest.exists()) {
                val pkg = Regex("""package\s*=\s*"([^"]+)"""")
                    .find(manifest.readText())?.groupValues?.get(1)
                if (!pkg.isNullOrEmpty()) {
                    lib.namespace = pkg
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
