{pkgs ? import <nixpkgs> {}, ...}:
pkgs.mkShell {
  name = "work.devops";
  shellHook = ''
    if [ -z ''${SSH_AGENT_PID+x} ]; then
      eval $(ssh-agent)
    fi
    ssh-add ~/.ssh/work.devops/rsa
  '';
}
