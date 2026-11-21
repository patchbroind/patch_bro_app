import java.io.FileInputStream
import java.util.Properties
import java.util.Base64

plugins {
    id("com.android.application")
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

// Add the selected flavor's public client configuration to Dart defines.
if (appFlavor != null) {
    val flavorConfig = Properties()
    val flavorConfigFile = file("flavors/$appFlavor.properties")

    require(flavorConfigFile.isFile) {
        "Missing app flavor configuration: ${flavorConfigFile.path}"
    }

    flavorConfigFile.inputStream().use(flavorConfig::load)

    val dartDefines = gradle.startParameter.projectProperties["dart-defines"]
        ?.split(',')
        ?.filter(String::isNotBlank)
        ?.toMutableList()
        ?: mutableListOf()

    val definedNames = dartDefines.mapNotNull { encoded ->
        runCatching {
            String(Base64.getDecoder().decode(encoded), Charsets.UTF_8)
                .substringBefore('=')
        }.getOrNull()
    }.toMutableSet()

    val flavorDefines = buildMap {
        put("APP_FLAVOR", appFlavor)

        for (name in listOf(
            "SUPABASE_URL",
            "SUPABASE_PUBLISHABLE_KEY",
            "API_BASE_URL"
        )) {
            put(name, flavorConfig.getProperty(name).orEmpty())
        }
    }

    for ((name, value) in flavorDefines) {
        require(value.isNotBlank()) {
            "Missing $name in ${flavorConfigFile.path}"
        }

        if (definedNames.add(name)) {
            dartDefines += Base64.getEncoder()
                .encodeToString(
                    "$name=$value".toByteArray(Charsets.UTF_8)
                )
        }
    }

    extensions.extraProperties["dart-defines"] =
        dartDefines.joinToString(",")
}

// Core library desugaring for flutter_local_notifications.
dependencies {
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.4"
    )
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

// Built-in Kotlin compiler configuration.
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
