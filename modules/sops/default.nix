{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.sops;
  # store the secret copies in a path managed by sops nix (/run/secrets/)
  # sops will remove the automatically after since they are not specified
  # in sops.secrets
  identitiesSecrets = "sops/all-keys.g.txt";
  identitiesFile = "/run/secrets/${identitiesSecrets}";

  identityType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Name/identifier for this identity";
        example = "main-age-key";
      };
      file = mkOption {
        type = types.path;
        description = "Path to the age identity file";
        example = "./secrets/age-key.txt";
      };
    };
  };
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.sops = with lib; {
    enable = mkEnableOption "sops";
    enableYubikeyIntegration = mkOption {
      type = types.bool;
      # default to not using the yubi dependencies when
      # we don't have any yubi keys.
      default = builtins.length cfg.yubiIdentities != 0;
      description = "Whether to enable yubi key integration.";
    };
    identities = mkOption {
      type = types.listOf identityType;
      default = [];
      description = "e.g. age key identities";
    };
    yubiIdentities = mkOption {
      type = types.listOf identityType;
      default = [];
      description = "yubi key identities";
    };
  };

  config = with lib;
    mkIf cfg.enable {
      sops = {
        defaultSopsFormat = "yaml";
        age.keyFile = identitiesFile;
      };

      environment.systemPackages = mkMerge [
        # smart card daemon
        (mkIf cfg.enableYubikeyIntegration [pkgs.pcsclite])
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
              # yubiIdentities should come after the normal age identities. this way,
              # sops will try them last and the activationScript will not fail if
              # something was not yet set up correctly for the yubi keys.
              ${strings.concatStrings (
                map appendIdentity (cfg.identities ++ (optionals cfg.enableYubikeyIntegration cfg.yubiIdentities))
              )}
              chmod 400 "${identitiesFile}"
            '';
        };

        yubiScript = {
          name = "setupYubikeyForSopsNix";
          exec = with pkgs;
          #bash
            ''
              # idea: https://github.com/Mic92/sops-nix/issues/377#issuecomment-2926579189
              PATH=$PATH:${makeBinPath [age-plugin-yubikey]}
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

        setupSecretsScript = {
          name = "setupSecrets";
          # exec is implemented by the sops-nix module.
        };
      in {
        ${identitiesScript.name} = {
          deps = [];
          text = identitiesScript.exec;
        };
        ${yubiScript.name} = mkIf cfg.enableYubikeyIntegration {
          deps = [identitiesScript.name];
          text = yubiScript.exec;
        };
        ${setupSecretsScript.name} = {
          deps = mkMerge [
            [identitiesScript.name]
            (mkIf cfg.enableYubikeyIntegration [yubiScript.name])
          ];
        };
      };

      # setting this to false fixes the problem where age-plugin-yubikey does not work, due to there
      # being either 2 or no pcscd processes running. One could probably modify the systemd service
      # with some ExecPre thingy to clean up the script above but i currently could not find success
      # while trying this.
      services.pcscd = mkIf cfg.enableYubikeyIntegration {
        enable = mkForce false;
      };
    };
}
