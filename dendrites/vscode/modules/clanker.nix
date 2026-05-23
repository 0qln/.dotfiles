profile: {
  pkgs,
  lib,
  ...
}:
with lib; {
  programs.vscode.profiles = {
    ${profile} = {
      extensions = mkMerge [
        (pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "vscode-ai-foundry";
            publisher = "teamsdevapp";
            version = "0.6.0";
            sha256 = "sha256-n3MMMEaVWqUGebGPeF+rq6AnWBkQ76DHjlD5KGalhRU=";
          }
          # installed manually because it wants to fuck around with directory permissions of the extension dir...
          {
            name = "vscode-copilotstudio";
            publisher = "ms-copilotstudio";
            version = "1.2.90";
            sha256 = "sha256-CdVpkEeqlOfAV6uHDUpGPm7eA+Fqpvz5HynvmV7xhVI=";
          }
        ])
        (with pkgs.vscode-extensions-patched; [
          github.copilot-chat
        ])
      ];
      userSettings = {
        "chat.mcp.gallery.enabled" = true;
      };
    };
  };
}
