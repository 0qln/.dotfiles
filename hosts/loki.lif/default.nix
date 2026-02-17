{...}: {
  imports = [
    ../loki
    ./configuration.nix
  ];

  home-manager = {
    users.oq = _: {
      imports = [./home-vars.nix];
    };
  };
}
