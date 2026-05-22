{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.flatpak = {config, ...}: let
    cfg = config.modules.flatpak;
  in {
    imports = [
      inputs.nix-flatpak.nixosModules.nix-flatpak
    ];

    options.modules.flatpak = {
      enable = mkEnableOption "flatpak";
    };

    config = mkIf cfg.enable {
      services.flatpak = {
        enable = true;
      };
    };
  };

  flake.homeModules.flatpak = {config, ...}: let
    cfg = config.modules.flatpak;
  in {
    imports = [
      inputs.nix-flatpak.homeManagerModules.nix-flatpak
    ];

    options.modules.flatpak = {
      enable = mkEnableOption "flatpak";
    };

    # https://github.com/gmodena/nix-flatpak/blob/main/modules/home-manager.nix
    config = mkIf cfg.enable {
      home.sessionVariables = {
        XDG_DATA_DIRS = "$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$XDG_DATA_DIRS";
      };

      services.flatpak = {
        # enable defaults to system-option.enable

        packages = [
          "com.visualstudio.code"
        ];

        overrides = {
          "com.visualstudio.code".Context = {
            filesystems = [
              "xdg-config/git:ro" # Expose user Git config
              "/app" # Some extensinos require write access (such as the Background extension)
            ];
            sockets = [
              "gpg-agent" # Expose GPG agent
              "pcsc" # Expose smart cards (i.e. YubiKey)
            ];
          };
        };
      };
    };
  };
}
