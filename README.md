# RV Studio (Flutter, MVVM, Stable Diffusion 1.5 on-device)

Build: push this folder to GitHub (branch main) and run Actions > Build APK, or locally
`bash tool/setup_android.sh && bash tool/build_sd_cli.sh && flutter build apk --release --target-platform android-arm64`
(local build needs Flutter, the Android SDK and NDK, cmake, git).

Engine: stable-diffusion.cpp's command-line tool, built for arm64 and packed as libsdcli.so.
Only data/sd_runner.dart knows its flags.

Structure: models/ (GenParams, catalog), data/ (SdRunner, ModelStore), viewmodels/ (Create, Models), views/ (Create, Gallery, Models), core/ (theme).
