{...}: {
  home-manager = {
    users.oq = _: {
      imports = [
        ./home-vars.nix
      ];
    };
  };
}
