{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.minecraft-service;
in {
  options.modules.minecraft-server = {
    enable = mkEnableOption "minecraft server";
    port = mkOption {type = types.int;};
  };

  config = mkIf cfg.enable {
    services.minecraft-server = {
      enable = true;
      eula = true;
      openFirewall = true; # Opens the port the server is running on (by default 25565 but in this case 43000)
      declarative = true;
      whitelist = {
        "aYellow" = "e97d3fe2-c417-42ad-a7c2-2a8f29c0b322";
        "1st_Eeveeanist" = "c81fbd05-113f-46c2-84c1-5b01d00cdcc8";
      };
      serverProperties = {
        server-port = 43000;
        difficulty = 3;
        gamemode = 1;
        max-players = 5;
        motd = "NixOS Minecraft server!";
        white-list = true;
        allow-cheats = true;
      };
      jvmOpts = "-Xms2048M -Xmx4096M";
    };
  };
}
