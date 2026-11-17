#!/system/bin/sh
. "$(dirname "$0")/apn.sh"
until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 2; done
sleep 10
apply_apns
