{
  lib,
  config,
  ...
}:
with lib; {
  config = mkIf config.modules.nixvim.clanker.enable {
    programs.nixvim = {
      plugins = {
        copilot-chat = {
          enable = true;
        };
      };
    };
  };
}
