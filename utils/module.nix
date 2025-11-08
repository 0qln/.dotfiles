{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.utils;
in {
  options.utils = mkOption {
    type = types.attrs;
    description = "Utility functions.";
  };

  config.utils = {
    sanitizeHostName = name: builtins.replaceStrings ["."] ["-"] (lib.strings.sanitizeDerivationName name);

    mkIfElse = condition: yes: no:
      mkMerge [
        (mkIf condition yes)
        (mkIf (!condition) no)
      ];

    mods = {
      # Wether a file is hidden or not.
      isHidden = file: builtins.match "_.*" file != null;

      # Wether a file type is 'directory'.
      isDir = type: type == "directory";

      # If the module of filename/filetype is a module.
      isMod = f: t: (cfg.mods.isDir t) && !(cfg.mods.isHidden f);

      # Collect all modules in a directory.
      collectMods = xDir: builtins.attrNames (lib.attrsets.filterAttrs cfg.mods.isMod (builtins.readDir xDir));

      # Idekanymore.
      eachX = with lib;
        xs: fns:
          map (i: i.fn i.x) (
            attrsets.cartesianProduct {
              x = xs;
              fn = lists.flatten [fns];
            }
          );
    };
  };
}
