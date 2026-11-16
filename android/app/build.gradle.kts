import java.util.Properties
import java.io.FileInputStream
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.plugin.compose")
    id("com.google.devtools.ksp")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Explicit override (Gradle property or env var) forces the same value for every flavor.
// Without one, the widget defaults on for dev/staging and off for prod (see per-flavor resValue below).
val enableAndroidWidgetOverride: Boolean? = (project.findProperty("enableAndroidWidget") as? String)?.toBoolean()
    ?: System.getenv("ENABLE_ANDROID_WIDGET")?.toBoolean()

// Release signing key (android/key.properties, written by CI from secrets).
// Without it — local checkouts, F-Droid — release builds come out unsigned
// instead of failing on an empty signing config; F-Droid signs the APK itself.
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()

android {
    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                val keystoreProperties = Properties()
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }
    namespace = "io.caravella.egm"
    // permission_handler_android 14.0.0 requires compileSdk 37 (its own
    // breaking-change note); Flutter 3.47.2's own default is still 36.
    compileSdk = 37
    ndkVersion = "28.2.13676358"

    // Robolectric needs the merged manifest and resources (App Functions tests).
    testOptions {
        unitTests.isIncludeAndroidResources = true
        unitTests.all { it.maxHeapSize = "2g" }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "io.caravella.egm"
        // Android 10+. Raised from Flutter's default (24) when moving to
        // edge-to-edge everywhere; no active installs were below it.
        minSdk = 29
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildFeatures {
        compose = true
        resValues = true
    }

    flavorDimensions.add("environment")
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Caravella - Dev")
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_dev"
            resValue("bool", "enable_android_widget", (enableAndroidWidgetOverride ?: true).toString())
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "Caravella - Staging")
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher_staging"
            resValue("bool", "enable_android_widget", (enableAndroidWidgetOverride ?: true).toString())
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Caravella")
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher"
            resValue("bool", "enable_android_widget", (enableAndroidWidgetOverride ?: false).toString())
        }
    }

    buildTypes {
        release {
            if (hasReleaseKeystore) signingConfig = signingConfigs.getByName("release")
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            // Ship native symbol tables in the App Bundle so Play can
            // symbolicate native crashes/ANRs (Play Console recommendation).
            ndk { debugSymbolLevel = "SYMBOL_TABLE" }
        }
    }
}

flutter {
    source = "../.."
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_11)
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")

    // Android App Functions – exposes Caravella capabilities to Android AI agents.
    // See: https://developer.android.com/reference/androidx/appfunctions
    // The compiler (KSP) generates CaravellaAppFunctionService and its XML from the
    // @AppFunctionDeclaration functions of BaseCaravellaAppFunctionService.
    // Keep the two versions together.
    implementation("androidx.appfunctions:appfunctions:1.0.0-rc01")
    ksp("androidx.appfunctions:appfunctions-compiler:1.0.0-rc01")
    implementation("androidx.glance:glance-appwidget:1.1.1")
    implementation("androidx.activity:activity-compose:1.13.0")
    implementation("androidx.compose.material:material-icons-core:1.7.8")
    implementation("androidx.compose.material3:material3:1.4.0")

    // Plain-JVM unit tests (android/app/src/test) for pure Kotlin logic that
    // doesn't touch the Android framework — see WidgetFormattingTest.
    testImplementation("junit:junit:4.13.2")
    // App Functions run through their generated service on Robolectric
    // (AppFunctionTestRule) — see CaravellaAppFunctionsTest.
    testImplementation("androidx.appfunctions:appfunctions-testing:1.0.0-rc01")
    kspTest("androidx.appfunctions:appfunctions-compiler:1.0.0-rc01")
    testImplementation("org.robolectric:robolectric:4.18")
    testImplementation("androidx.test:core:1.7.0")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.11.0")
}
