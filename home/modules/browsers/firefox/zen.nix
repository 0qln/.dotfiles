args @ {
  inputs,
  lib,
  pkgs,
  config,
  backupExtension,
  ...
}: let
  cfg = config.modules.browser.firefox.zen;
in
  with lib; {
    imports = with inputs; [
      zen-browser.homeModules.twilight
    ];

    options.modules.browser.firefox.zen = {
      enable = mkEnableOption "zen";
      setDefault = mkEnableOption "set default browser";
      profiles = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "a list of strings of profiles that are defined in ./profiles";
      };
    };

    config = mkIf cfg.enable {
      modules.browser._xdgDefault = mkIf cfg.setDefault (mkDefault "zen-twilight.desktop");

      home.activation.zen-profiles-cat = lib.hm.dag.entryAfter ["writeBoundary"] (
        let
          # This is the new file that was created by home-manager.
          profilesIni = "${config.home.homeDirectory}/.zen/profiles.ini";
          # This is the file that (maybe) was changed imperatively and moved to the
          # backup file by home-manager.
          profilesIniOld = "${profilesIni}.${backupExtension}";
        in "${
          pkgs.writeScript "zen-profiles-concat"
          # python
          ''
            #! /usr/bin/env nix-shell
            #! nix-shell -i python3 -p python3 python3Packages.configparser

            # This script concats the new nix-generated config with existing
            # imperatively generated configs.

            import configparser
            import os
            import os.path
            import sys

            # exit if not profile config existed before the nix config was
            # generated.
            if not os.path.isfile('${profilesIniOld}') or not os.path.isfile('${profilesIni}'):
              sys.exit()

            # https://docs.python.org/3/library/configparser.html
            config = configparser.ConfigParser()
            config.optionxform = lambda option: option

            # last ini file has priority
            config.read(['${profilesIniOld}', '${profilesIni}'])

            # ensure we only have one 'Default=1' section
            default = None
            for sectionName in config.sections():
              if 'Default' in config[sectionName]:
                if default == None:
                  config[sectionName]['Default'] = '1'
                  default = sectionName
                else:
                  del config[sectionName]['Default']

            # delete profiles.ini nix/store link such that we can write to the file
            os.unlink('${profilesIni}')

            # delete profiles.ini.${backupExtension} such that we don't get an error next time that home-
            # manager tries to backup the profiles.ini to that location
            os.unlink('${profilesIniOld}')

            # write the combined config into profiles.ini
            with open('${profilesIni}', 'w') as configfile:
              config.write(configfile, space_around_delimiters=False)
          ''
        }"
      );

      programs.zen-browser = {
        enable = true;

        # any other options under `programs.firefox` are also supported here.

        profiles = let
          mkProfile = p: (nameValuePair p (import ./profiles/${p}.nix args));
          profiles = map mkProfile cfg.profiles;
        in
          builtins.listToAttrs profiles;
      };
    };
  }
