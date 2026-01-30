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

echo


echo "🔍 searching for .iso files..."
echo


search_paths=(
  "$HOME/Downloads"
  "$HOME"
  "/tmp"
  "."
)


declare -a isos=()


for path in "${search_paths[@]}"; do
  if [[ -d "$path" ]]; then
    while IFS= read -r iso_file; do
      isos+=("$iso_file")
    done < <(find "$path" -maxdepth 2 -type f -iname "*.iso" 2>/dev/null)
  fi
done


if [[ ${#isos[@]} -gt 0 ]]; then
  readarray -t isos < <(printf '%s\n' "${isos[@]}" | sort -u)
fi


if [[ ${#isos[@]} -eq 0 ]]; then
  echo "❌ no .iso files found in common locations"
  echo
  echo -n "enter path to iso manually: "
  read -r iso
else
  echo "📀 found ${#isos[@]} iso file(s):"
  echo
  
  for i in "${!isos[@]}"; do
    iso_path="${isos[$i]}"
    iso_name=$(basename "$iso_path")
    iso_size=$(du -h "$iso_path" | cut -f1)
    printf "  \e[36m[%d]\e[0m %s \e[33m(%s)\e[0m\n" "$((i+1))" "$iso_name" "$iso_size"
    printf "      \e[90m%s\e[0m\n" "$iso_path"
  done
  
  echo
  echo -n "choose iso number [1-${#isos[@]}] or enter custom path: "
  read -r choice
  

  if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#isos[@]} ]]; then
    iso="${isos[$((choice-1))]}"
    echo "✅ selected: $(basename "$iso")"
  else

    iso="$choice"
  fi
fi


if [[ ! -f "$iso" ]]; then
  echo "❌ iso not found: $iso"
  exit 1
fi

echo


lsblk "$target"
echo


iso_name=$(basename "$iso")
iso_size=$(du -h "$iso" | cut -f1)

echo -e "\e[33m⚠️  WARNING: this will ERASE $target\e[0m"
echo
echo "  Device:  $target"
echo "  ISO:     $iso_name ($iso_size)"
echo
echo -n "continue? (y/N): "
read -r y
[[ "$y" =~ ^[Yy]$ ]] || exit 1

echo


echo "🔓 unmounting any mounted partitions..."
lsblk -ln -o NAME,MOUNTPOINT "$target" | awk '$2!=""{print $1}' | while read -r p; do
  echo "  unmounting /dev/$p"
  umount "/dev/$p" 2>/dev/null || true
done

sync
echo


echo "⚡ starting dd write with full verbose logging..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
dd if="$iso" of="$target" bs=8M iflag=fullblock conv=fsync oflag=direct status=progress
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sync
echo


echo -e "\e[32m✅ done! successfully flashed:\e[0m"
echo "  $iso_name → $target"
echo