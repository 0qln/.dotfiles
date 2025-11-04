with import <nixpkgs> {};
  mkShell {
    name = "dotfiles";

    packages = [
      alejandra
      fd
      sops
      age-plugin-yubikey
    ];

    shellHook =
      # bash
      ''
        export lifbrasir="${(import ./hosts/lifbrasir/fqdns.nix).primary}"

        update-sops-keys() {
          fd -Ht f . | grep .*secrets.* | xargs sops updatekeys -y
        }

        dots-prepare() {
          ssh-ensure "$HOME/.ssh/id_ed25519"
          cd ~/.dotfiles
          nix flake update private
          git add .
        }

        dots() {
          action="$1"
          output="$2"

          dots-prepare
          nixos-rebuild "$action" --flake ~/.dotfiles?submodules=1#$output --impure --show-trace --sudo
        }

        dots-remote() {
          host="$1"
          key="$2"
          action="$3"
          output="$4"

          dots-prepare
          nixos-rebuild --target-host "$host" "$action" --flake ~/.dotfiles?submodules=1#$output --impure --show-trace --sudo
        }

        dots-lifbrasir() {
          action="$1"
          key="$HOME/.ssh/server/id_ed25519"

          ssh-ensure "$key"
          dots-remote "root@$lifbrasir" "$key" "$action" "lifbrasir"
        }

        ssh-ensure() {
          key=$1

          # list ssh keys
          ssh-add -l > /dev/null 2>&1
          case $? in
            0)
              # ssh-agent exist and has keys
              if ! ssh-add -l | grep "$(ssh-keygen -lf $key)"; then
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
              eval $(ssh-agent -s)
              ssh-add $key
              ;;
          esac
        }
      '';
  }
