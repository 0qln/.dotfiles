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
        action="$1"
        output="$2"
        cd ~/.dotfiles
        nix flake update private
        git add .
        nixos-rebuild "$action" --flake ~/.dotfiles?submodules=1#$output --impure --show-trace --sudo
      }

      dots-remote() {
        host="$1"
        key="$2"
        action="$3"
        output="$4"

        ssh-add -l > /dev/null 2>&1
        case $? in
          0)
            # ssh-agent exist and has keys
            if ! ssh-add -l | grep "$(ssh-keygen -lf ~/.ssh/server/id_ed25519)"; then
              # ssh-agent does not have the $key
              ssh-add $key
            fi
            ;;
          1)
            # ssh-agent exists but does not have a key
            ssh-add $key
            ;;
          2)
            # ssh-agent does not exist
            eval $(ssh-agent)
            ssh-add $key
            ;;
        esac

        cd ~/.dotfiles
        nix flake update private
        git add .
        nixos-rebuild --target-host "$host" "$action" --flake ~/.dotfiles?submodules=1#$output --impure --show-trace --sudo
      }

      export lifbrasir="0qln.duckdns.org"
      dots-lifbrasir() {
        action="$1"
        dots-remote \
          "root@$lifbrasir" \
          "$HOME/.ssh/server/id_ed25519" \
          "$action" \
          "lifbrasir"
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
