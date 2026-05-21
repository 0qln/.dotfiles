{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.homeModules.emojis = {pkgs, ...}: {
    # todo: rofi emoji keyboard setup here
  };

  flake.nixosModules.emojis = {
    pkgs,
    config,
    ...
  }: let
    cfg = config.modules.emojis;
  in {
    options.modules.emojis = {
      enable = mkEnableOption "emojis";
    };

    config = mkIf cfg.enable {
      services.actkbd = {
        enable = true;
        bindings = [
          # {
          #   keys = [18];
          #   events = ["key"];
          #   command = "${getExe pkgs.kitty}";
          # }
        ];
      };
    };
  };
}
