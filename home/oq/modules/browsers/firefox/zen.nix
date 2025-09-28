args @ {
  inputs,
  lib,
  pkgs,
  config,
  backupExtension,
  ...
}: let
  utils = args.utils args;
in {
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  home.activation.zen-profiles-cat =
    lib.hm.dag.entryAfter ["writeBoundary"]
    (let
      # This is the new file that was created by home-manager.
      profilesIni = "${config.home.homeDirectory}/.zen/profiles.ini";
      # This is the file that (maybe) was changed imperatively and moved to the
      # backup file by home-manager.
      profilesIniOld = "${profilesIni}.${backupExtension}";
    in "${pkgs.writeScript "zen-profiles-concat" ''
      #! /usr/bin/env nix-shell
      #! nix-shell -i python3 -p python3 python3Packages.configparser

      # This script concats the new nix-generated config with existing
      # imperatively generated configs.

      import configparser
      import os
      import os.path

      # exit if not profile config existed before the nix config was
      # generated.
      if not os.path.isfile('${profilesIniOld}'):
        exit

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
    ''}");

  #TODO: everytime we restart zen, the search.json.mozlz4 link is replaced by
  # what it's pointing to. As a consequence, home-manager complains when it cannot
  # write a link to that location.
  # Find a workaround for ts or else this is unusable.

  programs.zen-browser = {
    enable = true;

    # any other options under `programs.firefox` are also supported here.

    # nah fuck this, that shit contains nothing...:
    # ~~see `man home-configuration.nix`, search: profiles.\<name\>.settings~~

    # profiles."NIX-GEN_DEV_my-internet@zen" = {
    #   id = 1;
    #   extensions = [
    #   ];
    # };

    # profiles."NIX-GEN_oq@zen" = {
    #   id = 0;
    #   isDefault = true;

    #   # https://mynixos.com/home-manager/option/programs.firefox.profiles.%3Cname%3E.search.engines
    #   search.engines = {
    #     # ...

    #     nix-packages = {
    #       name = "Nix Packages";
    #       urls = [
    #         {
    #           template = "https://search.nixos.org/packages";
    #           params = [
    #             {
    #               name = "type";
    #               value = "packages";
    #             }
    #             {
    #               name = "query";
    #               value = "{searchTerms}";
    #             }
    #           ];
    #         }
    #       ];

    #       icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    #       definedAliases = ["@np"];
    #     };

    #     nixos-wiki = {
    #       name = "NixOS Wiki";
    #       urls = [{template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";}];
    #       iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
    #       definedAliases = ["@nw"];
    #     };

    #     nix-options = {
    #       name = "Nix Options";
    #       urls = [
    #         {
    #           template = "https://search.nixos.org/options";
    #           params = [
    #             {
    #               name = "type";
    #               value = "options";
    #             }
    #             {
    #               name = "query";
    #               value = "{searchTerms}";
    #             }
    #           ];
    #         }
    #       ];

    #       icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    #       definedAliases = ["@no"];
    #     };

    #     bing.metaData.hidden = true;
    #     google.metaData.alias = "@g"; # builtin engines only support specifying one additional alias
    #   };
    # };

    # Notice: we can even extend imperatively created profiles :D
    # profiles."Default (Windows)" = {
    #   id = 2;
    #   path = "89h16xs5.Default (alpha)";

    #   # https://mynixos.com/home-manager/option/programs.firefox.profiles.%3Cname%3E.search.engines
    #   search.engines = {
    #     nix-packages = {
    #       name = "Nix Packages";
    #       urls = [
    #         {
    #           template = "https://search.nixos.org/packages";
    #           params = [
    #             {
    #               name = "query";
    #               value = "{searchTerms}";
    #             }
    #           ];
    #         }
    #       ];

    #       icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    #       definedAliases = ["@np"];
    #     };

    #     nix-options = {
    #       name = "Nix Options";
    #       urls = [
    #         {
    #           template = "https://search.nixos.org/options";
    #           params = [
    #             {
    #               name = "type";
    #               value = "options";
    #             }
    #             {
    #               name = "query";
    #               value = "{searchTerms}";
    #             }
    #           ];
    #         }
    #       ];

    #       icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    #       definedAliases = ["@no"];
    #     };

    #     nixos-wiki = {
    #       name = "NixOS Wiki";
    #       urls = [{template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";}];
    #       iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
    #       definedAliases = ["@nw"];
    #     };

    #     bing.metaData.hidden = true;
    #     google.metaData.alias = "@g"; # builtin engines only support specifying one additional alias
    #   };
    # };
  };
}
