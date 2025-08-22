plugins {
    id("com.android.application")
    id("com.google.gms.google-services")  // This must be here for Firebase integration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter Gradle plugin
}

buildscript {
    repositories {
        google()  // Add Google repository
        mavenCentral()  // Maven central for dependencies
    }
    dependencies {
        classpath("com.google.gms:google-services:4.3.10")  // Firebase plugin
    }
}

android {
    namespace = "com.example.zymbiot"  // Set your app's namespace
    compileSdk = flutter.compileSdkVersion  // Use Flutter's compileSdkVersion

    defaultConfig {
        applicationId = "com.example.zymbiot"  // Unique Application ID
        minSdkVersion(23)  // Corrected: Use method call for minSdkVersion
        targetSdk = flutter.targetSdkVersion  // Use Flutter's targetSdkVersion
        versionCode = flutter.versionCode  // Define your version code
        versionName = flutter.versionName  // Define your version name
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"  // Kotlin compatibility
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")  // Define signing config for release
        }
    }
}

flutter {
    source = "../.."  // Define the path to the Flutter source
}
