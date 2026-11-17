STATE=/data/adb/cyberspacevii/enable-tether-a67lg2
BAK="$STATE/apn.bak"
URI=content://telephony/carriers

# Parses `content query` rows. mode=apply: print id|numeric|apn|field|old|new for each edit.
# mode=restore (backup file first, then rows): print id|field|old for edits whose row still matches.
APN_AWK='
function parse(   line, n, kv, i, p) {
  line = $0; sub(/^Row: [0-9]+ /, "", line)
  for (p in f) delete f[p]
  n = split(line, kv, ", ")
  for (i = 1; i <= n; i++) { p = index(kv[i], "="); f[substr(kv[i], 1, p - 1)] = substr(kv[i], p + 1) }
}
mode == "restore" && FNR == NR { split($0, b, "|"); bak[b[1] "|" b[2] "|" b[3]] = bak[b[1] "|" b[2] "|" b[3]] "\n" b[4] "|" b[5]; next }
!/^Row: / { next }
{ parse() }
mode == "restore" {
  k = f["_id"] "|" f["numeric"] "|" f["apn"]
  if (k in bak) { n = split(substr(bak[k], 2), e, "\n"); for (i = 1; i <= n; i++) print f["_id"] "|" e[i] }
  next
}
{
  m = split(f["type"], a, ","); has = 0; def = 0; out = ""
  for (i = 1; i <= m; i++) {
    if (a[i] == "dun") has = 1
    else { if (a[i] == "default" || a[i] == "*") def = 1; out = out (out == "" ? "" : ",") a[i] }
  }
  if (!has || def) next   # Keep regular data APNs unchanged.
  pre = f["_id"] "|" f["numeric"] "|" f["apn"] "|"
  if (out == "") { if (f["carrier_enabled"] != "0") print pre "carrier_enabled|" f["carrier_enabled"] "|0" }
  else print pre "type|" f["type"] "|" out
}'

write_apns() {
  # Input: id|field|value. Batch carrier_enabled updates by value.
  awk -F'|' '$2 == "carrier_enabled" { ids[$3] = ids[$3] (ids[$3] == "" ? "" : ",") $1; next }
             { print "T|" $1 "|" $3 } END { for (v in ids) print "C|" v "|" ids[v] }' |
  while IFS='|' read -r kind a b; do
    if [ "$kind" = C ]; then content update --uri "$URI" --bind "carrier_enabled:i:$a" --where "_id IN ($b)"
    else content update --uri "$URI/$a" --bind "type:s:$b"; fi >/dev/null || exit 1
  done
}

apply_apns() {
  mkdir -p "$STATE" || return 1
  chmod 0700 "$STATE" || return 1
  umask 077
  rows=$(content query --uri "$URI" --projection _id:numeric:apn:type:carrier_enabled) || return 1
  echo "$rows" | grep -q '^Row: ' || return 1
  edits=$(echo "$rows" | awk -v mode=apply "$APN_AWK")
  [ -n "$edits" ] || return 0
  echo "$edits" | while IFS='|' read -r id num apn field old new; do
    grep -qxF "$id|$num|$apn|$field|$old" "$BAK" 2>/dev/null || echo "$id|$num|$apn|$field|$old" >> "$BAK" || exit 1
  done || return 1
  echo "$edits" | awk -F'|' '{ print $1 "|" $4 "|" $6 }' | write_apns
}

restore_apns() {
  [ -s "$BAK" ] || return 0
  rows=$(content query --uri "$URI" --projection _id:numeric:apn:type:carrier_enabled) || return 1
  echo "$rows" | grep -q '^Row: ' || return 1
  echo "$rows" | awk -v mode=restore "$APN_AWK" "$BAK" - | write_apns
}
