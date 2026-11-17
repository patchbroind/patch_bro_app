
import java.io.FileInputStream
import java.util.Properties
import java.util.Base64

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Detect the requested application flavor.
val appFlavor = gradle.startParameter.taskNames
    .map { it.lowercase() }
    .firstNotNullOfOrNull { task ->
        when {
            task.contains("worker") -> "worker"
            task.contains("employer") -> "employer"
            else -> null
        }
    }

// Supply APP_FLAVOR to Dart's String.fromEnvironment.
if (appFlavor != null) {
    val encodedFlavor = Base64.getEncoder()
        .encodeToString(
            "APP_FLAVOR=$appFlavor".toByteArray(Charsets.UTF_8)
        )

    extensions.extraProperties["dart-defines"] = encodedFlavor
}

// Core library desugaring for flutter_local_notifications.
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

// Load values from android/local.properties.
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")

if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

val mapsApiKey = localProperties.getProperty("MAPS_API_KEY") ?: ""

android {
    namespace = "com.example.patch_bro"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    buildFeatures {
        buildConfig = true
        resValues = true
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.patchbro"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    flavorDimensions += "app"

    productFlavors {
        create("worker") {
            dimension = "app"
            applicationIdSuffix = ".worker"
            resValue("string", "app_name", "Patch Bro Worker")
            buildConfigField("String", "APP_FLAVOR", "\"worker\"")
        }

        create("employer") {
            dimension = "app"
            applicationIdSuffix = ".employer"
            resValue("string", "app_name", "Patch Bro Employer")
            buildConfigField("String", "APP_FLAVOR", "\"employer\"")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
