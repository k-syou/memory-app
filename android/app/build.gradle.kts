plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.memory.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.memory.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        getByName("debug") {
            // 기본 debug keystore 사용
        }
        
        create("release") {
            // GitHub Actions에서는 ~/.android/debug.keystore 사용
            // 로컬에서는 기본 debug keystore 사용
            val keystorePath = System.getenv("ANDROID_KEYSTORE_PATH") 
                ?: "${System.getProperty("user.home")}/.android/debug.keystore"
            val keystorePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD") ?: "android"
            val keyAliasEnv = System.getenv("ANDROID_KEY_ALIAS") ?: "androiddebugkey"
            val keyPasswordEnv = System.getenv("ANDROID_KEY_PASSWORD") ?: "android"
            
            if (file(keystorePath).exists()) {
                storeFile = file(keystorePath)
                storePassword = keystorePassword
                keyAlias = keyAliasEnv
                keyPassword = keyPasswordEnv
            } else {
                // keystore가 없으면 debug keystore 사용
                val defaultKeystorePath = "${System.getProperty("user.home")}/.android/debug.keystore"
                if (file(defaultKeystorePath).exists()) {
                    storeFile = file(defaultKeystorePath)
                    storePassword = "android"
                    keyAlias = "androiddebugkey"
                    keyPassword = "android"
                }
            }
        }
    }

    buildTypes {
        release {
            // release signing config 사용 (명시적으로 지정)
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
