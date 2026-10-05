{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.clanker = {config, ...}: {
    options.modules.clanker = {
      enable = mkEnableOption "clanker";
    };

    config = let
      cfg = config.modules.clanker;
    in
      mkIf cfg.enable
      {
        # so copilot cli can resolve /bin/bash
        services.envfs.enable = true;
      };
  };

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

      # Skill name -> source directory; the attrset form merges with any
      # skills defined elsewhere, unlike `lib.skillsPath`. WorkSimple's
      # skills are Odoo-internal, so gate them like the ado MCP server.
      wsSkills =
        optionalAttrs config.settings.enableWorkSimple
        inputs.ws-skills.lib.skills;
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
                  headers.Authorization = "Bearer \${GITHUB_MCP_PAT}";
                };
              }
              (mkIf config.settings.enableWorkSimple {
                ado-unicornde = {
                  command = "npx";
                  args = ["-y" "@azure-devops/mcp" "unicornde" "--authentication" "pat"];
                  # The server wants the generic `PERSONAL_ACCESS_TOKEN`; keep that
                  # name out of the login shell and map it in per-server instead.
                  # Value is base64 of `<email>:<pat>`, from the clanker dotenv.
                  env.PERSONAL_ACCESS_TOKEN = "\${ADO_MCP_PAT}";
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
            # https://home-manager-options.extranix.com/?query=claude-code&release=master
            programs.claude-code = {
              enable = true;
              enableMcpIntegration = true;
              mcpServers = {}; # define in programs.mcp.servers instead.
              settings = {
                includeCoAuthoredBy = false;
              };
              skills = wsSkills;
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
              context = builtins.readFile (pkgs.callPackage ./andrej-kaparthy.nix {});
            };

            # make the config file mutable
            home.file."${config.programs.claude-code.configDir}/settings.json" = {
              mutable = true;
              force = true;
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
              skills = wsSkills;
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
