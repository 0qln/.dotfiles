{inputs, ...}: {
  imports = [
    ./tor.nix
    ./zen.nix
    ./firefox.nix

    # most extensions are in nur
    inputs.nur.modules.homeManager.default
  ];
}
