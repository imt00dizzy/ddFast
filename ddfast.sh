#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="/usr/local/lib/ddFast"

show_help() {
  cat <<EOF
ddFast - fast & simple ISO flasher

usage:
  sudo ddfast ~/path/to/image.iso /dev/sdX

example:
  sudo ddfast ~/Downloads/os.iso /dev/sda

options:
  -h, --help     show this help message and exit

notes:
  - target must be a block device (like /dev/sda)
  - all data on the target drive will be erased
  - requires root (sudo)
EOF
}


if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  show_help
  exit 0
fi


if [[ $EUID -ne 0 ]]; then
  echo "please run as root (sudo ddfast ...)"
  exit 1
fi

SRC="${1:-}"
DST="${2:-}"


if [[ -z "$SRC" || -z "$DST" ]]; then
  show_help
  exit 1
fi


[[ "$DST" != /dev/* ]] && DST="/dev/$DST"


if [[ ! -f "$SRC" ]]; then
  echo "error: source file not found: $SRC"
  exit 1
fi

if [[ ! -b "$DST" ]]; then
  echo "error: invalid target block device: $DST"
  exit 1
fi


SYS_DRIVES=("sda" "nvme0n1" "mmcblk0")
BASE_DST=$(basename "$DST")

if [[ " ${SYS_DRIVES[*]} " == *" $BASE_DST "* ]]; then
  echo "⚠️  warning: $DST looks like a system drive."
  read -r -p "are you 100% sure you want to flash to $DST? (type YES to continue): " CONFIRM
  [[ "$CONFIRM" == "YES" ]] || { echo "aborted."; exit 1; }
else
  read -r -p "this will erase all data on $DST — continue? (y/N): " CONFIRM
  [[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "aborted."; exit 1; }
fi


SRC_SIZE=$(stat -c%s "$SRC")
DST_SIZE=$(blockdev --getsize64 "$DST" 2>/dev/null || echo 0)

SRC_H=$(numfmt --to=iec-i --suffix=B "$SRC_SIZE" 2>/dev/null || echo "$SRC_SIZE bytes")
DST_H=$(numfmt --to=iec-i --suffix=B "$DST_SIZE" 2>/dev/null || echo "$DST_SIZE bytes")

echo
echo "────────────────────────────────────────────"
echo " source: $SRC ($SRC_H)"
echo " target: $DST ($DST_H)"
echo "────────────────────────────────────────────"
echo


echo "unmounting target partitions..."
lsblk -ln -o NAME,MOUNTPOINT "$DST" | awk '$2!=""{print $1}' | while read -r part; do
  umount "/dev/$part" 2>/dev/null || true
done

sync


echo "flashing image... this might take a while."
if command -v pv >/dev/null 2>&1; then
  pv -tpreb "$SRC" | dd of="$DST" bs=8M iflag=fullblock conv=fsync oflag=direct status=none
else
  dd if="$SRC" of="$DST" bs=8M iflag=fullblock conv=fsync oflag=direct status=progress
fi

sync
echo
echo " done! wrote $SRC → $DST"
echo "────────────────────────────────────────────"
echo " thank you for using ddFast"
echo " made by lucysgutz"
echo " https://lucys.space/"
echo "────────────────────────────────────────────"
