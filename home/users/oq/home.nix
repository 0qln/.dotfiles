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
      enableWorkSimple = mkEnableOption "work simple stuff";
    };

    imports =
      [
        inputs.private.homeModules."oq"
      ]
      ++ [
        ./vars.nix
      ]
      ++ [
        ../../modules/utils
      ]
      ++ [
        #TODO: move these imports somewhere else
        ../../themes/wlop-1_chinese-festival
        ../../themes/opts.nix
        ../../vars/opts.nix
      ]
      ++ [
        # commons for gui and tui
        ../../modules/btop
        ../../modules/direnv
        ../../modules/gh
        ../../modules/lf
        ../../modules/nixvim
        ../../modules/sops
        ../../modules/ssh
        ../../modules/tools
        ../../modules/zoxide
        ../../modules/secrets
        # ../../modules/azure
        # ../../modules/agents
        ../../modules/yubi
        ../../modules/proton/vpn.nix
        ../../modules/repos
      ]
      ++ [
        # modules
        ../../modules/tmux
        ../../modules/browsers
        ../../modules/bash
        ../../modules/hypr/_opt.nix
        ../../modules/hypr/_all.nix
        ../../modules/citrix
        ../../modules/git
        ../../modules/discord/vesktop.nix
        ../../modules/zoom
        ../../modules/libreoffice
        ../../modules/kooha
        ../../modules/shotcut
        ../../modules/jetbrains
        ../../modules/minecraft/prismlauncher.nix
        ../../modules/msteams
        ../../modules/nextcloud
        ../../modules/postman
        ../../modules/wallpaper-engine
        ../../modules/cursors
        ../../modules/fonts
        ../../modules/terminal
        ../../modules/obsidian
        ../../modules/rofi
        ../../modules/vscode
        ../../modules/youtube-music
        ../../modules/theme
        ../../modules/secrets
        ../../modules/todoist
        ../../modules/splatmoji
        ../../modules/starship
        ../../modules/zathura
      ]
      ++ [
        # todo: write modules and move these down into gui only section
        ../../modules/xdg-utils
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

      theme."enable_${config.vars.theme.name}" = mkDefault true;

      modules = mkMerge [
        {
          nixvim.enable = mkDefault true;
          bash.enable = mkDefault true;
          git.enable = mkDefault true;
          tmux.enable = mkDefault true;
          secrets.ssh.enable = mkDefault true;
        }

        # gui-only modules
        (mkIf (cfg.uiEnv == "gui") {
          browser.firefox.firefox.enable = mkDefault true;
          hypr.enable = mkDefault true;
          discord.vesktop.enable = mkDefault true;
          discord.vesktop.theme = mkDefault "system24";
          libreoffice.enable = mkDefault true;
          jetbrains.enable = mkDefault true;
          nextcloud.enable = mkDefault true;
          cursor.enable = mkDefault true;
          fonts.enable = mkDefault true;
          obsidian.enable = mkDefault true;
          rofi.enable = mkDefault true;
          vscode.enable = mkDefault true;
          ytm.enable = mkDefault true;
          todoist = {
            enable = mkDefault true;
            cliProgram.enable = mkDefault true;
            quickAdd.enable = mkDefault true;
          };
          starship.enable = mkDefault true;
          zathura.enable = mkDefault true;
        })

        # tui-only modules
        (mkIf (cfg.uiEnv == "tui") {
          #
        })

        (mkIf (cfg.uiEnv == "gui" && cfg.enableWorkSimple) {
          citrix.enable = mkDefault true;
          browser = {
            chrome.chromium = {
              enable = mkDefault true;
              enableWorkSimple = mkDefault true;
            };
          };
          git.enableWorkSimple = mkDefault true;
          msteams.enable = true;
          postman.enable = true;
        })
      ];
    };
  }
