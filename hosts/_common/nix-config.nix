{...}: {
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.extra-experimental-features = [
    "pipe-operators"
  ];
}
