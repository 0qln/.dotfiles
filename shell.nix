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

      # check if the ssh-agent wasn't spawned when .envrc was executed by direnv.
      # if not, that means the user entered the shell manually and we have to create
      # the ssh-agent here. (not sure this is correct lol.)
      if [ -z ''${SSH_AGENT_PID+x} ]; then
        eval $(ssh-agent)
      fi

      # add the ssh credentials
      ssh-add ~/.ssh/id_ed25519
    '';
  }
