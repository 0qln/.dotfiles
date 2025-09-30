profile: {pkgs, ...}: {
  programs.vscode.profiles.${profile} = {
    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # {
      #   name = "odoo";
      #   publisher = "odoo";
      #   version = "1.0.1";
      #   sha256 = "sha256-a/EFuxH+LGBk+yY7mYpFmI9BBZ5GKARYAMYPm2kBxvE=";
      # }
      {
        name = "odoosnippets";
        publisher = "jigar-patel";
        version = "1.5.0";
        sha256 = "sha256-hmPDXpCS7Up9HJgZoXtutO3n6UYHhVHns+CJT0cPMhU=";
      }
    ];

    userSettings = {
      "Odoo.serverConfigPath" = "odoo.conf";
    };
  };
}
