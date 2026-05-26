// Expose AGP 9.1.0 and Kotlin 2.1.0 on the root buildscript classpath so that
// Flutter plugin subprojects whose build.gradle still declares older AGP/Kotlin
// in their own buildscript block resolve the correct version via the parent
// classloader (parent-first classloading).  Without this, plugins like
// file_picker load AGP 8.x from their own buildscript which is incompatible
// with Gradle 9.x and silently fails to compile.
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:9.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
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
// gradle.afterProject runs after each project's build script completes, avoiding
// both the ordering issue of plugins.withId (fires before compileSdk is set) and
// the "project already evaluated" error from project.afterEvaluate.
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
