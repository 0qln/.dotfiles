{
  pkgs ? import <nixpkgs> { },
  ...
}:
pkgs.mkShell {
  name = "work.devops";
  shellHook = ''
    ssh-add ~/.ssh/work.devops/rsa
  '';
}
