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
      claude.pling.enable = mkEnableOption "clanker.claude.pling (WSL only)";
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
                  command = getExe pkgs.bash;
                  args = [
                    "-c"
                    ''
                      # @azure-devops/mcp depends on keytar, which dlopens libsecret
                      # and glib; neither is on the default library path on NixOS.
                      export LD_LIBRARY_PATH=${makeLibraryPath [pkgs.libsecret pkgs.glib]}
                      # The server wants base64 of `<user>:<pat>` in the generic
                      # PERSONAL_ACCESS_TOKEN. The user half is ignored as long as it
                      # is non-empty, and the sops secret holds the PAT verbatim as
                      # Azure DevOps issues it. Built here so the generic name never
                      # enters the login shell.
                      export PERSONAL_ACCESS_TOKEN="$(printf '%s' "mcp:$ADO_MCP_PAT" | base64 -w0)"
                      exec npx -y @azure-devops/mcp unicornde --authentication pat
                    ''
                  ];
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

        # claude pling setup
        #
        # A sound, and a Windows toast, when a Claude window wants attention.
        # WSL only: WSLg forwards audio, so the sound plays natively, but it
        # runs no notification daemon -- the toast has to go to the host.
        (let
          cfg = config.modules.clanker.claude;

          # The skill already ships the script, and the flake input already
          # has it in the store, so take it from there. Nothing is copied
          # into ~/.claude and `pling.py install` is never run: the hooks
          # below are the only thing that writes settings.json.
          pling = "${inputs.ws-skills.lib.skills.ws-claude-pling}/scripts/pling.py";

          # Kept verbatim from pling.py's POWERSHELL_TOAST, so a WSL toast
          # looks exactly like a native Windows one. `silent` suppresses the
          # toast's own chime -- the sound is the script's job, and a toast
          # that dings as well is a double pling.
          toast-ps1 = pkgs.writeText "pling-toast.ps1" ''
            $ErrorActionPreference = 'Stop'
            [void][Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
            $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent(
                [Windows.UI.Notifications.ToastTemplateType]::ToastText02)
            $texts = $template.GetElementsByTagName('text')
            [void]$texts.Item(0).AppendChild($template.CreateTextNode($env:PLING_TITLE))
            [void]$texts.Item(1).AppendChild($template.CreateTextNode($env:PLING_BODY))
            $audio = $template.CreateElement('audio')
            $audio.SetAttribute('silent', 'true')
            [void]$template.DocumentElement.AppendChild($audio)
            $toast = New-Object Windows.UI.Notifications.ToastNotification $template
            $appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
            [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
          '';

          # PowerShell must get that script in one piece. Feeding it on stdin
          # with `-Command -` makes it read the file back a line at a time,
          # which silently drops the one statement spanning two lines: it
          # exits 0 and shows nothing at all. -EncodedCommand hands the whole
          # script over as a single unit and sidesteps every layer of quoting
          # on the way. It wants base64 of UTF-16LE, which is what this
          # builds -- with the python3 the hook already depends on, so the
          # closure does not grow.
          toast = pkgs.runCommand "pling-toast.b64" {} ''
            ${getExe pkgs.python3} -c 'import base64,sys;sys.stdout.write(base64.b64encode(open(sys.argv[1],encoding="utf-8").read().encode("utf-16le")).decode())' ${toast-ps1} > $out
          '';

          # pling.py raises its toast through `notify-send` on Linux, which
          # WSL has neither a binary nor a daemon for. This answers to the
          # same `<title> <body>` call and hands the text to the PowerShell
          # above. It reaches PATH only inside the hook command, so it cannot
          # shadow a real notify-send anywhere else.
          notify-send = pkgs.writeShellScriptBin "notify-send" ''
            export PLING_TITLE="''${1:-}"
            export PLING_BODY="''${2:-}"
            # WSLENV is what carries the two across the WSL/Windows boundary;
            # without it the toast arrives with both of its lines empty.
            export WSLENV="PLING_TITLE:PLING_BODY''${WSLENV:+:''${WSLENV}}"
            exec powershell.exe -NoProfile -NonInteractive \
              -EncodedCommand "$(< ${toast})"
          '';

          # Spelled out rather than wrapped in a script: `pling.py` and
          # `--event <name>` are the two strings pling.py matches to find its
          # own hooks, so a wrapper would leave `status` reporting them as
          # not installed, hide them from `uninstall`, and have `install`
          # count them as somebody else's. A bare PATH prefix keeps both
          # strings visible and reaches no further than this one command.
          # Nothing here may add a way to fail either -- a Stop hook that
          # exits non-zero blocks Claude from stopping, and `run` is careful
          # to always exit 0.
          hookCommand = event:
            "PATH=${notify-send}/bin:$PATH "
            + "${getExe pkgs.python3} ${pling} run --event ${event}";

          # Mirrors %UserProfile%\.claude\pling.json: the same two events
          # with the same two tones. `flash` is Windows-only and off there
          # too, so the Linux side ignoring it costs nothing. The two quiet
          # events keep their hook so switching one on is a one-line change
          # here rather than a reinstall.
          media = "/mnt/c/WINDOWS/Media";
          events = {
            stop = {
              hook = "Stop";
              enabled = true;
              sound = "${media}/tada.wav";
              flash = false;
              toast = true;
            };
            notification = {
              hook = "Notification";
              enabled = true;
              sound = "${media}/chimes.wav";
              flash = false;
              toast = true;
            };
            subagentstop = {
              hook = "SubagentStop";
              enabled = false;
              sound = null;
              flash = false;
              toast = false;
            };
            sessionend = {
              hook = "SessionEnd";
              enabled = false;
              sound = null;
              flash = false;
              toast = false;
            };
          };
        in
          mkIf (cfg.enable && cfg.pling.enable) {
            programs.claude-code.settings.hooks =
              mapAttrs' (event: e:
                nameValuePair e.hook [
                  {
                    hooks = [
                      {
                        type = "command";
                        command = hookCommand event;
                        statusMessage = "Pling";
                        async = true;
                      }
                    ];
                  }
                ])
              events;

            home.file."${config.programs.claude-code.configDir}/pling.json".text =
              builtins.toJSON (mapAttrs (_: e: removeAttrs e ["hook"]) events);
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
