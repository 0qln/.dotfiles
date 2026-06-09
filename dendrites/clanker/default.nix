{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.homeModules.clanker = {
    config,
    pkgs,
    ...
  }: {
    options.modules.clanker = {
      enable = mkEnableOption "clanker";
      claude.enable = mkEnableOption "clanker.claude";
      github-copilot.enable = mkEnableOption "clanker.github-copilot";
    };

    config = let
      cfg = config.modules.clanker;
    in
      mkIf cfg.enable (mkMerge [
        # global clankkker setup
        {
          programs.mcp = {
            enable = true;
            servers = mkMerge [
              {
                playwright = {
                  type = "local";
                  command = "npx";
                  args = ["@playwright/mcp@latest"];
                  tools = ["*"];
                };
                nixos = {
                  command = "nix";
                  args = ["run" "github:utensils/mcp-nixos" "--"];
                };
                github = {
                  type = "http";
                  url = "https://api.githubcopilot.com/mcp/";
                };
              }
              (mkIf config.settings.enableWorkSimple {
                ado-remote-unicornde = {
                  type = "http";
                  url = "https://mcp.dev.azure.com/unicornde";
                };
              })
            ];
          };
        }

        # claude setup
        (let
          cfg = config.modules.clanker.claude;
        in
          mkIf cfg.enable {
            programs.claude-code = {
              enable = true;
              settings = {
                includeCoAuthoredBy = false;
              };
            };
          })

        # github-copilot setup
        (let
          cfg = config.modules.clanker.github-copilot;
        in
          mkIf cfg.enable {
            # https://home-manager-options.extranix.com/?query=github-copilot-cli&release=master
            programs.github-copilot-cli = {
              enable = true;
              enableMcpIntegration = true;
              mcpServers = {}; # define in programs.mcp.servers instead.
              settings = {
                banner = "never";
                includeCoAuthoredBy = false;
                trusted_folders = [
                  config.vars.repos.dir
                  config.vars.flake.dir
                ];
              };
              skills = {};
              lspServers = {
                rust = {
                  command = "${getExe pkgs.rust-analyzer}";
                  args = [];
                  fileExtensions = {
                    ".rs" = "rust";
                    ".toml" = "toml";
                  };
                };
              };
              context = let
                claudeMd = builtins.readFile (pkgs.callPackage ./andrej-kaparthy.nix {});
                githubCopilotMd = builtins.replaceStrings ["CLAUDE"] ["Github-Copilot"] claudeMd;
              in "${githubCopilotMd}";
            };

            # make the config file mutable
            home.file."${config.programs.github-copilot-cli.configDir}/config.json" = {
              mutable = true;
              force = true;
            };
          })
      ]);
  };
}
