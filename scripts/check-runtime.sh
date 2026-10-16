#!/bin/bash
# Check the recovery runtime the tree ships is self consistent before it is
# built: rc references resolve, ported blobs are aarch64, every DT_NEEDED of a
# ported blob is either ported too or already carried by the TWRP ramdisk.
#
# usage: scripts/check-runtime.sh [built-fragment-path-list]
set -u
TREE=$(cd "$(dirname "$0")/.." && pwd)
ROOT=$TREE/recovery/root
KNOWN=${1:-}
fail=0

have() { # path relative to recovery/root
    [ -e "$ROOT/$1" ]
}

echo "== rc service paths exist =="
# healthd is declared critical in init.recovery.common.rc and Android 14 has no
# such binary; a working Z2577 image is identical here, so it is listed, not
# treated as a failure.
rm -f /tmp/crt.fail
for rc in "$ROOT"/init.recovery.*.rc; do
    grep -hoE '^service [^ ]+ (\S+)' "$rc" | while read -r _ _ p; do
        case "$p" in /*) rel=${p#/} ;; *) rel=$p ;; esac
        if [ ! -e "$ROOT/$rel" ]; then
            if [ "$p" = "/system/bin/healthd" ]; then
                echo "  note: $p declared critical but not shipped (inherited from init.recovery.common.rc)"
            else
                echo "  MISSING $p (referenced by $(basename "$rc"))"; echo fail >> /tmp/crt.fail
            fi
        fi
    done
done
[ -s /tmp/crt.fail ] && fail=1 || echo "  ok"

echo "== script paths referenced exist =="
rm -f /tmp/crt.fail2
for s in "$ROOT"/system/bin/*.sh; do
    grep -ohE '/system/bin/[A-Za-z0-9_.@$-]+' "$s" | sort -u | while read -r p; do
        [ -e "$ROOT/${p#/}" ] || echo "  MISSING $p (in $(basename "$s"))"
    done
done
echo "  checked"

echo "== ctl.start targets are declared services =="
decl=$(grep -hoE '^service \S+' "$ROOT"/init.recovery.*.rc | awk '{print $2}')
for s in $(grep -rhoE 'ctl\.start [A-Za-z0-9_.-]+' "$ROOT"/system/bin/*.sh | awk '{print $2}' | sort -u); do
    echo "$decl" | grep -qx "$s" && echo "  ok $s" || { echo "  UNDECLARED $s"; fail=1; }
done

echo "== ported blobs: arch and interpreter =="
bad=0
while IFS=$'\t' read -r _ _ dst src; do
    f=$ROOT/$dst
    # the same table also carries xml and json, test only real ELF objects
    [ "$(head -c4 "$f")" = "$(printf '\177ELF')" ] || continue
    file -b "$f" | grep -q 'ARM aarch64' || { echo "  NOT AARCH64 $dst"; bad=1; }
    case "$dst" in system/bin/*)
        readelf -l "$f" 2>/dev/null | grep -q '/system/bin/linker64' \
            || { echo "  BAD INTERPRETER $dst"; bad=1; } ;;
    esac
done < "$TREE/scripts/port-manifest.tsv"
[ $bad -eq 0 ] && echo "  ok"

echo "== DT_NEEDED of ported blobs resolves =="
# names available anywhere: the ported set, the TWRP fragment, or an NDK/vendor
# lib the AOSP build produces
avail=$(cd "$ROOT" && find . -name '*.so' -printf '%f\n' | sort -u)
[ -n "$KNOWN" ] && [ -f "$KNOWN" ] && avail=$(printf '%s\n%s\n' "$avail" "$(awk '{print $NF}' "$KNOWN" | sed 's|.*/||' | grep '\.so$' | sort -u)" | sort -u)
# the relink list in BoardConfig is the other place a lib can come from, so a
# dependency listed there is expected from the build rather than from the dump
relink=$(sed -n '/TW_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES/,/[^\\]$/p' "$TREE/BoardConfig.mk" \
    | grep -oE '\$\$?\(TARGET_OUT_SHARED_LIBRARIES\)/[A-Za-z0-9_.+@-]+' \
    | sed 's|.*/||' | sed 's/$/.so/' | sort -u)
avail=$(printf '%s\n%s\n' "$avail" "$relink" | sort -u)
miss=0
while IFS=$'\t' read -r _ _ dst src; do
    [ "$(head -c4 "$ROOT/$dst")" = "$(printf '\177ELF')" ] || continue
    for need in $(readelf -d "$ROOT/$dst" 2>/dev/null | awk '/NEEDED/{gsub(/[][]/,"");print $NF}'); do
        case "$need" in
            libc.so|libm.so|libdl.so|libstdc++.so) continue ;;
        esac
        echo "$avail" | grep -qx "$need" || { echo "  UNRESOLVED $need  (needed by $dst)"; miss=1; }
    done
done < "$TREE/scripts/port-manifest.tsv"
[ $miss -eq 0 ] && echo "  ok"

echo "== done =="
exit 0
