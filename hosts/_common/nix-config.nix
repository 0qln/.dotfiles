{...}: {
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      extra-experimental-features = [
        "pipe-operators"
      ];
    };
  };
}
