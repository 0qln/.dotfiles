{
  pkgs ? import <nixpkgs> { },
  ...
}:
pkgs.mkShell {
  name = "dev-lifbrasir";
  shellHook = ''
    alias build-lifbrasir=" cd ~/.dotfiles && git add . && sudo nixos-rebuild --target-host lifbrasir switch --flake ~/.dotfiles?submodules=1#lifbrasir "
    eval $(ssh-agent)
    ssh-add ~/.ssh/server/id_ed25519
  '';
}
