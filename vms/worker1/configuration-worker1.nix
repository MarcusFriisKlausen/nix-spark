{ config, pkgs, lib, modulesPath, ... }:
let
  MASTER_IP = "192.168.123.101";
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
  
  services.getty.autologinUser = lib.mkForce "node";
  
  networking.firewall.allowedTCPPorts = [
    22
    7078
    8081
  ];
  
  systemd.services.spark-worker = {
    description = "Spark Worker";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      Environment = [
        "SPARK_LOG_DIR=/var/log/spark"
        "SPARK_WORKER_DIR=/var/lib/spark/work"
        "SPARK_WORKER_PORT=7078"
        "PATH=/run/current-system/sw/bin:${pkgs.spark}/bin:${pkgs.spark}/sbin"
      ];  
      ExecStart = "${pkgs.spark}/sbin/start-worker.sh spark://${MASTER_IP}:7077";
      Restart = "on-failure";
      RestartSec = 10;
      User = "root";
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "24.11";
}
