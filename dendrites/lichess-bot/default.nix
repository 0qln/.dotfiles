{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.lichess-bot = {
    config,
    pkgs,
    ...
  }: let
    serviceName = "lichess-bot";
    cfg = config.modules.lichess-bot;

    # https://github.com/lichess-bot-devs/lichess-bot/wiki/How-to-Install#linux
    # https://github.com/lichess-bot-devs/lichess-bot/blob/master/requirements.txt
    pythonEnv = pkgs.python3.withPackages (ps: with ps; [chess pyyaml requests backoff rich]);

    lichess-bot-pkg = pkgs.stdenv.mkDerivation {
      pname = "lichess-bot-src";
      version = "2026.5.12.2";
      src = pkgs.fetchFromGitHub {
        owner = "lichess-bot-devs";
        repo = "lichess-bot";
        rev = "c67bbfe57e0d406fd774958bd571f82f0ae5580a";
        sha256 = "sha256-oIw6UmKOP6Ut+CtvdPXPF6LrHyQQndEN0YlWvJ/hZ/I=";
      };

      nativeBuildInputs = [pkgs.makeWrapper];

      buildInputs = [pythonEnv];
      buildPhase = "true";
      installPhase =
        # bash
        ''
          mkdir -p $out/bin $out/share/lichess-bot
          cp -r * $out/share/lichess-bot

          makeWrapper ${pythonEnv}/bin/python3 $out/bin/lichess-bot \
            --add-flags "$out/share/lichess-bot/lichess-bot.py" \
            --set PYTHONUNBUFFERED 1
        '';

      meta.mainProgram = "lichess-bot";
    };
  in {
    options.modules.lichess-bot = mkOption {
      type = types.submodule ({config, ...}: {
        options = {
          enable = mkEnableOption "lichess-bot";
          apiTokenFile = mkOption {
            type = types.path;
          };
          configFile = mkOption {
            type = types.path;
            description = "The path to the bot's yaml configuration file.";
          };
          name = mkOption {
            type = types.str;
            default = "my-bot";
            description = "The name of the bot.";
          };
          logDir = mkOption {
            type = types.str;
            default = "${serviceName}_${config.name}";
          };
          restartTriggers = mkOption {
            type = types.listOf types.package;
            default = [];
            description = "Packages that, when updated, trigger a service restart.";
          };
        };
      });
    };

    config = mkIf cfg.enable (let
      name = "${serviceName}_${cfg.name}";
    in {
      sops.secrets = {
        "${name}/api-token" = {
          sopsFile = cfg.apiTokenFile;
          mode = "0400";
          format = "binary";
        };
      };

      environment.etc."${name}/config.yml".source = cfg.configFile;

      # https://github.com/lichess-bot-devs/lichess-bot/wiki/How-to-Run-lichess%E2%80%90bot#running-as-a-service
      systemd.services.${name} = {
        after = ["network-online.target"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];

        description = "${cfg.name}, a lichess-bot";

        inherit (cfg) restartTriggers;

        serviceConfig = let
          configPath = "/etc/${name}/config.yml";
          tokenPath = config.sops.secrets."${name}/api-token".path;
        in {
          Restart = "on-failure";
          RestartSec = "30s";

          Environment = ["PYTHONUNBUFFERED=1"];

          # https://github.com/lichess-bot-devs/lichess-bot/wiki/How-to-Run-lichess%E2%80%90bot#running-lichess-bot
          ExecStart = pkgs.writeShellScript name ''
            export LICHESS_BOT_TOKEN=$(cat "${tokenPath}")
            ${getExe lichess-bot-pkg} -u --config ${configPath} --logfile "/var/log/${cfg.logDir}/log.txt" --disable_auto_logging
          '';

          # https://linux-audit.com/systemd/settings/units/readonlypaths/
          ProtectSystem = "strict";
          BindReadOnlyPaths = [tokenPath configPath];
          LogsDirectory = cfg.logDir;

          PrivateTmp = true;
        };
      };
    });
  };
}
