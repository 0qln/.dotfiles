{inputs, ...}: {
  imports = [
    inputs.private.nixosModules."lif"

    ./mount.nix
  ];
}
