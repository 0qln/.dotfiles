profile: {...}: {
  imports = [
    (import ../../modules/misc.nix profile)
    (import ../../modules/editor.nix profile)
    (import ../../icons/vsicons.nix profile)
    (import ../../colors/beeverfeever.kanagawa-vscode.nix profile)
    (import ./editor.nix profile)
  ];
}
