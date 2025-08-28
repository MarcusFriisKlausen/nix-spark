{ config, pkgs, lib, modulesPath, ... }:
let
  MASTER_HOSTNAME = "spark-master";
in
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  networking.hostName = "spark-worker1";
  
  networking.useDHCP = false;
  networking.interfaces.eth0 = {
    ipv4.addresses = [
      {
        address = "192.168.123.102";
        prefixLength = 24;
      }
    ];
  };

  users.users.node = {
    isNormalUser = true;
    extraGroups = [ "wheel" "dialout" ];
    password = "";
  };
  
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    spark
    python3
    python3Packages.numpy
    python3Packages.pandas
    python3Packages.pyspark
  ];
  
  networking.firewall.allowedTCPPorts = [
    22
  ];
  
  systemd.services.spark-worker = {
    description = "Systemd service for starting spark as worker";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.spark}/sbin/start-worker.sh spark://${MASTER_HOSTNAME}:7077";
      ExecStop = "${pkgs.spark}/sbin/stop-worker.sh";
      Restart = "always";
      RestartSec = 2;
      User = "root";
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "24.11";
}
