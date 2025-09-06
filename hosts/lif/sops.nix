{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/oq/age-yubikey-identity-ca0b293d.txt";
  };

  environment.systemPackages = with pkgs; [
    toybox
    pcsclite
  ];

  # https://github.com/Mic92/sops-nix/issues/377#issuecomment-2926579189
  system.activationScripts = let
    setupScriptName = "setupYubikeyForSopsNix";
  in {
    ${setupScriptName}.text = ''
      PATH=$PATH:${lib.makeBinPath [pkgs.age-plugin-yubikey]}
      ${pkgs.runtimeShell} -c "mkdir -p /var/lib/pcsc && ln -sfn ${pkgs.ccid}/pcsc/drivers /var/lib/pcsc/drivers"
      ${pkgs.toybox}/bin/pgrep pcscd > /dev/null && ${pkgs.toybox}/bin/pkill pcscd
      ${pkgs.pcsclite}/bin/pcscd
    '';
    setupSecrets.deps = [setupScriptName];
  };
}
