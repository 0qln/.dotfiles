{
  pkgs,
  ...
}:
{
  # docs:
  # https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module
  # https://nix-community.github.io/home-manager/options.xhtml#opt-home.activation
  # https://github.com/nix-community/home-manager/blob/master/modules/home-environment.nix
  # https://home-manager-options.extranix.com/
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./bash
    ./btop
    ./direnv
    ./git
    ./lf
    ./nixvim
    ./sops
    ./ssh
    ./tools
  ];

  home.packages = with pkgs; [
    # TODO: this belongs in a dev-shell (?)
    gcc
    rustup
    rustc
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  home.stateVersion = "25.05"; # Did you read the comment?
}
