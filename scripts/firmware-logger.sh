#!/bin/bash
# firmware-logger.sh — structured logger for the M51 firmware flow.
#
# Sourced by scripts/fetch-firmware.sh (and any step that touches the
# firmware). Every line carries an IST timestamp, a level and a stage,
# plus key=value fields, so a failed run can be replayed from the log
# alone.
#
# Usage:
#   FW_LOG_FILE=/path/to/firmware.log
#   source scripts/firmware-logger.sh
#   fw_log INFO  version-check "checkupdate done" region=INS tool=samloader-rs result=DXE3
#   fw_log ERROR download       "download failed" reason="..." bytes_done=123
#
# Log line format:
#   2026-11-24T23:56:11+05:30 [INFO] [download] message key=value key=value
#
# Levels: INFO, WARN, ERROR. Stages: version-check, download, verify,
# drive, logger.
#
# Retrofit: set FW_LOG_TS to an explicit IST timestamp for one call to
# record an event that already happened, e.g.
#   FW_LOG_TS=2026-11-24T23:54:00+05:30 fw_log INFO version-check "..."
# Never invent a timestamp — use the time the event actually happened
# (from the tool output / log that recorded it).

# Log file. The driver sets this to the file next to the firmware
# (~/workspace/firmware/m51-latest/firmware.log); default is stderr
# only if it is unset (never silently drop a line).
FW_LOG_FILE="${FW_LOG_FILE:-}"

fw_timestamp() {
    TZ=Asia/Kolkata date '+%Y-%m-%dT%H:%M:%S%:z'
}

# fw_log LEVEL STAGE MESSAGE [key=value ...]
fw_log() {
    local level="$1"; shift
    local stage="$1"; shift
    local message="$1"; shift
    local ts="${FW_LOG_TS:-$(fw_timestamp)}"
    local line="$ts [$level] [$stage] $message"
    local kv
    for kv in "$@"; do
        line="$line $kv"
    done
    # Always to stdout (so a terminal run shows it) and to the file.
    echo "$line"
    if [ -n "$FW_LOG_FILE" ]; then
        echo "$line" >> "$FW_LOG_FILE"
    fi
}

fw_info()  { fw_log INFO  "$@"; }
fw_warn()  { fw_log WARN  "$@"; }
fw_error() { fw_log ERROR "$@"; }

# fw_section TITLE — a visible separator for a new phase.
fw_section() {
    local ts="${FW_LOG_TS:-$(fw_timestamp)}"
    local line="$ts [INFO] ===== $1 ====="
    echo "$line"
    if [ -n "$FW_LOG_FILE" ]; then
        echo "$line" >> "$FW_LOG_FILE"
    fi
}

# fw_run STAGE "description" cmd... — logs the command, runs it, logs
# the exit code. The command's own output goes to stdout, not the log.
fw_run() {
    local stage="$1"; shift
    local desc="$1"; shift
    fw_log INFO "$stage" "run: $desc" cmd="$*"
    "$@"
    local rc=$?
    if [ "$rc" -eq 0 ]; then
        fw_log INFO "$stage" "ok: $desc" exit="$rc"
    else
        fw_log ERROR "$stage" "FAILED: $desc" exit="$rc"
    fi
    return "$rc"
}
