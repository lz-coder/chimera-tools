#!/bin/sh

log() {
  echo [$(date)] $1
}

start() {
  log "calculating zram size...."
  mem_total=$(grep MemTotal /proc/meminfo | grep -E --only-matching '[[:digit:]]+')

  log "loading zram module"
  modprobe zram

  log "creating device /dev/zram0 using zstd with $((mem_total))KiB"
  zramctl /dev/zram0 --algorithm zstd --size "$((mem_total))KiB"

  log "creating swap on /dev/zram0"
  mkswap -U clear /dev/zram0

  log "activating swap"
  swapon --discard --priority 100 /dev/zram0

  log "Swap on ZRAM activated :)"
}

stop() {
  log "deactivating swap on /dev/zram0"
  swapoff /dev/zram0

  log "disabling module..."
  modprobe -r zram
  log "module disabled"

  echo 1 > /sys/module/zswap/parameters/enabled
  log "Swap on ZRAM disabled :|"
  
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
