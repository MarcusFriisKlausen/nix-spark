{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  networking.hostName = "spark-master";

  networking.useDHCP = false;
  networking.interfaces.eth0 = {
    ipv4.addresses = [
      {
        address = "192.168.123.101";
        prefixLength = 24;
      }
    ];
  };
  
  services.openssh.enable = true;

  users.users.node = {
    isNormalUser = true;
    extraGroups = [ "wheel" "dialout" ];
    password = "spark";
    openssh.authorizedKeys.keyFiles = [
      ../../keys/ssh-key.pub
    ];
  };

  environment.systemPackages = with pkgs; [
    spark
    python3
    python3Packages.numpy
    python3Packages.pandas
    python3Packages.pyspark
  ];

  networking.firewall.allowedTCPPorts = [
    22
    7077
  ];

  services.getty.autologinUser = lib.mkForce "node";
  
  systemd.services.spark-master = {
    description = "Systemd service for starting spark as master";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.spark}/sbin/start-master.sh";
      ExecStop = "${pkgs.spark}/sbin/stop-master.sh";
      Restart = "always";
      User = "root";
    };
  };
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "24.11";
}
