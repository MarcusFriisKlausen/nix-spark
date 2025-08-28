#!/usr/bin/env bash

project_dir=$(dirname "$(dirname "$(realpath "$0")")")
vms_dir="$project_dir/vms"

for dir in "$vms_dir"/*; do
  name=$(basename "$dir")
  iso=$(find "$dir/iso/iso" -maxdepth 1 -type f -name "*.iso" -print -quit)
  qcow=$(find "$dir" -maxdepth 1 -type f -name "*.qcow2" -print -quit)

  sudo virt-install \
    --name=$name \
    --memory=1024 \
    --vcpus=2 \
    --disk $qcow,device=disk,bus=virtio,size=8 \
    --cdrom=$iso \
    --os-variant=generic \
    --boot=uefi \
    --nographics \
    --console pty,target_type=virtio \
    --network network=sparknet
done

echo "All VMs added as libvirt domains. Use 'sudo virsh list --all' to see domains."
