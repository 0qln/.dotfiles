with import <nixpkgs> {};
with import ./utils; let
  inherit (import-module ./vars {}) vars;
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
        action="$2"
        output="$3"

        dots-prepare
        nixos-rebuild --target-host "$host" "$action" --flake ~/.dotfiles?submodules=1#"$output" --impure --show-trace --sudo
      '';

    dots-lifbrasir =
      # bash
      ''
        action="$1"

        dots-remote "root@$lifbrasir" "$action" "lifbrasir"
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
      '';
  }
