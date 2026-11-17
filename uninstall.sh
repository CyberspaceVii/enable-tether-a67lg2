#!/system/bin/sh
. "$(dirname "$0")/apn.sh"
(
  until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 2; done
  sleep 10
  if restore_apns; then
    rm -rf "$STATE"
    rmdir /data/adb/cyberspacevii 2>/dev/null
  else
    echo "Enable Tether: APN restore failed. Backup retained in $STATE." >&2
  fi
) &
