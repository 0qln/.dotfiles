{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.git;
in
  with lib; {
    options.modules.git = {
      enable = mkEnableOption "git config";
      lazygit.enable = config.utils.mkEnableOption "lazygit" cfg.enable;
      enableWorkSimple = mkEnableOption "worksimple stuff";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        git
        delta
      ];

      programs.git = mkMerge [
        {
          enable = true;
          user.name = "0qln";
          user.email = "linusnag@gmail.com";
          extraConfig = {
            pull.rebase = false;
            safe.directory = ["*"];
            init.defaultBranch = "master";
            mergetool.prompt = false;
            mergetool.keepBackup = false;
          };
        }
        (mkIf cfg.enableWorkSimple {
          includes = [
            {
              condition = "gitdir:~/repos/work.devops/**";
              path = config.sops.secrets."work.config".path;
            }
          ];
        })
      ];

      programs.lazygit = mkIf cfg.lazygit.enable {
        enable = true;
        # https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md
        settings = {
          # https://github.com/jesseduffield/lazygit/issues/155#issuecomment-2260986940
          git = {
            paging = {
              colorArg = "always";
              pager = "delta --paging=never -s";
            };
          };
        };
      };

      sops.secrets."work.config" = mkIf cfg.enableWorkSimple {
        sopsFile = ./work.config.secrets;
        format = "binary";
      };
    };
  }
