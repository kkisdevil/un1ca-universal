#!/usr/bin/env bash
# Copyright (c) 2026 Kartik Deepak Sormare (kkisdevil) — UN1CA Universal
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Install the smali tools upstream's camera patch needs on PATH.
#
# Build ROM #3 (2026-11-24) died in the upstream "Camera patches"
# module (unica/patches/camera/customize.sh) because
# target/m51/patches/tweaks/patch_camera.py calls three bare commands
# that nothing in the build installs:
#   baksmali disassemble ...   (disassemble SamsungCamera classes.dex)
#   smali assemble ...         (reassemble the patched dex)
#   apksigner sign ...         (re-sign the APK with security/aosp_platform.*)
# Upstream CI installs none of them either — Arnav's own CI runs have
# all failed since the patch landed (2026-11-12) — so this is not a
# porter-only gap; the porter has to provision them itself.
#
# Where they come from:
#   * baksmali / smali — the classes ship INSIDE the apktool jar that
#     upstream's build_dependencies.sh already builds (apktool relocates
#     org.jf.smali to com.android.tools.smali). The wrappers run those
#     classes with the runner's JDK 17. No extra download.
#     Fallback, if a future apktool build drops them: the thin jars from
#     Maven Central (org.smali 2.5.2 + their deps) under
#     $TOOLS_DIR/smali-libs.
#   * apksigner — Android SDK build-tools r34 (dl.google.com, ~61 MB),
#     extracted under $TOOLS_DIR/android-14 and reached through a
#     wrapper (the launcher resolves its lib/ relative to its own path,
#     so it must NOT be symlinked into bin/).
#
# Installs into $TOOLS_DIR/bin, which the workflow adds to GITHUB_PATH
# in "Generate build config" — so every later step (Build ROM) sees
# them. Idempotent: already-installed tools are verified and skipped,
# so re-runs (and the cached out/tools dir) cost nothing.
#
# Usage:
#   bash scripts/install-smali-tools.sh
#   TOOLS_DIR is taken from the environment (set by the workflow's
#   "Generate build config" step) or, when run inside the upstream
#   checkout, defaults to $PWD/out/tools.
set -euo pipefail

if [ -n "${TOOLS_DIR:-}" ]; then
    :
elif [ -f "$PWD/buildenv.sh" ]; then
    TOOLS_DIR="$PWD/out/tools"
else
    echo "TOOLS_DIR is not set and this is not the upstream checkout —" >&2
    echo "run from the upstream checkout, or set TOOLS_DIR=/path/to/out/tools" >&2
    exit 1
fi
BIN_DIR="$TOOLS_DIR/bin"
mkdir -p "$BIN_DIR"

command -v java >/dev/null 2>&1 || { echo "java is not on PATH — JDK 17 must be installed first (setup-java step)" >&2; exit 1; }
command -v zip >/dev/null 2>&1 || { echo "zip is not on PATH — patch_camera.py needs it" >&2; exit 1; }

APKTOOL_JAR="$BIN_DIR/apktool.jar"
SMALI_LIBS_DIR="$TOOLS_DIR/smali-libs"

# --- baksmali / smali wrappers -------------------------------------------
# Preferred: run the relocated classes from the apktool jar built by
# build_dependencies.sh. Fall back to Maven Central thin jars.
write_apktool_wrappers() {
    cat > "$BIN_DIR/baksmali" <<'EOF'
#!/usr/bin/env bash
# baksmali via the apktool jar (classes relocated to com.android.tools.smali).
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec java -cp "$DIR/apktool.jar" com.android.tools.smali.baksmali.Main "$@"
EOF
    cat > "$BIN_DIR/smali" <<'EOF'
#!/usr/bin/env bash
# smali via the apktool jar (classes relocated to com.android.tools.smali).
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec java -cp "$DIR/apktool.jar" com.android.tools.smali.smali.Main "$@"
EOF
    chmod +x "$BIN_DIR/baksmali" "$BIN_DIR/smali"
}

write_maven_wrappers() {
    # Thin jars need the full dependency classpath (org.smali 2.5.2).
    local cp=""
    local jar
    for jar in "$SMALI_LIBS_DIR"/*.jar; do
        cp+="$jar:"
    done
    cat > "$BIN_DIR/baksmali" <<EOF
#!/usr/bin/env bash
# baksmali via Maven Central thin jars (apktool jar lacks the classes).
set -euo pipefail
exec java -cp "$cp" org.jf.baksmali.Main "\$@"
EOF
    cat > "$BIN_DIR/smali" <<EOF
#!/usr/bin/env bash
# smali via Maven Central thin jars (apktool jar lacks the classes).
set -euo pipefail
exec java -cp "$cp" org.jf.smali.Main "\$@"
EOF
    chmod +x "$BIN_DIR/baksmali" "$BIN_DIR/smali"
}

download_maven_jars() {
    local base="https://repo1.maven.org/maven2"
    mkdir -p "$SMALI_LIBS_DIR"
    # org.smali 2.5.2 + deps from the baksmali/smali poms.
    local artifacts=(
        "org/smali/baksmali/2.5.2/baksmali-2.5.2.jar"
        "org/smali/smali/2.5.2/smali-2.5.2.jar"
        "org/smali/dexlib2/2.5.2/dexlib2-2.5.2.jar"
        "org/smali/util/2.5.2/util-2.5.2.jar"
        "com/google/guava/guava/27.1-android/guava-27.1-android.jar"
        "com/beust/jcommander/1.64/jcommander-1.64.jar"
        "org/antlr/antlr/3.5.2/antlr-3.5.2.jar"
        "org/antlr/antlr-runtime/3.5.2/antlr-runtime-3.5.2.jar"
        "org/antlr/stringtemplate/3.2.1/stringtemplate-3.2.1.jar"
    )
    for art in "${artifacts[@]}"; do
        local file
        file="$SMALI_LIBS_DIR/$(basename "$art")"
        if [ ! -s "$file" ]; then
            echo "Downloading $art ..."
            curl -fsSL "$base/$art" -o "$file"
        fi
    done
}

apktool_has_smali() {
    [ -f "$APKTOOL_JAR" ] || return 1
    # Read the listing into a variable first: with `set -o pipefail`,
    # `unzip -l | grep -q` fails on SIGPIPE because grep -q closes the
    # pipe as soon as it matches and unzip then dies with status 141.
    local listing
    listing="$(unzip -l "$APKTOOL_JAR" 2>/dev/null)" || return 1
    grep -q "com/android/tools/smali/baksmali/Main.class" <<< "$listing" \
        && grep -q "com/android/tools/smali/smali/Main.class" <<< "$listing"
}

if "$BIN_DIR/baksmali" --version >/dev/null 2>&1 && "$BIN_DIR/smali" --version >/dev/null 2>&1; then
    echo "baksmali + smali already installed and working — skipping."
else
    if apktool_has_smali; then
        echo "Using baksmali/smali classes from $APKTOOL_JAR"
        write_apktool_wrappers
    else
        echo "apktool.jar lacks the smali classes — falling back to Maven Central jars."
        download_maven_jars
        write_maven_wrappers
    fi
    echo "Verifying baksmali/smali..."
    "$BIN_DIR/baksmali" --version
    "$BIN_DIR/smali" --version
fi

# --- apksigner ------------------------------------------------------------
# From Android SDK build-tools r34 (dl.google.com). The zip extracts to
# android-14/ ; the launcher resolves lib/ relative to its own path, so
# bin/apksigner is a wrapper that execs the real launcher by absolute
# path instead of a symlink.
BUILD_TOOLS_ZIP="$TOOLS_DIR/cache/build-tools_r34-linux.zip"
BUILD_TOOLS_DIR="$TOOLS_DIR/android-14"

if [ -x "$BUILD_TOOLS_DIR/apksigner" ] && "$BIN_DIR/apksigner" version >/dev/null 2>&1; then
    echo "apksigner already installed and working — skipping."
else
    mkdir -p "$TOOLS_DIR/cache"
    if [ ! -s "$BUILD_TOOLS_ZIP" ]; then
        echo "Downloading Android build-tools r34 (apksigner) ..."
        curl -fsSL "https://dl.google.com/android/repository/build-tools_r34-linux.zip" \
            -o "$BUILD_TOOLS_ZIP"
    fi
    echo "Extracting apksigner ..."
    rm -rf "$BUILD_TOOLS_DIR"
    unzip -q -o "$BUILD_TOOLS_ZIP" -d "$TOOLS_DIR"
    [ -x "$BUILD_TOOLS_DIR/apksigner" ] || { echo "apksigner not found in $BUILD_TOOLS_ZIP" >&2; exit 1; }
    cat > "$BIN_DIR/apksigner" <<EOF
#!/usr/bin/env bash
# apksigner from Android build-tools r34 (see install-smali-tools.sh).
set -euo pipefail
exec "$BUILD_TOOLS_DIR/apksigner" "\$@"
EOF
    chmod +x "$BIN_DIR/apksigner"
    echo "Verifying apksigner..."
    "$BIN_DIR/apksigner" version
fi

echo "smali tools ready in $BIN_DIR:"
ls -l "$BIN_DIR/baksmali" "$BIN_DIR/smali" "$BIN_DIR/apksigner"
