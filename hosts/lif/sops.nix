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

  mkSopsDependant = name: script: {
    ${name} = {
      text = script;
      deps = ["setupSecrets"];
    };
  };

  ageIdentity = rec {
    name = "age-yubikey-identity-ca0b293d.txt";
    file = ../../yubis/${name};
    path = "/root/.config/sops/age/${name}";
  };
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFormat = "yaml";
    age.keyFile = ageIdentity.path;
  };

  environment.systemPackages = with pkgs; [
    pcsclite
  ];

  system.activationScripts =
    # Copy the age identity to somewhere outside of the nix store since, sops
    # does not allow paths to the nix store.
    mkSopsDependency "createIdentityCopy" (with ageIdentity; ''
      DEST="$(dirname ${path})"
      mkdir -p "$DEST"
      cp -f ${file} "$DEST/${name}"
    '')
    # ;
    //
    # https://github.com/Mic92/sops-nix/issues/377#issuecomment-2926579189
    (mkSopsDependency "setupYubikeyForSopsNix" (with pkgs; ''

      # pcscd has some dependencies that sometimes aren't yet loaded when
      # we start up pcscd, so we will wait a bit ...
      # https://pcsclite.apdu.fr/

      # TODO: find a better solution, maybe just copy the fucking systemd
      # service module of nixpkgs in herer idkkkkkk

      echo "waiting [x]sec for dependencies..."
      ${pkgs.systemd}/bin/udevadm settle --timeout=30
      for i in {1..5}
      do
       echo "Loop spin:" $i
        # echo $(ykman list)
        sleep 1
      done

      echo "done waiting"

      PATH=$PATH:${lib.makeBinPath [age-plugin-yubikey]}
      ${runtimeShell} -c "mkdir -p /var/lib/pcsc && ln -sfn ${ccid}/pcsc/drivers /var/lib/pcsc/drivers"

      echo "pcscd: $(${toybox}/bin/pgrep pcscd)"
      if ! ${toybox}/bin/pgrep pcscd > /dev/null ; then
        echo starting...
        ${pcsclite}/bin/pcscd
        echo "pcscd: $(${toybox}/bin/pgrep pcscd)"
      fi

      echo "$(${toybox}/bin/which ${systemd}/bin/systemctl)"
      echo "$(${toybox}/bin/whoami)"

      # this does not work, since systemd apparently only starts after the activation script...
      # ${systemd}/bin/systemctl daemon-reload
      # while ! ${systemd}/bin/systemctl start pcscd;
      # do
      #   echo "systemctl start pcscd failed: $?"
      #   sleep 1
      # done
      # echo "pcscd: $(${toybox}/bin/pgrep pcscd)"
      # ${toybox}/bin/pkill pcscd
      # echo "pcscd: $(${toybox}/bin/pgrep pcscd)"
      # ${pcsclite}/bin/pcscd
      # echo "pcscd: $(${toybox}/bin/pgrep pcscd)"

      # FUCK<"$(${systemd}/bin/systemctl start pcscd.service)"
      # echo $FUCK
    ''));

  # setting this to false fixes the problem where age-plugin-yubikey does not work, due to there being either
  # 2 or no pcscd processes running. One could probably modify the systemd service with some
  # ExecPre thingy to clean up the script above but i currently could not find success while
  # trying this.
  services.pcscd = {
    enable = lib.mkForce false;
    # wantedBy = [""];
  };

  # systemd.user.services.nixos-activation = {
  #   after = ["pcscd.socket"];
  #   requires = ["pcscd.socket"];
  #   unitConfig = {
  #     # If pcscd is a system service, you might need to reference it differently
  #     # User services can't directly require system services
  #     After = "pcscd.socket";
  #     Requires = "pcscd.socket";
  #   };
  # };

  # https://github.com/NixOS/nixpkgs/blob/0d00f23f023b7215b3f1035adb5247c8ec180dbc/nixos/modules/system/activation/activation-script.nix
}
