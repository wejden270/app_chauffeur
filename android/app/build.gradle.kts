plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter Gradle plugin
    // Add the Google services Gradle plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.chauffeurs_app"
    compileSdk = 35  // Keep at 35 for plugin compatibility
    ndkVersion = "25.1.8937393"  // Add this line after namespace declaration

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.chauffeurs_app"
        minSdk = 21
        targetSdk = 35  // Match compileSdk
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Activer MultiDex pour éviter les erreurs de dépassement de méthodes
        multiDexEnabled = true

        ndk {
            // Specify ABIs to build for
            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
        }
    }

    buildTypes {
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug") // Utilisation de debug pour éviter l’erreur
        }

        release {
            isMinifyEnabled = false  // Gardé désactivé pour éviter les erreurs
            isShrinkResources = false // Ajouté pour éviter le problème de Gradle
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")

            // Vérification si signingConfigs "release" est défini avant de l'utiliser
            if (signingConfigs.findByName("release") != null) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1") // Ajout de MultiDex

    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.12.0"))

    // Add the Firebase Analytics dependency
    implementation("com.google.firebase:firebase-analytics")

    // Add other Firebase dependencies as needed
    // For example: implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-messaging")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("com.google.android.material:material:1.11.0")  // Ajouter cette ligne
    implementation("androidx.core:core:1.10.0")
    implementation("androidx.window:window:1.0.0")
    implementation("androidx.window:window-java:1.0.0")
}
