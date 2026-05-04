{...}: {
  flake.homeModules.steam_bongocat = {...}: {
    imports = [
      ./hyprland.nix
    ];
  };
}
