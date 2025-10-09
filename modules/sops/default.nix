{
  pkgs,
  inputs,
  lib,
  ...
}: let
  mkIdentity = name: file: {
    inherit name;
    inherit file;
  };

  mkYubiIdentity = name: (mkIdentity name ../../yubis/${name});

  yubiIdentities = {
    yubi-1 = mkYubiIdentity "yubi-1/age-yubikey-identity-ca0b293d.txt";
    yubi-2 = mkYubiIdentity "yubi-2/age-yubikey-identity-7432b76e.txt";
  };

  ageIdentities = {
    age-keys = mkIdentity "oq.age" "/home/oq/.config/sops/age/keys.txt";
  };

  ageIdentitiesSecrets = "sops/age/all-keys.g.txt";
  ageIdentitiesFile = "/run/secrets/${ageIdentitiesSecrets}";
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFormat = "yaml";
    # use a combined key file.
    # this way, sops can automatically fallback to use the backup key.
    age.keyFile = ageIdentitiesFile;
  };

  environment.systemPackages = with pkgs; [
    pcsclite
  ];

  # https://github.com/NixOS/nixpkgs/blob/0d00f23f023b7215b3f1035adb5247c8ec180dbc/nixos/modules/system/activation/activation-script.nix
  system.activationScripts = let
    # Copy the age identities to somewhere outside of the nix store, since sops
    # does not allow paths to the nix store.
    identitiesScript = let
      identities = lib.strings.concatStrings (
        lib.attrsets.mapAttrsToList (
          name: identity:
            with identity; ''
              # === ${name} ===
              ${builtins.readFile file}
            ''
        ) (ageIdentities // yubiIdentities)
      );
    in {
      name = "setupIdentitiesFile";
      exec = ''
        mkdir -p "$(dirname "${ageIdentitiesFile}")"
        cat > "${ageIdentitiesFile}" << EOF
        ${identities}
        EOF
      '';
    };

    yubiScript = {
      name = "setupYubikeyForSopsNix";
      exec = with pkgs; ''
        # idea: https://github.com/Mic92/sops-nix/issues/377#issuecomment-2926579189
        PATH=$PATH:${lib.makeBinPath [age-plugin-yubikey]}
        ${runtimeShell} -c "mkdir -p /var/lib/pcsc && ln -sfn ${ccid}/pcsc/drivers /var/lib/pcsc/drivers"

        echo "pcscd: $(${toybox}/bin/pgrep pcscd)"

        if ! ${toybox}/bin/pgrep pcscd > /dev/null ; then

          # pcscd has some dependencies that sometimes aren't yet loaded when
          # we start up pcscd, so we will wait a bit ...
          # https://pcsclite.apdu.fr/

          # TODO: find a better solution, maybe just copy the fucking systemd
          # service module of nixpkgs in herer idkkkkkk

          echo "waiting for dependencies..."
          for i in {1..10}
          do
           echo "Loop spin:" $i
            sleep 1
          done
          echo "done waiting"

          echo starting pcscd...
          ${pcsclite}/bin/pcscd

          echo "pcscd: $(${toybox}/bin/pgrep pcscd)"
        fi
      '';
    };
  in {
    ${identitiesScript.name} = {
      deps = [];
      text = identitiesScript.exec;
    };
    ${yubiScript.name} = {
      deps = [identitiesScript.name];
      text = yubiScript.exec;
    };
    ${"setupSecrets"} = {
      deps = [yubiScript.name];
    };
  };

  # setting this to false fixes the problem where age-plugin-yubikey does not work, due to there being either
  # 2 or no pcscd processes running. One could probably modify the systemd service with some
  # ExecPre thingy to clean up the script above but i currently could not find success while
  # trying this.
  services.pcscd = {
    enable = lib.mkForce false;
  };
}
