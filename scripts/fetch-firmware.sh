#!/bin/bash
# fetch-firmware.sh — download, verify and mirror the M51 stock firmware.
#
# The whole flow, end to end, through scripts/firmware-logger.sh:
#   1. version-check — confirm the latest official firmware for INS
#   2. download      — Samsung FUS via samloader-rs (resumable)
#   3. verify        — size, zip contents (BL/AP/CP/CSC/HOME_CSC),
#                      MD5/SHA-256, trailing .tar.md5 checks
#   4. drive         — chunked upload to Google Drive (the Drive CLI
#                      cannot multipart-upload multi-GB files) + verify
#                      every chunk landed (size + md5Checksum)
#   5. log upload    — the log file itself goes to Drive with the firmware
#
# Re-runnable and idempotent: a completed step is skipped on re-run
# (the download resumes from its .part file; chunks already on Drive
# by name+size are not re-uploaded). Nothing is flashed.
#
# Usage:
#   FW_DIR=~/workspace/firmware/m51-latest \
#   SAMLOADER=~/workspace/firmware/tools/samloader \
#   bash scripts/fetch-firmware.sh [--check-only] [--skip-drive]
#
# Logs to $FW_DIR/firmware.log (IST timestamps, levels, stages).
# Exit code is non-zero if any step fails; read the log to re-run
# exactly the failed step (see docs/FIRMWARE.md "Logger").

set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/firmware-logger.sh"

# ---- pinned inputs (settled 2026-11-24, see docs/FIRMWARE.md) ----
MODEL="${MODEL:-SM-M515F}"
REGION="${REGION:-INS}"
# DXJ1 is the latest official firmware for INS. DXJ2 is the same build
# for the Latin America CSC group only; DXE3 is what a no-IMEI FUS
# checkupdate wrongly reports as latest. Do not "fix" this by
# switching to DXJ2 or to whatever checkupdate returns.
FW_VERSION="${FW_VERSION:-M515FXXU6DXJ1/M515FODM6DXJ1/M515FXXU6DXJ1}"
FW_FILE="${FW_FILE:-SM-M515F_2_20241004032751_smm7rurrx5_fac.zip}"
FW_DIR="${FW_DIR:-$HOME/workspace/firmware/m51-latest}"
SAMLOADER="${SAMLOADER:-$HOME/workspace/firmware/tools/samloader}"
GWS_CLI="${GWS_CLI:-/opt/hatch/bin/hatch_gws_cli}"
DRIVE_FOLDER_NAME="${DRIVE_FOLDER_NAME:-firmware}"
# Drive parent folder: backups/m51-hyperos (see docs/FIRMWARE.md).
# Resolved at runtime by name; the ID is logged, never hard-coded.
DRIVE_PARENT_NAME="${DRIVE_PARENT_NAME:-m51-hyperos}"
CHUNK_BYTES="${CHUNK_BYTES:-1073741824}"   # 1 GiB split parts

FW_LOG_FILE="$FW_DIR/firmware.log"
export FW_LOG_FILE
mkdir -p "$FW_DIR"

CHECK_ONLY=0
SKIP_DRIVE=0
for arg in "$@"; do
    case "$arg" in
        --check-only) CHECK_ONLY=1 ;;
        --skip-drive) SKIP_DRIVE=1 ;;
        *) fw_error logger "unknown argument" arg="$arg"; exit 2 ;;
    esac
done

fail() { fw_error "$1" "$2"; exit 1; }

# ------------------------------------------------------------------
# 1. version-check
# ------------------------------------------------------------------
fw_section "1. version-check ($MODEL / $REGION)"
[ -x "$SAMLOADER" ] || fail version-check "samloader-rs not found or not executable" path="$SAMLOADER"
"$SAMLOADER" --version 2>&1 | head -1 | while IFS= read -r line; do
    fw_log INFO version-check "tool version" tool=samloader-rs out="$line"
done

RAW_CHECK="$("$SAMLOADER" check-update --model "$MODEL" --region "$REGION" 2>&1)"
RC=$?
fw_log INFO version-check "check-update done" region="$REGION" tool=samloader-rs exit="$RC" raw_response="$RAW_CHECK"
# A no-IMEI checkupdate returns a STALE track (DXE3 for INS). That is
# expected and is not the version we download. The pinned version
# above was cross-checked against the SamFrew INS listing (DXJ1
# marked "Latest") and the DXJ1 firmware page's identifiers.
case "$RAW_CHECK" in
    *DXE3*) fw_warn version-check "checkupdate returned DXE3 — known stale no-IMEI track, ignoring" expected="$FW_VERSION" ;;
esac
fw_log INFO version-check "pinned version in use" version="$FW_VERSION" file="$FW_FILE" \
    evidence="SamFrew INS listing (DXJ1 Latest) + DXJ1 firmware page identifiers + FUS server filename match"
[ "$CHECK_ONLY" -eq 1 ] && { fw_log INFO version-check "check-only: stopping here"; exit 0; }

# ------------------------------------------------------------------
# 2. download (resumable via samloader-rs .part file)
# ------------------------------------------------------------------
fw_section "2. download (FUS via samloader-rs)"
ZIP_PATH="$FW_DIR/$FW_FILE"
if [ -f "$ZIP_PATH" ]; then
    fw_log INFO download "final zip already present, skipping download" path="$ZIP_PATH" bytes="$(stat -c %s "$ZIP_PATH")"
else
    fw_log INFO download "starting download" source="Samsung FUS" model="$MODEL" region="$REGION" version="$FW_VERSION" out_dir="$FW_DIR"
    START_TS=$(date +%s)
    "$SAMLOADER" download -m "$MODEL" -r "$REGION" -v "$FW_VERSION" -d "$FW_DIR" 2>&1 | while IFS= read -r line; do
        fw_log INFO download "samloader: $line"
    done
    # NOTE: the pipe above runs the download in a subshell, so its exit
    # code is not visible here — presence + size of the final file is
    # the check, and verify (step 3) is the gate.
    END_TS=$(date +%s)
    fw_log INFO download "download command returned" duration_s="$((END_TS - START_TS))"
    [ -f "$ZIP_PATH" ] || fail download "final zip missing after download" path="$ZIP_PATH" \
        hint="re-run this script — samloader-rs resumes from the .part file"
    fw_log INFO download "download complete" path="$ZIP_PATH" bytes="$(stat -c %s "$ZIP_PATH")"
fi

# ------------------------------------------------------------------
# 3. verify
# ------------------------------------------------------------------
fw_section "3. verify"
SIZE="$(stat -c %s "$ZIP_PATH")"
fw_log INFO verify "zip size" path="$ZIP_PATH" bytes="$SIZE"
[ "$SIZE" -eq 5964436871 ] || fw_warn verify "zip size differs from the 2026-11-24 reference" bytes="$SIZE" reference=5964436871

fw_log INFO verify "listing zip contents"
CONTENTS="$(unzip -l "$ZIP_PATH")"
echo "$CONTENTS" | while IFS= read -r line; do fw_log INFO verify "zip entry: $line"; done
for want in BL_M515FXXU6DXJ1 AP_M515FXXU6DXJ1 CP_M515FXXU6DXJ1 HOME_CSC_ODM_M515FODM6DXJ1 CSC_ODM_M515FODM6DXJ1; do
    if echo "$CONTENTS" | grep -q "$want"; then
        fw_log INFO verify "present: $want"
    else
        fail verify "missing from zip" file="$want"
    fi
done

MD5="$(md5sum "$ZIP_PATH" | awk '{print $1}')"
SHA256="$(sha256sum "$ZIP_PATH" | awk '{print $1}')"
fw_log INFO verify "hashes computed" md5="$MD5" sha256="$SHA256"
# Reference hashes from the verified 2026-11-24 download. If these are
# ever updated, update docs/FIRMWARE.md in the same commit.
if [ "$MD5" = "d3afc8d09f0bf94faaeccfd29517c9df" ]; then
    fw_log INFO verify "MD5 matches reference"
else
    fw_warn verify "MD5 differs from reference" md5="$MD5" reference="d3afc8d09f0bf94faaeccfd29517c9df"
fi
if [ "$SHA256" = "0e71ca19c9d2af6eb8b63e9882218792f855d90326893312bdfa4e1ff5ab50c5" ]; then
    fw_log INFO verify "SHA-256 matches reference"
else
    fw_warn verify "SHA-256 differs from reference" sha256="$SHA256" reference="0e71ca19c9d2af6eb8b63e9882218792f855d90326893312bdfa4e1ff5ab50c5"
fi

EXTRACT_DIR="$FW_DIR/extracted"
mkdir -p "$EXTRACT_DIR"
fw_log INFO verify "extracting tars for trailing-MD5 checks" out_dir="$EXTRACT_DIR"
unzip -o -q "$ZIP_PATH" -d "$EXTRACT_DIR" || fail verify "unzip failed (zip CRC error?)" path="$ZIP_PATH"
fw_log INFO verify "extraction ok — zip CRCs clean"
for tar in "$EXTRACT_DIR"/*.tar.md5; do
    base="$(basename "$tar")"
    fw_log INFO verify "trailing-MD5 check" file="$base"
    if "$SAMLOADER" verify-md5 "$tar" 2>&1; then
        fw_log INFO verify "trailing-MD5 OK" file="$base"
    else
        fail verify "trailing-MD5 FAILED" file="$base"
    fi
done
fw_log INFO verify "all verification passed" md5="$MD5" sha256="$SHA256"

# ------------------------------------------------------------------
# 4. drive (chunked — the CLI cannot multipart-upload multi-GB files)
# ------------------------------------------------------------------
if [ "$SKIP_DRIVE" -eq 1 ]; then
    fw_log INFO drive "skipped (--skip-drive). Re-run without it to upload."
else
    fw_section "4. drive upload (chunked, 1 GiB parts)"
    fw_log INFO drive "resolving parent folder" name="$DRIVE_PARENT_NAME"
    PARENT_JSON="$("$GWS_CLI" drive files list --params "{\"q\":\"name = '$DRIVE_PARENT_NAME' and mimeType = 'application/vnd.google-apps.folder' and trashed=false\",\"pageSize\":5,\"fields\":\"files(id,name)\"}" 2>&1)" \
        || fail drive "could not list Drive folders" error="$PARENT_JSON"
    PARENT_ID="$(echo "$PARENT_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['files'][0]['id'] if d.get('files') else '')" 2>/dev/null)"
    [ -n "$PARENT_ID" ] || fail drive "Drive folder not found" name="$DRIVE_PARENT_NAME"
    fw_log INFO drive "parent folder resolved" name="$DRIVE_PARENT_NAME" folder_id="$PARENT_ID"

    # Firmware subfolder (create if missing).
    SUB_JSON="$("$GWS_CLI" drive files list --params "{\"q\":\"name = '$DRIVE_FOLDER_NAME' and '$PARENT_ID' in parents and mimeType = 'application/vnd.google-apps.folder' and trashed=false\",\"pageSize\":5,\"fields\":\"files(id,name)\"}" 2>&1)"
    SUB_ID="$(echo "$SUB_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['files'][0]['id'] if d.get('files') else '')" 2>/dev/null)"
    if [ -z "$SUB_ID" ]; then
        SUB_JSON="$("$GWS_CLI" drive files create --params '{"ignoreDefaultVisibility":true}' --json "{\"name\":\"$DRIVE_FOLDER_NAME\",\"mimeType\":\"application/vnd.google-apps.folder\",\"parents\":[\"$PARENT_ID\"]}" 2>&1)" \
            || fail drive "could not create firmware folder" error="$SUB_JSON"
        SUB_ID="$(echo "$SUB_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)"
        fw_log INFO drive "created firmware folder" name="$DRIVE_FOLDER_NAME" folder_id="$SUB_ID"
    else
        fw_log INFO drive "firmware folder exists" name="$DRIVE_FOLDER_NAME" folder_id="$SUB_ID"
    fi

    # Split (idempotent: split is cheap and deterministic).
    SPLIT_DIR="$FW_DIR/split"
    mkdir -p "$SPLIT_DIR"
    fw_log INFO drive "splitting zip into 1 GiB parts" chunk_bytes="$CHUNK_BYTES" out_dir="$SPLIT_DIR"
    split -b "$CHUNK_BYTES" -d --suffix-length=2 "$ZIP_PATH" "$SPLIT_DIR/$FW_FILE.part" \
        || fail drive "split failed"
    for part in "$SPLIT_DIR"/"$FW_FILE".part*; do
        pname="$(basename "$part")"
        pbytes="$(stat -c %s "$part")"
        pmd5="$(md5sum "$part" | awk '{print $1}')"
        # Skip parts already on Drive with the same name+size.
        EXIST="$("$GWS_CLI" drive files list --params "{\"q\":\"name = '$pname' and '$SUB_ID' in parents and trashed=false\",\"pageSize\":5,\"fields\":\"files(id,name,size,md5Checksum)\"}" 2>&1)"
        E_SIZE="$(echo "$EXIST" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['files'][0].get('size','') if d.get('files') else '')" 2>/dev/null)"
        if [ -n "$E_SIZE" ] && [ "$E_SIZE" = "$pbytes" ]; then
            fw_log INFO drive "part already on Drive, skipping" part="$pname" bytes="$pbytes"
            continue
        fi
        fw_log INFO drive "uploading part" part="$pname" bytes="$pbytes" md5="$pmd5" method="hatch_gws_cli +upload (multipart, single part)"
        U_START=$(date +%s)
        UP_JSON="$("$GWS_CLI" drive +upload "$part" --parent "$SUB_ID" --name "$pname" 2>&1)" \
            || fail drive "upload failed" part="$pname" error="$UP_JSON"
        U_END=$(date +%s)
        UP_ID="$(echo "$UP_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)"
        # Verify it landed: size + md5Checksum from Drive.
        GOT="$("$GWS_CLI" drive files get --params "{\"fileId\":\"$UP_ID\",\"fields\":\"id,name,size,md5Checksum,webViewLink\"}" 2>&1)"
        G_SIZE="$(echo "$GOT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('size',''))" 2>/dev/null)"
        G_MD5="$(echo "$GOT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('md5Checksum',''))" 2>/dev/null)"
        if [ "$G_SIZE" = "$pbytes" ] && [ "$G_MD5" = "$pmd5" ]; then
            fw_log INFO drive "part verified on Drive" part="$pname" bytes="$G_SIZE" md5="$G_MD5" duration_s="$((U_END - U_START))" file_id="$UP_ID"
        else
            fail drive "part verification FAILED (size/md5 mismatch)" part="$pname" drive_size="$G_SIZE" local_size="$pbytes" drive_md5="$G_MD5" local_md5="$pmd5"
        fi
    done
    fw_log INFO drive "all parts uploaded and verified" folder="backups/m51-hyperos/firmware" parts="$(find "$SPLIT_DIR" -maxdepth 1 -type f | wc -l)"
    fw_log INFO drive "rejoin on download with: cat ${FW_FILE}.part?? > ${FW_FILE} && sha256sum ${FW_FILE} (expect 0e71ca19c9d2af6eb8b63e9882218792f855d90326893312bdfa4e1ff5ab50c5)"
fi

# ------------------------------------------------------------------
# 5. log upload — the log itself goes to Drive with the firmware
# ------------------------------------------------------------------
if [ "$SKIP_DRIVE" -eq 0 ]; then
    fw_section "5. log upload"
    fw_log INFO drive "uploading this log file to Drive" path="$FW_LOG_FILE"
    if "$GWS_CLI" drive +upload "$FW_LOG_FILE" --parent "$SUB_ID" --name "firmware.log" 2>&1; then
        fw_log INFO drive "log uploaded" name="firmware.log"
    else
        fw_warn drive "log upload failed (firmware parts above are unaffected)"
    fi
fi

fw_section "done"
fw_log INFO drive "firmware saved" drive_folder="backups/m51-hyperos/firmware" file="$FW_FILE" bytes="$SIZE" md5="$MD5" sha256="$SHA256"
