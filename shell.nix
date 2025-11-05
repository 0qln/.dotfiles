with import <nixpkgs> {}; let
  lifbrasir = (import ./hosts/lifbrasir/fqdns.nix).primary;

  packages = [
    alejandra
    fd
    sops
    age-plugin-yubikey
  ];

  mapFuncs = transform: lib.concatStringsSep "\n" (lib.mapAttrsToList transform funcs);
  addToPath = derivation: "PATH_add '${builtins.dirOf (lib.getExe derivation)}'";
  funcToDerivation = name: body:
    writeShellApplication {
      inherit name;
      runtimeInputs = packages;
      text = ''
        ${mapFuncs funcToBash}
        ${body}
      '';
    };
  funcToBash = name: body: ''
    ${name}() {
      ${body}
    }
  '';

  funcs = {
    update-sops-keys =
      # bash
      ''
        fd -Ht f . | grep '.*secrets.*' | xargs sops updatekeys -y
      '';

    dots-prepare =
      # bash
      ''
        ssh-ensure "$HOME/.ssh/id_ed25519"
        cd ~/.dotfiles
        nix flake update private
        git add .
      '';

    dots =
      # bash
      ''
        action="$1"
        output="$2"

        dots-prepare
        nixos-rebuild "$action" --flake "$HOME/.dotfiles?submodules=1#$output" --impure --show-trace --sudo
      '';

    dots-remote =
      # bash
      ''
        host="$1"
        key="$2"
        action="$3"
        output="$4"

        dots-prepare
        nixos-rebuild --target-host "$host" "$action" --flake ~/.dotfiles?submodules=1#"$output" --impure --show-trace --sudo
      '';

    dots-lifbrasir =
      # bash
      ''
        action="$1"
        key="$HOME/.ssh/server/id_ed25519"

        ssh-ensure "$key"
        dots-remote "root@${lifbrasir}" "$key" "$action" "lifbrasir"
      '';

    ssh-ensure =
      # bash
      ''
        set +e

        key="$1"

        # list ssh keys
        ssh-add -l > /dev/null 2>&1
        case $? in
          0)
            # echo agent exist and has keys
            if ! ssh-add -l | grep "$(ssh-keygen -lf "$key")" > /dev/null; then
              # agent does not have the identity "$key"
              ssh-add "$key" > /dev/null
            fi
            ;;
          1)
            # agent exists but does not have any keys
            ssh-add "$key" > /dev/null
            ;;
          2)
            # no agent exists
            eval "$(ssh-agent -s)"
            ssh-add "$key" > /dev/null
            ;;
        esac
      '';
  };
in
  mkShell {
    name = "dotfiles";
    inherit packages;

    shellHook =
      # bash
      ''
        export lifbrasir=${lifbrasir}

        ${mapFuncs (name: body: (addToPath (funcToDerivation name body)))}
      '';
  }
