{
  self,
  mkNixosSystem,
  ...
}: {
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
  ];

  flake.nixosConfigurations.lif = mkNixosSystem "lif" "x86_64-linux" [
    self.nixosModules.lif
    self.nixosModules.lif-hardware
  ];
}
