with import <nixpkgs> {};
  mkShell {
    name = "dotfiles";

    packages = [
      alejandra
      fd
      sops
      age-plugin-yubikey
    ];

    shellHook = ''
      alias update-sops-keys="fd -t f -H . | grep .*secrets.* | xargs sops updatekeys -y"
      dots() {
        cd ~/.dotfiles
        nix flake update home
        git add .
        nixos-rebuild $1 --flake ~/.dotfiles?submodules=1#$2 --impure --show-trace --sudo
      }
    '';
  }
