{config, ...}: let
  extensionPatchOverlay = final: prev: {
    vscode-extensions-patched =
      prev.lib.mapAttrs (
        publisher: exts:
          if prev.lib.isAttrs exts
          then
            prev.lib.mapAttrs (
              name: ext:
                if prev.lib.isDerivation ext
                then
                  ext.overrideAttrs (old: {
                    vscodeExtUniqueId = "${old.vscodeExtPublisher or publisher}.${old.vscodeExtName or name}";
                  })
                else ext
            )
            exts
          else exts
      )
      prev.vscode-extensions;
  };
  containerName = "vscode_fedora";
  containerHome = "${config.home.homeDirectory}/.distrobox/${containerName}";
in {
  nixpkgs.overlays = [extensionPatchOverlay];

  home.activation = {
    vscode-distrobox-config_extensions = config.utils.mkCopy {
      source = "${config.home.homeDirectory}/.vscode/extensions";
      destPath = "${containerHome}/.vscode/extensions";
      newMode = "700";
      deps = ["mutableFileGeneration" "writeBoundary"];
    };
  };
}
