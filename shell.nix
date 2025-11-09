with import <nixpkgs> {};
with import ./utils; let
  vars = (import-module ./vars {}).vars;
  lifbrasir = vars.hosts.lifbrasir.fqdns.primary.dn;

  packages = [
    alejandra
    fd
    sops
    age-plugin-yubikey
  ];

  mapFuncs = transform: (lib.mapAttrsToList transform funcs);

  funcToDerivation = name: body:
    writeShellApplication {
      inherit name;
      runtimeInputs = packages;
      checkPhase = ["disable=SC2154"];
      text = ''
        ${body}
      '';
    };

  var-ensure = key: val:
  # bash
  ''[ -z "''$${key}" ] && export ${key}="${val}"'';

  funcs = {
    echo-test =
      # bash
      ''
        echo 'test'
      '';

    update-sops-keys =
      # bash
      ''
        fd -Ht f . | grep '.*secrets.*' | xargs sops updatekeys -y
      '';

    dots-prepare =
      # bash
      ''
        ssh-ensure "$1"
        cd ~/.dotfiles
        nix flake update private
        git add .
      '';

    dots =
      # bash
      ''
        action="$1"
        output="$2"

        dots-prepare "$git_key"
        nixos-rebuild "$action" --flake "$HOME/.dotfiles?submodules=1#$output" --impure --show-trace --sudo
      '';

    dots-remote =
      # bash
      ''
        host="$1"
        key="$2"
        action="$3"
        output="$4"

        ssh-ensure "$key"
        dots-prepare "$git_key"
        nixos-rebuild --target-host "$host" "$action" --flake ~/.dotfiles?submodules=1#"$output" --impure --show-trace --sudo
      '';

    dots-lifbrasir =
      # bash
      ''
        action="$1"

        dots-remote "root@$lifbrasir" "$lifbrasir_key" "$action" "lifbrasir"
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
    packages = packages ++ (mapFuncs funcToDerivation);

    shellHook =
      # bash
      ''
        ${var-ensure "lifbrasir" lifbrasir}
        ${var-ensure "lifbrasir_key" "$HOME/.ssh/server/id_ed25519"}
        ${var-ensure "git_key" "$HOME/.ssh/id_ed25519"}
      '';
  }
