#!/system/bin/sh
[ "$(getprop ro.product.device)" = A67L_Gen2 ] || abort "This module is for the Foxxd A67L Gen 2."
[ "$KSU" = true ] || abort "KernelSU Next is required."

ui_print "Enable Tether CyberspaceVII"
ui_print " "
ui_print "Configuring hotspot APNs..."

. "$MODPATH/apn.sh"
if apply_apns; then
  ui_print "APN settings saved. Reboot to apply the provisioning setting."
else
  restore_apns || ui_print "APN restore failed. Backup retained in $STATE."
  abort "Could not configure hotspot APNs."
fi
