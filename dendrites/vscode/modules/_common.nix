profile: {...}: {
  imports = [
    (import ./git.nix profile)
    (import ./clanker.nix profile)
    (import ./neovim.nix profile)
    (import ./keybinds.nix profile)
    (import ./nix-shells.nix profile)
    (import ./ssh-remote.nix profile)
    (import ./format-files.nix profile)
  ];
}
