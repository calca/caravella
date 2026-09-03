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

// Keep Android library subprojects aligned with the app's compile SDK (see
// android/app/build.gradle.kts). Some plugins still set an older compile SDK
// and fail dependency metadata checks; others (e.g. permission_handler_android
// 14.0.0) need this one bumped in lockstep with the app's, or this override
// forces them back down to a level too old for the API symbols they reference.
// gradle.afterProject runs after each project's build script completes, avoiding
// both the ordering issue of plugins.withId (fires before compileSdk is set) and
// the "project already evaluated" error from project.afterEvaluate.
gradle.afterProject {
    extensions.findByType<com.android.build.gradle.LibraryExtension>()?.compileSdk = 37
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
