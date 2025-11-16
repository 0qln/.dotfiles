# credits: https://gist.github.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  # Path logic from:
  # https://github.com/nix-community/home-manager/blob/3876cc613ac3983078964ffb5a0c01d00028139e/modules/programs/vscode.nix
  cfg = config.programs.vscode;

  vscodePname = cfg.package.pname;

  configDir =
    {
      "vscode" = "Code";
      "vscode-insiders" = "Code - Insiders";
      "vscodium" = "VSCodium";
    }.${
      vscodePname
    };

  userDir =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "Library/Application Support/${configDir}/User"
    else "${config.xdg.configHome}/${configDir}/User";

  settingsFile = "settings.json";
  tasksFile = "tasks.json";
  keybindingsFile = "keybindings.json";
  snippetDir = "snippets";

  configFiles = path: cfg: [
    (optional (cfg.userTasks != {}) "${path}/${tasksFile}")
    (optional (cfg.userSettings != {}) "${path}/${settingsFile}")
    (optional (cfg.keybindings != {}) "${path}/${keybindingsFile}")
    (optional (cfg.globalSnippets != {}) "${path}/${snippetDir}/global.code-snippets")
    (mapAttrsToList (lang: _: "${path}/${snippetDir}/${lang}.json") cfg.languageSnippets)
  ];

  pathsToMakeWritable = flatten (
    attrsets.mapAttrsToList (
      profileName: profileCfg:
        configFiles (
          if profileName == "default"
          then userDir
          else "${userDir}/profiles/${profileName}"
        )
        profileCfg
    )
    cfg.profiles
  );
in {
  config = mkIf config.modules.vscode.enable {
    home.file = genAttrs pathsToMakeWritable (_: {
      force = true;
      mutable = true;
    });
  };
}
