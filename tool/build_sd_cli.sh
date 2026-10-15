#!/usr/bin/env bash
# Builds stable-diffusion.cpp's command-line tool for Android (arm64) and packs it
# as libsdcli.so so Android lets the app execute it.
set -e
NDK="${ANDROID_NDK_HOME:-$ANDROID_NDK_LATEST_HOME}"
rm -rf sdcpp
git clone --depth 1 --recursive https://github.com/leejet/stable-diffusion.cpp sdcpp
cd sdcpp
FLAGS="-march=armv8.2-a+dotprod+fp16"
cmake -B build \
  -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-28 \
  -DCMAKE_BUILD_TYPE=Release -DSD_BUILD_EXAMPLES=ON \
  -DGGML_OPENMP=OFF -DGGML_NATIVE=OFF \
  -DCMAKE_C_FLAGS="$FLAGS" -DCMAKE_CXX_FLAGS="$FLAGS"
cmake --build build -j"$(nproc)"
BIN=$(find build -type f \( -name sd-cli -o -name sd \) | head -1)
test -n "$BIN" || { echo "sd-cli binary not found"; exit 1; }
mkdir -p ../android/app/src/main/jniLibs/arm64-v8a
cp "$BIN" ../android/app/src/main/jniLibs/arm64-v8a/libsdcli.so
echo "packed $BIN"
