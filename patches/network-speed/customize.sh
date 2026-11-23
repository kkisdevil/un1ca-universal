#!/bin/sh
# This module needs no customize.sh logic.
#
# Upstream apply_modules.sh (scripts/internal/apply_modules.sh in
# salvogiangri/UN1CA) applies every *.patch under this module's smali/
# directory automatically, in sorted order, with git apply against the
# apktool-decoded APK:
#
#   smali/system/priv-app/SecSettings/SecSettings.apk/
#     0001-Enable-real-time-network-speed-in-status-bar.patch
#
# Nothing else is needed. Do not add a customize.sh that re-applies the
# same patch — apply_modules.sh would apply it twice and the second
# application would fail with "patch does not apply".
