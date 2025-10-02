pkgs: {
  name = "Nix Packages";
  urls = [
    {
      template = "https://search.nixos.org/packages";
      params = [
        {
          name = "query";
          value = "{searchTerms}";
        }
      ];
    }
  ];

  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
  definedAliases = ["@np"];
}
