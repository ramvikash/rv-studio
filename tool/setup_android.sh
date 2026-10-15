#!/usr/bin/env bash
# Generates the Android project around lib/ and applies the settings the app needs.
set -e
flutter create --platforms=android --project-name sd_studio --org com.example .
G=$(ls android/app/build.gradle.kts android/app/build.gradle 2>/dev/null | head -1)
sed -i -E 's/minSdk(Version)?[ =]+flutter\.minSdkVersion/minSdk = 26/' "$G"
# let Android unpack libsdcli.so to disk so it can be executed
sed -i '0,/^android {/s//android {\n    packaging { jniLibs { useLegacyPackaging = true } }/' "$G"
M=android/app/src/main/AndroidManifest.xml
grep -q 'permission.INTERNET' $M || sed -i 's#<application#<uses-permission android:name="android.permission.INTERNET"/>\n    <application#' $M
sed -i "s#android:label=\"[^\"]*\"#android:label=\"RV Studio\"#" $M
K=$(find android/app/src/main -name MainActivity.kt | head -1)
cat > "$K" <<'KT'
package com.example.sd_studio

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sd/native")
            .setMethodCallHandler { call, result ->
                if (call.method == "libDir") result.success(applicationInfo.nativeLibraryDir)
                else result.notImplemented()
            }
    }
}
KT
flutter pub get
