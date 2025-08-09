{
  inputs,
  ...
}:
{
  # docs:
  # https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module
  # https://nix-community.github.io/home-manager/options.xhtml#opt-home.activation
  # https://github.com/nix-community/home-manager/blob/master/modules/home-environment.nix
  # https://home-manager-options.extranix.com/
  home-manager.users.oq =
    {
      pkgs,
      config,
      sops-nix,
      lib,
      ...
    }:
    {
      nixpkgs.config.allowUnfree = true;

      imports = [
        inputs.zen-browser.homeModules.twilight
        inputs.nixvim.homeModules.nixvim
        inputs.sops-nix.homeManagerModules.sops
        ./hypr
        ./btop
        ./git
        ./lf
        ./todoist
        ./youtube-music
        ./rofi
        ./starship
        ./kitty
        ./sops
        ./nixvim
        ./obsidian
      ];

      home.packages = with pkgs; [

        git
        gh

        fzf
        fd
        tree
        unzip

        gcc

        rustup
        rustc

        ffmpeg
        mpv
        imagemagick
        qimgv

        wallust

        nerd-fonts.victor-mono
      ];

      # direnv
      programs.direnv = {
        enable = true;
      };

      programs.bash = {
        enable = true;
        # Setting session variables normally is broken when using home-manager ;(
        # context: https://github.com/nix-community/home-manager/issues/1011
        initExtra = ''
          export EDITOR="nvim"
          # wallust run ${toString ./wallpapers/wallhaven-zygxxo.jpg}

          alias cdf='cd $(fd --hidden --type d | fzf)'
        '';
      };

      # Configure browsers

      programs.firefox.enable = true;
      programs.zen-browser = {
        enable = true;
        # any other options under `programs.firefox` are also supported here.
        # see `man home-configuration.nix`.
      };

      # workaround for making the config writable:
      # while this works... it is incredibly ugly :(
      # home.activation = {
      # run cp -RL "${config.xdg.configHome}/git" "${config.xdg.configHome}/git.contents"
      # run rm -rf "${config.xdg.configHome}/git"
      # run mv "${config.xdg.configHome}/git.contents" "${config.xdg.configHome}/git"
      # run chmod -R 755 "${config.xdg.configHome}/git"
      # replaceWithTarget = lib.hm.dag.entryAfter [ "writeBoundry" ] ''

      #   run cp -RL "${config.xdg.configHome}/todoist" "${config.xdg.configHome}/todoist.contents"
      #   run rm -rf "${config.xdg.configHome}/todoist"
      #   run mv "${config.xdg.configHome}/todoist.contents" "${config.xdg.configHome}/todoist"
      #   run chmod 755 "${config.xdg.configHome}/todoist"
      #   run chmod 600 "${config.xdg.configHome}/todoist/config.json"

      # '';
      # removeExisting = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      #   rm -rf "${config.xdg.configHome}/.config/git/config"
      # '';
      #
      # copy = let
      #   new = pkgs.writeText "tmp" (builtins.readFile ./);
      # in lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      #   rm -rf "/Users/me/.yabairc"
      #   cp "${newYabai}" "/Users/me/.yabairc"
      #   chmod +x "/Users/me/.yabairc"
      # '';
      # };

      # sops.secrets = {
      #   "oq-sshKeys-server" = {
      #     format = "binary";
      #     sopsFile = ./server/id_ed25519;

      #   };
      #   "oq-sshKeys-server-pub" = {
      #     format = "binary";
      #     sopsFile = ./server/id_ed25519.pub;
      #   };
      # };
      # home.activation."ssh-keys" = lib.hm.dag.entryAfter [ "writeBoundry" ] ''

      # '';

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      home.stateVersion = "25.05"; # Did you read the comment?
    };
}
