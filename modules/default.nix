{defaultUser}: {...}: {
  imports = [
    nixos-wsl.nixosModules.default
  ];

  wsl = {
    enable = true;
    inherit defaultUser;
  };
}
