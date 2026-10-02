{
  inputs,
  flake,
  host-name,
  ...
}:
with inputs.nixpkgs.lib; {
  imports = [
    ../../modules
    ../../home/users

    ./localization.nix
    ./printing.nix
    ./packages.nix
    ./app-image.nix
    ./compat.nix

    flake.nixosModules.nix
    flake.nixosModules.utils
    flake.nixosModules.vars
    flake.nixosModules.yubi
    flake.nixosModules.fonts
  ];

  networking.hostName = host-name;

  nixpkgs = {
    overlays = [
      inputs.nur.overlays.default
    ];
  };

  modules = {
    devenv = {
      enable = true;
      caches.enable = true;
    };

    nix.caches = mkMerge [
      (mkIf (host-name != "lifbrasir") {
        "cache.07112025.xyz" = "1HUJvXG7ct1ws0zcximEEibEfPPoOPEale5xkQNsRw8=";
      })
    ];

    # a host builds whatever the cache could not give it, then sends it up.
    # lifbrasir is the cache, so it has nowhere to push to.
    nix.push.enable = host-name != "lifbrasir";

    ssh.enable = true;

    yubi.enable = true;

    fonts.enable = true;
  };
}
