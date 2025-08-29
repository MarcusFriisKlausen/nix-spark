{ config, lib, pkgs, inputs, ... }:

let
  libvirt_nat_bridge = "virbr1";
  nixvirt = inputs.nixvirt;
in
{
  programs.virt-manager.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };

  virtualisation.libvirt = {
    enable = true;
    connections."qemu:///system".networks = [
      {
        definition = nixvirt.lib.network.writeXML {
          name = "sparknet";
          uuid = "6d405544-f162-4965-acdd-f3c4909db6e8";
          forward = {
            mode = "nat";
            nat = {
              port = { start = 49152; end = 65535; };
            };
          };
          bridge = {
            name = libvirt_nat_bridge;
            stp = true;
            delay = 0;
          };
          ip = {
            address = "192.168.123.1";
            netmask = "255.255.255.0";
            dhcp = {
              range = { start = "192.168.123.100"; end = "192.168.123.200"; };
            };
          };
        };
        active = true;
      }
    ];
  };
}
