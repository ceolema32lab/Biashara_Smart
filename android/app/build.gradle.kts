plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.biashara_smart"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Tumetumia VERSION_17 ili kuendana na mahitaji ya sasa ya Android
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // Lazima jvmTarget ilandane na compileOptions hapo juu
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.biashara_smart"
        
        // Gemini AI na Plugins nyingi za sasa zinahitaji angalau SDK 21
        minSdk = flutter.minSdkVersion 
        
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            // Ikiwekwa 'true' inasaidia kupunguza ukubwa wa APK (Obfuscation)
            // Lakini kwa sasa tumeiacha 'false' ili kuzuia error za kwanza za build
            isMinifyEnabled = false
            isShrinkResources = false
            
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Hapa unaweza kuongeza dependencies nyingine za asili za android kama ikihitajika
}
