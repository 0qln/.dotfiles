profile:
{ pkgs, ... }:
{

  programs.vscode.profiles.${profile} = {

    extensions = with pkgs.vscode-extensions; [
      arrterian.nix-env-selector
      mkhl.direnv
    ];
  };

}
