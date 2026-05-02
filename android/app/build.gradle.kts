plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.waddah_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    configurations {
    all {
        exclude(group = "unity-classes", module = "unity-classes")
    }
}

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.waddah_app"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    repositories {
        flatDir {
            dirs("../../unity/unityLibrary/libs")
        }
    }
}

flutter {
    source = "../.."
}

configurations.all {
    resolutionStrategy {
        force("com.unity3d.player:unity-classes:+")
    }
}

dependencies {
}