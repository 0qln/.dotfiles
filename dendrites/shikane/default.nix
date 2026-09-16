{inputs, ...}:
with inputs.nixpkgs.lib; {
  # workflow: plug in a monitor
  # → catchall gives it sane defaults immediately
  # → arrange it however you like with hyprctl keyword
  # → monitors-capture docked-office → paste into home-vars.nix
  flake.homeModules.shikane = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.modules.shikane;

    # shikane only touches properties that are actually present in the TOML,
    # so unset options must be dropped rather than serialised as null.
    prune = filterAttrs (_: v: v != null);

    nullIfEmpty = xs:
      if xs == []
      then null
      else xs;

    mkOutput = o:
      prune {
        inherit (o) search enable mode position scale transform;
        adaptive_sync = o.adaptiveSync;
        exec = nullIfEmpty o.exec;
      };

    mkProfile = name: profile:
      prune {
        inherit name;
        output = map mkOutput profile.outputs;
        exec = nullIfEmpty profile.exec;
      };

    # Arrange the displays by hand, then capture the result as a ready-to-paste
    # snippet. This is the fast path that replaces editing config by hand.
    capture = pkgs.writeShellApplication {
      name = "monitors-capture";
      runtimeInputs = [config.services.shikane.package];
      text = ''
        if [ $# -lt 1 ]; then
          echo "usage: monitors-capture <profile-name>" >&2
          exit 1
        fi
        # -d/-n additionally include description and port name in the searches;
        # vendor, model and serial are included by default.
        shikanectl export -d -n "$1"
      '';
    };
  in {
    config = mkIf cfg.enable {
      services.shikane = {
        enable = true;
        settings = prune {
          inherit (cfg) timeout;
          profile = mapAttrsToList mkProfile cfg.profiles;
        };
      };

      home.packages = [capture];
    };
  };
}
