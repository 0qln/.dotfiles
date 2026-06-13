{
  self,
  mkNixosSystem,
  ...
}: {
  imports = [
    ./configuration.nix
  ];

  flake.nixosConfigurations.lif = mkNixosSystem "lif" "x86_64-linux" [
    self.nixosModules.lif
  ];
}
