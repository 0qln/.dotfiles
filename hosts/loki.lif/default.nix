{...}: {
  imports = [
    ../loki
    ./configuration.nix

    ../../modules/networking
  ];

  home-manager = {
    users.oq = _: {
      imports = [./home-vars.nix];
    };
  };
}
