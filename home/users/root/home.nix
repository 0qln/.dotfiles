{
  flake,
  config,
  lib,
  ...
}: let
  cfg = config.settings;
in
  with lib; {
    options.settings = {
      enable = config.utils.mkEnableOption "settings" true;
      uiEnv = mkOption {
        type = types.enum (import ./envs.nix);
        default = "tui";
        description = "Directs what stuff is installed. (e.g. firefox browser for gui enviromnets)";
      };
    };

    imports =
      [
        flake.homeModules.utils
        flake.homeModules.vars
        flake.homeModules.sops
        flake.homeModules.nixvim
      ]
      ++ [
        ../../modules
        ../../themes
      ];

    config = mkIf cfg.enable {
      vars = {
        root = mkDefault config.home.homeDirectory;
        cloud.dir = mkDefault "${config.vars.root}/nextcloud";
        pictures.dir = mkDefault "${config.vars.cloud.dir}/pictures";
        screenshots.dir = mkDefault "${config.vars.pictures.dir}/screenshots";
      };

      # docs:
      # https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module
      # https://nix-community.github.io/home-manager/options.xhtml#opt-home.activation
      # https://github.com/nix-community/home-manager/blob/master/modules/home-environment.nix
      # https://home-manager-options.extranix.com/
      nixpkgs.config.allowUnfree = true;

      home = {
        username = import ./name.nix;

        homeDirectory = mkForce "/root/";

        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It‘s perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        stateVersion = "25.05"; # Did you read the comment?
      };

      modules = mkMerge [
        {
          sops.enable = mkDefault true;
          nixvim.enable = mkDefault true;
          lf.enable = mkDefault true;
          bash.enable = mkDefault true;
          btop.enable = mkDefault true;
          dev.direnv.enable = mkDefault true;
          git.enable = mkDefault true;
          tmux.enable = mkDefault true;
          tools.enable = mkDefault true;
          zoxide.enable = mkDefault true;
        }
        (mkIf (cfg.uiEnv == "tui") {
          # tui-only modules
        })
      ];
    };
  }
