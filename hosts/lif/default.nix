{
  self,
  inputs,
  mkHostArgs,
  ...
}: {
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
  ];

  flake.nixosConfigurations.lif = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = mkHostArgs "lif" "x86_64-linux";
    modules = [
      self.nixosModules.lif
      self.nixosModules.lif-hardware
    ];
  };
}
