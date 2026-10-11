#!/bin/bash
# Se ejecuta en la Mac de GitHub Actions. No necesita ejecutar el simulador.
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

if [[ "$(uname -s)" != "Darwin" ]]; then
    printf '%s\n' 'Este script necesita macOS y Xcode. En Windows, ejecuta el workflow de GitHub Actions.' >&2
    exit 1
fi

command -v xcodebuild >/dev/null
test -f MapasYPermisos.xcodeproj/project.pbxproj
xcodebuild -version

mkdir -p .build-cloud dist-cloud
build_dir="$(mktemp -d "$project_root/.build-cloud/run.XXXXXX")"

xcodebuild \
    -project MapasYPermisos.xcodeproj \
    -scheme MapasYPermisos \
    -configuration Release \
    -sdk iphonesimulator \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$build_dir/DerivedData" \
    ARCHS=arm64 \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGNING_ALLOWED=NO \
    build 2>&1 | tee "$build_dir/build.log"

app_path="$build_dir/DerivedData/Build/Products/Release-iphonesimulator/MapasYPermisos.app"
test -d "$app_path"

# Distinguir ARM64 de simulador de ARM64 para un iPhone fisico.
platform="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleSupportedPlatforms:0' "$app_path/Info.plist")"
if [[ "$platform" != "iPhoneSimulator" ]]; then
    printf '%s\n' "Plataforma inesperada: $platform. Se necesita iPhoneSimulator." >&2
    exit 1
fi

executable="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$app_path/Info.plist")"
lipo -verify_arch arm64 "$app_path/$executable"

build_id="${GITHUB_SHA:-$(date -u +%Y%m%dT%H%M%SZ)}"
output_path="$project_root/dist-cloud/MapasYPermisos-Simulator-${build_id:0:12}.zip"
ditto -c -k --sequesterRsrc --keepParent "$app_path" "$output_path"
unzip -t "$output_path"

printf '\nAplicacion compilada para Appetize: %s\n' "$output_path"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    printf '%s\n' \
        '## Compilacion terminada' \
        '' \
        "Commit: $build_id" \
        '' \
        'Plataforma verificada: iPhoneSimulator. Arquitectura: arm64.' \
        '' \
        'Descarga el artefacto y extrae su ZIP exterior. Sube a Appetize el ZIP interior MapasYPermisos-Simulator-....zip.' \
        '' \
        'La compilacion no prueba el mapa ni los permisos; compruebalos en Appetize.' \
        >> "$GITHUB_STEP_SUMMARY"
fi

