{pkgs ? import <nixpkgs> {}, ...}:
pkgs.mkShell {
  name = "dev-lifbrasir";
  shellHook = ''
    export lifbrasir="0qln.duckdns.org"

    build-lifbrasir() {
      cd ~/.dotfiles
      git add .
      nixos-rebuild --target-host $lifbrasir switch --flake ~/.dotfiles?submodules=1#lifbrasir --show-trace --sudo
    }

    eval $(ssh-agent)
    ssh-add ~/.ssh/server/id_ed25519
  '';
}
