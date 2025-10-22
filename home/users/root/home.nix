{
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
        type = types.enum [
          "tui"
          "gui"
        ];
        default = "tui";
        description = "Directs what stuff is installed. (e.g. firefox browser for gui enviromnets)";
      };
    };

    imports = [
      ../../modules/bash
      ../../modules/btop
      ../../modules/direnv
      ../../modules/git
      ../../modules/tmux
      ../../modules/lf
      ../../modules/nixvim
      ../../modules/sops
      ../../modules/tools
      ../../modules/zoxide
    ];

    config = mkIf cfg.enable {
      # docs:
      # https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module
      # https://nix-community.github.io/home-manager/options.xhtml#opt-home.activation
      # https://github.com/nix-community/home-manager/blob/master/modules/home-environment.nix
      # https://home-manager-options.extranix.com/
      nixpkgs.config.allowUnfree = true;

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      home.stateVersion = "25.05"; # Did you read the comment?

      modules = mkMerge [
        {
          nixvim.enable = mkDefault true;
        }
        (mkIf (cfg.uiEnv == "gui") {
          # gui-only modules
        })
        (mkIf (cfg.uiEnv == "tui") {
          # tui-only modules
        })
      ];
    };
  }
