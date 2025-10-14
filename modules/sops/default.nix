{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.sops;
  identitiesSecrets = "sops/all-keys.g.txt";
  identitiesFile = "/root/${identitiesSecrets}";
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.sops = with lib; {
    enable = mkEnableOption "sops";
    identities = mkOption {
      type = types.listOf types.attrs; # TODO: specify that we need name and file.
      default = [];
      description = "";
    };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFormat = "yaml";
      # use a combined key file.
      # this way, sops can automatically fallback to use the backup key.
      age.keyFile = identitiesFile;
    };

    environment.systemPackages = with pkgs; [
      pcsclite
    ];

    # https://github.com/NixOS/nixpkgs/blob/0d00f23f023b7215b3f1035adb5247c8ec180dbc/nixos/modules/system/activation/activation-script.nix
    system.activationScripts = let
      # Copy the age identities to somewhere outside of the nix store, since sops
      # does not allow paths to the nix store.
      identitiesScript = {
        name = "setupIdentitiesFile";
        exec = let
          appendIdentity = i:
          #bash
          ''
            echo "# === ${i.name} ===" >> "${identitiesFile}"
            cat ${i.file} >> "${identitiesFile}"
          '';
        in
          #bash
          ''
            mkdir -p "$(dirname "${identitiesFile}")"
            echo "" > "${identitiesFile}"
            ${lib.strings.concatStrings (map appendIdentity cfg.identities)}
          '';
      };

      yubiScript = {
        name = "setupYubikeyForSopsNix";
        exec = with pkgs;
        #bash
          ''
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
  };
}
