#!/system/bin/sh
RESETPROP=resetprop
command -v resetprop >/dev/null 2>&1 || RESETPROP=/data/adb/ksu/bin/resetprop
"$RESETPROP" net.tethering.noprovisioning true
