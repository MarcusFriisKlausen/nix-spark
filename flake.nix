{
  description = "Apache Spark Cluster";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixvirt.url = "http://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
    nixvirt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixvirt, ... }@inputs:
  {
    nixosConfigurations.cluster = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        nixvirt.nixosModules.default
        ./hosts/configuration-cluster.nix
        ./modules/virtual-network.nix
        ./modules/user.nix
      ];
    };
  };
}
