#!/usr/bin/env bash                                                                                                                                                                                               

set -euo pipefail

clear

ascii="
                                        
  ▄▄▄▄▄▄     ▄▄▄▄▄▄    ▄▄               
 █▀██▀▀██   █▀██▀▀██  ██             █▄ 
   ██   ██    ██   ██▄██▄           ▄██▄
   ██   ██    ██   ██ ██ ▄▀▀█▄ ▄██▀█ ██ 
 ▄ ██   ██  ▄ ██   ██ ██ ▄█▀██ ▀███▄ ██ 
 ▀██▀███▀   ▀██▀███▀ ▄██▄▀█▄███▄▄██▀▄██ 
                      ██                
                     ▀▀            "

rainbow_ascii() {
  i=0
  while IFS= read -r line; do
    color=$(( (i % 6) + 31 )) 
    echo -e "\e[${color}m${line}\e[0m"
    i=$((i+1))
  done <<< "$ascii"
}

rainbow_ascii

echo
lsblk -o name,type,model,size,label,mountpoint
echo
echo -n "choose target block (example: sdb): "
read -r BLK
target="/dev/$BLK"

if [[ ! -b "$target" ]]; then
  echo "invalid block device"
  exit 1
fi

echo -n "path to iso: "
read -r iso

if [[ ! -f "$iso" ]]; then
  echo "iso not found"
  exit 1
fi

lsblk "$target"
echo -n "this will ERASE $target — continue? (y/N): "
read -r y
[[ "$y" =~ ^[Yy]$ ]] || exit 1

lsblk -ln -o NAME,MOUNTPOINT "$target" | awk '$2!=""{print $1}' | while read -r p; do
  umount "/dev/$p" 2>/dev/null || true
done

sync

echo "starting dd write with full verbose logging..."

dd if="$iso" of="$target" bs=8M iflag=fullblock conv=fsync oflag=direct status=progress

sync

echo "done, flashed $iso to $target"
