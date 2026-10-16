#!/bin/bash
# Copy the recovery runtime the platform needs out of the stock Z2458 dump.
#
# usage: scripts/port-stock-runtime.sh <dump_root>
#
# <dump_root> is the unpacked stock, holding system/ and vendor/. Every file
# copied here is a stock blob; nothing is authored. The destination layout
# mirrors the Z2577 tree, which is the same board family and boots with it.
#
# Writes scripts/port-manifest.tsv: sha256, size, destination, source.
set -eu

DUMP=${1:?usage: port-stock-runtime.sh <dump_root>}
TREE=$(cd "$(dirname "$0")/.." && pwd)
V=$DUMP/vendor/vendor/vendor_a
S=$DUMP/system/system_a/system
OUT=$TREE/recovery/root
MAN=$TREE/scripts/port-manifest.tsv

[ -d "$V" ] || { echo "no vendor image at $V" >&2; exit 1; }
[ -d "$S" ] || { echo "no system image at $S" >&2; exit 1; }

: > "$MAN"
n=0

# copy_one <absolute source> <destination relative to recovery/root>
copy_one() {
    src=$1
    dst=$2
    [ -f "$src" ] || { echo "MISSING in dump: $src" >&2; return 1; }
    mkdir -p "$OUT/$(dirname "$dst")"
    cp -f "$src" "$OUT/$dst"
    chmod 0755 "$OUT/$dst"
    printf '%s\t%s\t%s\t%s\n' "$(sha256sum "$src" | cut -d' ' -f1)" \
        "$(stat -c%s "$src")" "$dst" "$src" >> "$MAN"
    n=$((n + 1))
}

# TEE and boot HAL services. Flattened into /system/bin the way the Z2577 tree
# ships them, so the service paths in init.recovery.ums9230_6h10.rc match.
copy_one "$V/bin/tsupplicant"                                                   system/bin/tsupplicant
copy_one "$V/bin/sprdstorageproxyd"                                             system/bin/sprdstorageproxyd
copy_one "$V/bin/hw/android.hardware.security.keymint@2.0-unisoc.service.trusty" system/bin/android.hardware.security.keymint@2.0-unisoc.service.trusty
copy_one "$V/bin/hw/android.hardware.gatekeeper@1.0-service.trusty"            system/bin/android.hardware.gatekeeper@1.0-service.trusty
copy_one "$V/bin/hw/vendor.sprd.hardware.boot@1.2-service"                     system/bin/vendor.sprd.hardware.boot@1.2-service

# Libraries the recovery ramdisk does not build from source. The relink step in
# Z2577 carries most of keymint; the trusty and sprd pieces exist only as vendor
# blobs, so they come from here.
SYSLIBS="android.hardware.gatekeeper@1.0.so
android.hardware.security.keymint-V1-ndk.so
lib_android_keymaster_keymint_utils.so
libcppbor_external.so
libcppcose_rkp.so
libeic_trusty.so
libkernelbootcp.trusty.so
libkeymaster_messages.so
libkeymaster_portable.so
libkeymint.so
libpuresoftkeymasterdevice.so
libsoft_attestation_cert.so
libtrusty.so
libtrustyHalHelper.so
vendor.sprd.hardware.boot@1.2.so
vendor.sprd.hardware.trusty-V1-ndk.so
vendor.sprd.hardware.trusty@1.0.so"

while read -r so; do
    [ -n "$so" ] || continue
    copy_one "$V/lib64/$so" "system/lib64/$so"
done <<< "$SYSLIBS"

copy_one "$V/lib64/hw/android.hardware.boot@1.0-impl-1.2.so" system/lib64/hw/android.hardware.boot@1.0-impl-1.2.so
copy_one "$V/lib64/hw/android.hardware.boot@1.0-impl-1.2.so" system/lib64/android.hardware.boot@1.0-impl-1.2.so

# Dependencies the vendor TEE blobs pull in that the AOSP build does not place in
# the recovery ramdisk. keymint AIDL V2 is not in this dump at all; it is asked
# for through the relink list in BoardConfig.mk instead.
copy_one "$S/lib64/libhidlmemory.so"              system/lib64/libhidlmemory.so
copy_one "$S/lib64/android.hardware.common-V2-ndk.so" system/lib64/android.hardware.common-V2-ndk.so

# Same set under /vendor/lib64: TWRP replaces /vendor with the real partition
# during its fstab pass, and the services resolve through either path.
VENDORLIBS="android.hardware.gatekeeper@1.0.so
lib_android_keymaster_keymint_utils.so
libcppbor_external.so
libcppcose_rkp.so
libkeymaster_messages.so
libkeymaster_portable.so
libkeymint.so
libpuresoftkeymasterdevice.so
libsoft_attestation_cert.so
libtrusty.so"

while read -r so; do
    [ -n "$so" ] || continue
    copy_one "$V/lib64/$so" "vendor/lib64/$so"
done <<< "$VENDORLIBS"

# Trusted applications read by the TEE supplier and the keymint service
for elf in identity.elf hdcp.elf silead.elf; do
    copy_one "$V/firmware/$elf" "vendor/firmware/$elf"
done

# VINTF declarations for the three services above. Without these the framework
# never finds them; on this platform a declared service nothing serves blocks.
copy_one "$V/etc/vintf/manifest.xml"            vendor/etc/vintf/manifest.xml
copy_one "$V/etc/vintf/compatibility_matrix.xml" vendor/etc/vintf/compatibility_matrix.xml
for frag in android.hardware.security.keymint@2.0-unisoc.service.trusty.xml \
            android.hardware.gatekeeper@1.0-service.trusty.xml \
            vendor.sprd.hardware.boot@1.2.xml; do
    copy_one "$V/etc/vintf/manifest/$frag" "vendor/etc/vintf/manifest/$frag"
done

# Same declarations on the system side, plus the framework matrices the stock
# system image carries
copy_one "$S/etc/task_profiles.json"          system/etc/task_profiles.json
copy_one "$S/etc/vintf/manifest.xml"          system/etc/vintf/manifest.xml
for xml in "$S"/etc/vintf/compatibility_matrix.*.xml; do
    copy_one "$xml" "system/etc/vintf/$(basename "$xml")"
done
if [ -d "$S/etc/vintf/manifest" ]; then
    for xml in "$S"/etc/vintf/manifest/*.xml; do
        [ -e "$xml" ] || continue
        copy_one "$xml" "system/etc/vintf/manifest/$(basename "$xml")"
    done
fi

# Dependency closure. A stock blob that needs a soname the TWRP ramdisk does
# not already ship has to be ported with it, or the service cannot even load.
# scripts/aosp-libs.txt lists the sonames the ramdisk provides, so those are
# left alone; everything else that resolves in the dump is pulled in.
SKIP=$TREE/scripts/aosp-libs.txt
if [ -f "$SKIP" ]; then
    snap=$(mktemp)
    for _ in 1 2 3 4 5 6; do
        added=0
        cp -f "$MAN" "$snap"
        while IFS=$'\t' read -r _ _ dst _; do
            f=$OUT/$dst
            [ "$(head -c4 "$f" 2>/dev/null)" = "$(printf '\177ELF')" ] || continue
            for need in $(readelf -d "$f" 2>/dev/null | awk '/NEEDED/{gsub(/[][]/,"");print $NF}'); do
                [ -f "$OUT/system/lib64/$need" ] && continue
                grep -qx "$need" "$SKIP" && continue
                found=$(find "$V/lib64" "$S/lib64" -maxdepth 1 -name "$need" 2>/dev/null | head -1)
                [ -n "$found" ] || continue
                copy_one "$found" "system/lib64/$need"
                added=$((added + 1))
            done
        done < "$snap"
        [ "$added" -eq 0 ] && break
    done
    rm -f "$snap"
fi

unresolved=$(mktemp)
while IFS=$'\t' read -r _ _ dst _; do
    f=$OUT/$dst
    [ "$(head -c4 "$f" 2>/dev/null)" = "$(printf '\177ELF')" ] || continue
    for need in $(readelf -d "$f" 2>/dev/null | awk '/NEEDED/{gsub(/[][]/,"");print $NF}'); do
        [ -f "$OUT/system/lib64/$need" ] && continue
        grep -qx "$need" "$SKIP" 2>/dev/null && continue
        echo "  $need  (needed by $dst)" >> "$unresolved"
    done
done < "$MAN"

if [ -s "$unresolved" ]; then
    echo "unresolved dependencies (must come from the build, not the dump):"
    sort -u "$unresolved" | sed 's/^/  /'
fi
rm -f "$unresolved"

echo "copied $n files"
echo "manifest: $MAN"
