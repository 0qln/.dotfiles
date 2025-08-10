{ pkgs ? import <nixpkgs> {} }:

# https://nix.dev/manual/nix/2.25/language/derivations

let
  name = "couchdb-init";
  servicePkgs = with pkgs; [ bash curl ];

  # https://raw.githubusercontent.com/vrtmrz/obsidian-livesync/main/utils/couchdb/couchdb-init.sh
  scriptContent = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/vrtmrz/obsidian-livesync/main/utils/couchdb/couchdb-init.sh";
    sha256 = "06yidz515z4f8nw4fzd1hmwr07a5vav60bw1crf1s8vmmg7pjqln";
  };

  script = (pkgs.writeScriptBin name (builtins.readFile scriptContent)).overrideAttrs(old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
in pkgs.symlinkJoin {
  inherit name;
  paths = [ script ] ++ servicePkgs;
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
