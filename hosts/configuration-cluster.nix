{ config, pkgs, ... }:

{
  imports = [
    ../hardware/hardware-configuration.nix
  ];
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "spark-cluster";
  networking.networkmanager.enable = false;
  
  environment.systemPackages = with pkgs;  [
    spark
    python3
    python3Packages.pandas
    python3Packages.numpy
    python3Packages.pyspark
  ];
  system.stateVersion = "24.11";
}
