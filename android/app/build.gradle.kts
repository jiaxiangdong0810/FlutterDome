plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.untitled1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.untitled1"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildFeatures {
        buildConfig = true
        resValues = true
    }

    flavorDimensions += "env"

    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Flutter Demo Dev")
            buildConfigField("String", "BASE_URL", "\"https://api.dev.example.com\"")
            buildConfigField("String", "ENV_NAME", "\"dev\"")
            buildConfigField("boolean", "ENABLE_DEBUG_MENU", "true")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "Flutter Demo")
            buildConfigField("String", "BASE_URL", "\"https://api.example.com\"")
            buildConfigField("String", "ENV_NAME", "\"prod\"")
            buildConfigField("boolean", "ENABLE_DEBUG_MENU", "false")
        }
    }

    buildTypes {
        debug {
            isDebuggable = true
            isMinifyEnabled = false
            isShrinkResources = false
        }
        release {
            isDebuggable = false
            isMinifyEnabled = true
            isShrinkResources = true
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
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

// 默认使用 dev flavor 构建
// 这样在 Android Studio 直接点击运行或执行 flutter build apk 时，
// 不需要指定 --flavor 参数也会使用 dev 环境
tasks.configureEach {
    if (name == "assembleDebug") {
        dependsOn("assembleDevDebug")
        // 复制 devDebug 的输出到 debug 期望的位置
        doLast {
            copy {
                from("${layout.buildDirectory.get()}/outputs/flutter-apk/app-dev-debug.apk")
                into("${layout.buildDirectory.get()}/outputs/flutter-apk")
                rename("app-dev-debug.apk", "app-debug.apk")
            }
        }
    }
    if (name == "assembleRelease") {
        dependsOn("assembleDevRelease")
        doLast {
            copy {
                from("${layout.buildDirectory.get()}/outputs/flutter-apk/app-dev-release.apk")
                into("${layout.buildDirectory.get()}/outputs/flutter-apk")
                rename("app-dev-release.apk", "app-release.apk")
            }
        }
    }
}
