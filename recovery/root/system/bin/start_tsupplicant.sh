#!/sbin/sh
# Mount /odm and start the TEE TA supplier.
#
# TWRP mounts /odm during its fstab pass and unmounts it again, so the TA load
# has to wait for /data and for the storage proxies, then mount it itself.

LOG=/tmp/start_tsupplicant.log
exec > "$LOG" 2>&1

TA=/odm/firmware/gatekeeper.elf

i=0
while [ $i -lt 120 ]; do
    grep -q ' /data ' /proc/mounts && break
    sleep 1
    i=$((i + 1))
done

i=0
while [ $i -lt 60 ] && [ "$(getprop twrp.storage.ready)" != "1" ]; do
    sleep 1
    i=$((i + 1))
done

i=0
while [ $i -lt 30 ]; do
    mount -t erofs -o ro /dev/block/by-name/odm /odm 2>/dev/null
    sleep 2
    grep -q ' /odm ' /proc/mounts && [ -r "$TA" ] && break
    i=$((i + 1))
done

if [ ! -r "$TA" ]; then
    echo "$TA not readable after ${i} tries, aborting"
    exit 1
fi

setprop vendor.sprd.tsupplicant.enabled 1
sleep 2
setprop twrp.tsupplicant.ready 1
