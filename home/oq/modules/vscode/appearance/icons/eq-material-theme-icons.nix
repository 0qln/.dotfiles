profile:
{ pkgs, ... }:
{
  programs.vscode.profiles.${profile} = {
    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "vsc-material-theme-icons";
        publisher = "equinusocio";
        version = "3.9.0";
        sha256 = "sha256-pg0m6yg1i35bHLwfBCa/7GTj2670tLMo4gc5Jtv6Ztg=";
      }
    ];

    userSettings = {
      "workbench.iconTheme" = "eq-material-theme-icons";
    };
  };
}
