{ config, lib, userName ? "marcus", ... }:
{
  users.users.userName = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "networkmanager" ];
  };
}
