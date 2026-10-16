#!/sbin/sh
# Wait for the trusty IPC node, then let the TEE services start in order.

LOG=/tmp/prepdecrypt.log
exec > "$LOG" 2>&1

i=0
while [ $i -lt 30 ]; do
    [ -e /dev/trusty-ipc-dev0 ] && break
    sleep 1
    i=$((i + 1))
done

if [ -e /dev/trusty-ipc-dev0 ]; then
    echo "trusty node after ${i}s"
else
    # signal anyway so decrypt fails fast instead of blocking here
    echo "no trusty node after ${i}s, signaling anyway"
fi

setprop crypto.ready 1
