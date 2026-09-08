import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "moe.neri.hinatago"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
        }
    }

    defaultConfig {
        applicationId = "moe.neri.hinatago"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("default") {
            keyAlias = System.getenv("ANDROID_KEY_ALIAS") 
                ?: keystoreProperties.getProperty("keyAlias")
            
            keyPassword = System.getenv("ANDROID_KEY_PASSWORD") 
                ?: keystoreProperties.getProperty("keyPassword")
            
            storePassword = System.getenv("ANDROID_STORE_PASSWORD") 
                ?: keystoreProperties.getProperty("storePassword")

            val keystorePath = System.getenv("ANDROID_KEYSTORE_PATH") 
                ?: keystoreProperties.getProperty("storeFile")
            
            if (keystorePath != null) {
                storeFile = file(keystorePath)
            }
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("default")
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("default")
            
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {
    implementation("androidx.credentials:credentials:1.6.0")
    implementation("androidx.credentials:credentials-play-services-auth:1.6.0")
}

flutter {
    source = "../.."
}
