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
// gradle.afterProject runs after each project's build script completes, avoiding
// both the ordering issue of plugins.withId (fires before compileSdk is set) and
// the "project already evaluated" error from project.afterEvaluate.
gradle.afterProject {
    extensions.findByType<com.android.build.gradle.LibraryExtension>()?.compileSdk = 37
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
