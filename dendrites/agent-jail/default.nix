{
  inputs,
  self,
  ...
}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.agent-jail = {config, ...}: let
    cfg = config.modules.agent-jail;
  in {
    options.modules.agent-jail = {
      enable = mkEnableOption "agent jail distrobox system dependencies";
    };

    imports = [
      self.nixosModules.distrobox
    ];

    config = mkIf cfg.enable {
      modules.distrobox.enable = true;
    };
  };

  # An Ubuntu distrobox with its own home, for running agents and skill
  # evals with a sandboxed Bash. On the host itself Claude Code's sandbox
  # trips over the read-only, home-manager-managed ~/.ssh; inside the box
  # the home is a plain directory, and bubblewrap works there.
  flake.homeModules.agent-jail = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.modules.agent-jail;
    inherit (cfg) containerName;
    containerHome = "${config.home.homeDirectory}/.distrobox/${containerName}";
    manifest = "${containerHome}/distrobox.ini";

    # `distrobox enter -- cmd` runs no profile, so the jail's PATH is set
    # here: the flake's claude (and node, for plugin hooks) from /nix/store,
    # then the container's own tools. Nothing from the host's PATH.
    jailPath = concatStringsSep ":" [
      (makeBinPath [cfg.claudePackage pkgs.nodejs])
      "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    ];

    agentJail = pkgs.writeShellApplication {
      name = "agent-jail";
      text =
        # bash
        ''
          name=${escapeShellArg containerName}
          manifest=${escapeShellArg manifest}

          # The jail's own Claude Code config, never the host's: the host's
          # settings, plugins, hooks and CLAUDE.md would leak into every run.
          run() {
            distrobox enter --name "$name" -- env \
              CLAUDE_CONFIG_DIR=${escapeShellArg "${containerHome}/.claude"} \
              PATH=${escapeShellArg jailPath} \
              "$@"
          }

          usage() {
            cat >&2 <<'USAGE'
          usage: agent-jail <command>
            create                build the box from its manifest (first time, or after a change)
            recreate              throw the box away and build it again; its home stays
            login                 log Claude Code in, once, into the jail's own config
            status                whether the jail's Claude Code is logged in
            shell                 a shell in the jail, in the current directory
            claude [args...]      Claude Code in the jail, in the current directory
            eval <dir> [args...]  claude plugin eval with sandboxed Bash, for skills you wrote
            rm                    remove the box; its home stays
          USAGE
            exit 1
          }

          cmd="''${1:-}"
          if [ "$#" -gt 0 ]; then
            shift
          fi

          case "$cmd" in
            create) distrobox assemble create --file "$manifest" ;;
            recreate) distrobox assemble create --replace --file "$manifest" ;;
            login) run claude auth login ;;
            status) run claude auth status ;;
            shell) run bash -l ;;
            claude) run claude "$@" ;;
            eval)
              dir="''${1:?usage: agent-jail eval <skill or plugin dir> [claude plugin eval options]}"
              shift
              # --scaffold and --trust-plugin run the cases' own scripts, which
              # is why this is for skills you wrote yourself.
              run claude plugin eval "$dir" --allow-tools Write,Edit,Bash --scaffold --trust-plugin --no-publish "$@"
              ;;
            rm) distrobox rm --force "$name" ;;
            *) usage ;;
          esac
        '';
    };
  in {
    options.modules.agent-jail = {
      enable = mkEnableOption "agent jail";
      containerName = mkOption {
        type = types.str;
        default = "agent-jail";
        description = "Name of the distrobox container.";
      };
      image = mkOption {
        type = types.str;
        default = "docker.io/library/ubuntu:24.04";
        description = "Container image; the default packages are Ubuntu 24.04 names.";
      };
      packages = mkOption {
        type = types.listOf types.str;
        # bubblewrap and socat are what Claude Code's sandbox needs before it
        # lets an agent use Bash; libicu74 is what the .NET SDK needs; the
        # rest is what agents reach for.
        default = ["bubblewrap" "socat" "git" "ripgrep" "curl" "ca-certificates" "python3" "libicu74"];
        description = "apt packages installed into the box.";
      };
      dotnetChannels = mkOption {
        type = types.listOf types.str;
        default = ["10.0"];
        description = ".NET SDK channels installed to /opt/dotnet; empty for none.";
      };
      claudePackage = mkOption {
        type = types.package;
        default = pkgs.claude-code;
        defaultText = literalExpression "pkgs.claude-code";
        description = "Claude Code inside the jail, run from /nix/store.";
      };
    };

    imports = [
      self.homeModules.distrobox
    ];

    config = mkIf cfg.enable {
      home.packages = [agentJail];

      home.file.".distrobox/${containerName}/setup-container.sh" = {
        executable = true;
        force = true;
        text =
          # bash
          ''
            #!/usr/bin/env bash

            set -euo pipefail

            # init_hooks run as root on every start of the container, so every
            # step below checks first whether it is already done.
            missing=()
            for package in ${escapeShellArgs cfg.packages}; do
              dpkg -s "$package" >/dev/null 2>&1 || missing+=("$package")
            done
            if [ "''${#missing[@]}" -gt 0 ]; then
              apt-get update -y
              DEBIAN_FRONTEND=noninteractive apt-get install -y "''${missing[@]}"
            fi

            for channel in ${escapeShellArgs cfg.dotnetChannels}; do
              if ! /opt/dotnet/dotnet --list-sdks 2>/dev/null | grep -q "^$channel\."; then
                curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
                bash /tmp/dotnet-install.sh --channel "$channel" --install-dir /opt/dotnet
                rm -f /tmp/dotnet-install.sh
              fi
            done
            if [ -x /opt/dotnet/dotnet ]; then
              ln -sf /opt/dotnet/dotnet /usr/local/bin/dotnet
            fi
          '';
      };

      # its own manifest: ~/.config/distrobox/distrobox.ini belongs to checkmk.
      home.file.".distrobox/${containerName}/distrobox.ini".text =
        # ini
        ''
          [${containerName}]
          image=${cfg.image}
          pull=true
          home=${containerHome}

          init_hooks=${containerHome}/setup-container.sh
        '';
    };
  };
}
