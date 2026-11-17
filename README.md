# Enable Tether

**[Download enable-tether-a67lg2.zip](https://github.com/CyberspaceVii/enable-tether-a67lg2/releases/download/v0.1/enable-tether-a67lg2.zip)**

Share the phone's regular mobile data connection over its hotspot.

A KernelSU Next module for the **Foxxd A67L Gen 2**. It skips Android's carrier
provisioning check and adjusts APNs reserved for tethering, allowing the hotspot
to use the regular data APN. Carrier network restrictions can still apply.

## Requirements

- Foxxd A67L Gen 2
- Rooted with KernelSU Next

The installer checks both before changing APN settings.

## Install

1. Download [`enable-tether-a67lg2.zip`](https://github.com/CyberspaceVii/enable-tether-a67lg2/releases/latest/download/enable-tether-a67lg2.zip) (latest release).
2. KernelSU Next → Modules → Install from storage → select the zip.
3. Reboot, then turn on the hotspot in Settings.

## What changes

- Sets `net.tethering.noprovisioning=true` before Android starts.
- Disables APNs whose only type is `dun` (tethering).
- Removes `dun` from APNs that also serve other purposes, leaving those other
  types enabled. Regular data APNs with `default` or `*` are left alone.

Original values are saved before each edit in
`/data/adb/cyberspacevii/enable-tether-a67lg2/apn.bak`. The module checks the APN
table again after boot, so it can reapply changes after an APN reset or SIM swap.

## Uninstall

Remove the module in KernelSU Next and reboot. It restores saved APN values
when the row ID, carrier code and APN name still match. If restoration fails,
the backup is kept at the path above.

Disabling the module stops it from setting the provisioning property after the
next reboot, but leaves its APN edits in place. Remove it to restore those edits.

## License

[WTFPL](LICENSE).

---

CyberspaceVII · https://www.cyberspace7.org
