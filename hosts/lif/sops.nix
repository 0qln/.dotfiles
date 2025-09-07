{
  pkgs,
  inputs,
  lib,
  ...
}: let
  mkSopsDependency = name: script: {
    ${name}.text = script;
    setupSecrets.deps = [name];
  };

  mkAgeIdentity = name: rec {
    # use a combined key file instead of `path = "${root}/${name}"`,
    # this way, sops can automatically fallback to use the backup key.
    file = ../../yubis/${name};
    root = "/root/.config/sops/age/";
    path = "${root}/yubi-combined";
    name = name;
  };

  ageIdentities = {
    yubi-1 = mkAgeIdentity "yubi-1/age-yubikey-identity-ca0b293d.txt";
    yubi-2 = mkAgeIdentity "yubi-2/age-yubikey-identity-7432b76e.txt";
  };

  flatten = xs: builtins.foldl' (acc: s: acc // s) {} xs;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFormat = "yaml";
    age.keyFile = ageIdentities.yubi-1.path;
  };

  environment.systemPackages = with pkgs; [
    pcsclite
  ];

  # https://github.com/NixOS/nixpkgs/blob/0d00f23f023b7215b3f1035adb5247c8ec180dbc/nixos/modules/system/activation/activation-script.nix
  system.activationScripts =
    # Copy the age identity to somewhere outside of the nix store since, sops
    # does not allow paths to the nix store.
    (flatten (lib.attrsets.mapAttrsToList
      (name: identity:
        mkSopsDependency "createIdentityCopy_${name}" (with identity; ''
          mkdir -p "$(dirname "${path}")"
          cat "${file}" >> "${path}"
        ''))
      ageIdentities))
    //
    # https://github.com/Mic92/sops-nix/issues/377#issuecomment-2926579189
    (mkSopsDependency "setupYubikeyForSopsNix" (with pkgs; ''

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
        for i in {1..7}
        do
         echo "Loop spin:" $i
          sleep 1
        done
        echo "done waiting"

        echo starting pcscd...
        ${pcsclite}/bin/pcscd

        echo "pcscd: $(${toybox}/bin/pgrep pcscd)"
      fi
    ''));

  # setting this to false fixes the problem where age-plugin-yubikey does not work, due to there being either
  # 2 or no pcscd processes running. One could probably modify the systemd service with some
  # ExecPre thingy to clean up the script above but i currently could not find success while
  # trying this.
  services.pcscd = {
    enable = lib.mkForce false;
  };
}
