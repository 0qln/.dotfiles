{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.git;
in {
  options.modules.git = {
    enable = mkEnableOption "git config";
    lazygit.enable = config.utils.mkEnableOption "lazygit" cfg.enable;
    #todo
    # gitea.enable = config.utils.mkEnableOption "gitea" cfg.enable;
    # github.enable = config.utils.mkEnableOption "github" cfg.enable;
    worksimple = {
      enable = mkEnableOption "worksimple stuff";
      config = mkOption {
        type = types.path;
        description = "The sops encrypted file that contains the git config for work simple.";
      };
    };
    merge = mkOption {
      default = {};
      type = types.submodule {
        options = {
          tool = mkOption {
            type = types.str;
            default =
              if (config.settings.uiEnv == "gui")
              then "meld"
              else "nvimdiff";
            description = "Git merge tool to use.";
            example = "nvimdiff";
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      git
      delta
      tea
      meld
    ];

    programs.git = mkMerge [
      {
        enable = true;
        settings = {
          user = {
            name = "0qln";
            email = "0qln@proton.me";
          };
          pull.rebase = false;
          safe.directory = ["*"];
          init.defaultBranch = "master";
          merge.tool = cfg.merge.tool;
          mergetool.prompt = false;
          mergetool.keepBackup = false;
          submodule.recurse = true;
          alias = {
            fnotes = "fetch origin refs/notes/commits:refs/notes/commits";
            pnotes = "push origin refs/notes/commits";
          };
        };
        lfs.enable = true;
      }
      (mkIf cfg.worksimple.enable {
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
          pagers = [
            {
              colorArg = "always";
              pager = "delta --paging=never -s";
            }
          ];
        };
      };
    };

    sops.secrets."work.config" = mkIf cfg.worksimple.enable {
      sopsFile = cfg.worksimple.config;
      format = "binary";
    };
  };
}
