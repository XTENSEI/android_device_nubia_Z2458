#!/sbin/sh
# Mount prodnv, wait for /data, then start the TEE secure storage proxies in the
# order storageproxyd_android.rc implies. Started before /data exists they open
# shadow files and the TEE verify fails.

LOG=/tmp/start_storage_proxies.log
exec > "$LOG" 2>&1

i=0
while [ $i -lt 30 ] && ! grep -q ' /mnt/vendor ' /proc/mounts; do
    mkdir -p /mnt/vendor
    mount -t ext4 /dev/block/by-name/prodnv /mnt/vendor 2>/dev/null
    sleep 1
    i=$((i + 1))
done
grep -q ' /mnt/vendor ' /proc/mounts || echo "prodnv not mounted after ${i}s"

i=0
while [ $i -lt 120 ]; do
    grep -q ' /data ' /proc/mounts && break
    sleep 1
    i=$((i + 1))
done

if ! grep -q ' /data ' /proc/mounts; then
    echo "/data not mounted after ${i}s, aborting"
    exit 1
fi

mkdir -p /data/vendor/sprd_ss /data/vendor/sprd_tee_ss /mnt/vendor/productinfo/sprd_ss
chown system:system /data/vendor/sprd_ss /data/vendor/sprd_tee_ss /mnt/vendor/productinfo/sprd_ss
chmod 0770 /data/vendor/sprd_ss /data/vendor/sprd_tee_ss /mnt/vendor/productinfo/sprd_ss

setprop ctl.start vendor.rpmbproxy
sleep 2
setprop ctl.start vendor.nsproxy
sleep 2
setprop ctl.start vendor.prodproxy

echo "storage proxies started"
setprop twrp.storage.ready 1
