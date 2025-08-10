{ name, pkgs, servicePkgs ? [] }:

# Documentation
# https://ertt.ca/nix/shell-scripts/
# https://gist.github.com/CMCDragonkai/9b65cbb1989913555c203f4fa9c23374

# TODO: refactor?
# https://discourse.nixos.org/t/packaging-a-bash-script-issues/20224
# https://nixos.org/manual/nixpkgs/stable/#trivial-builder-writeShellApplication
# https://github.com/NixOS/nixpkgs/blob/a667cde977180c174c917f429cc1e9cb6296a81c/pkgs/build-support/trivial-builders.nix#L274

let
  script = (pkgs.writeScriptBin name (builtins.readFile ./todoist-backup.sh)).overrideAttrs(old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
in pkgs.symlinkJoin {
  inherit name;
  paths = [ script ] ++ servicePkgs;
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
