{inputs, ...}:
with inputs.nixpkgs.lib; {
  flake.nixosModules.yubi = {config, ...}: let
    cfg = config.modules.yubi;
  in {
    options.modules.yubi = {
      enable = mkEnableOption "yubikey support";
    };

    config = mkIf cfg.enable {
      # smart-card daemon
      services.pcscd = {
        enable = true;
      };
    };
  };

  flake.homeModules.yubi = {
    pkgs,
    config,
    ...
  }: let
    cfg = config.modules.yubi;
  in {
    options.modules.yubi = {
      enable = mkEnableOption "yubikey tooling";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        yubikey-manager
        age-plugin-yubikey
      ];

      services.yubikey-agent = {
        enable = true;
      };
    };
  };
}
