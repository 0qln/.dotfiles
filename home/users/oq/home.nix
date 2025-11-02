{
  config,
  lib,
  inputs,
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
        ../../utils
        ../../modules
        ../../vars
        ../../themes
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

      themes.cogecha-1_uneasy-flowers.enable = mkDefault true;

      private = {
        secrets.gh.hostsYml = mkDefault true;
      };

      modules = mkMerge [
        {
          nixvim.enable = mkDefault true;
          bash.enable = mkDefault true;
          git.enable = mkDefault true;
          tmux.enable = mkDefault true;
          secrets.ssh.enable = mkDefault true;
          btop.enable = mkDefault true;
          direnv.enable = mkDefault true;
          gh.enable = mkDefault true;
          lf.enable = mkDefault true;
          proton.vpn.enable = mkDefault true;
          repos.enable = mkDefault true;
          xdg-utils.enable = mkDefault true;
          yubi.enable = mkDefault true;
          tools.enable = mkDefault true;
          zoxide.enable = mkDefault true;
          ssh.enable = mkDefault true;
          starship.enable = mkDefault true;
          bluetooth.client = mkDefault "bluetui";
        }

        # gui-only modules
        (mkIf (cfg.uiEnv == "gui") {
          terminal.emulator = mkDefault "kitty";
          nixvim.wayland.enable = mkDefault true;
          browser.firefox = {
            firefox = {
              enable = mkDefault true;
            };
          };
          hypr.enable = mkDefault true;
          discord.vesktop.enable = mkDefault true;
          discord.vesktop.theme = mkDefault "system24";
          libreoffice.enable = mkDefault true;
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
          zathura = {
            setDefault = mkDefault ["application/pdf"];
            enable = mkDefault true;
          };
          tools = {
            qimgv.setDefault = mkDefault [
              "image/png"
              "video/webm"
              "image/jpeg"
              "image/gif"
              "image/bmp"
              "image/webp"
            ];
          };
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
