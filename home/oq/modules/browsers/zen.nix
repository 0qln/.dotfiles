{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  programs.zen-browser = {
    enable = true;

    # any other options under `programs.firefox` are also supported here.

    # nah fuck this, that shit contains nothing...:
    # ~~see `man home-configuration.nix`, search: profiles.\<name\>.settings~~

    # https://mynixos.com/home-manager/option/programs.firefox.profiles.%3Cname%3E.search.engines
    # profiles."oq@lif".search.engines = {
    #   # ...

    #   nix-packages = {
    #     name = "Nix Packages";
    #     urls = [
    #       {
    #         template = "https://search.nixos.org/packages";
    #         params = [
    #           {
    #             name = "type";
    #             value = "packages";
    #           }
    #           {
    #             name = "query";
    #             value = "{searchTerms}";
    #           }
    #         ];
    #       }
    #     ];

    #     icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    #     definedAliases = [ "@np" ];
    #   };

    #   nixos-wiki = {
    #     name = "NixOS Wiki";
    #     urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
    #     iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
    #     definedAliases = [ "@nw" ];
    #   };

    #   bing.metaData.hidden = true;
    #   google.metaData.alias = "@g"; # builtin engines only support specifying one additional alias
    # };
  };
}
