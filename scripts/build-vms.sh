#!/usr/bin/env bash

project_dir=$(dirname "$(dirname "$(realpath "$0")")")
hosts_dir="$project_dir/hosts"
vms_dir="$project_dir/vms"
filename="nixos.qcow2"

for dir in "$vms_dir"/*; do
  config=$(find "$dir" -maxdepth 1 -type f -name "*.nix" -print -quit)

  qemu-img create -f qcow2 "$dir/$filename" 8G 

  nix-build "<nixpkgs/nixos>" \
    -A config.system.build.isoImage \
    -I nixos-config="$config" \
    --out-link "$dir/iso"
done

echo "All VM live CDs and disk files created!"
