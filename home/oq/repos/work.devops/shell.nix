{
  pkgs ? import <nixpkgs> { },
  ...
}:
pkgs.mkShell {
  name = "work.devops";
  shellHook = ''
    eval $(ssh-agent)
    ssh-add ~/.ssh/work.devops/rsa
  '';
}
