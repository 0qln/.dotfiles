{inputs, ...}:
with inputs.nixpkgs.lib; let
  modulesConf = ".config/hypr/modules.conf";
  moduleXConf = x: ".config/hypr/modules/${x}/hyprland.conf";
  moduleXScripts = x: ".config/hypr/modules/${x}/scripts";
  moduleXScriptX = x: y: "${moduleXScripts x}/${y}";
  sourceX = x: "source = ~/${moduleXConf x}";
in {
  flake.homeModules.hyprland-mods-opts = {
    pkgs,
    config,
    ...
  }: let
    cfg = config.modules.hyprland;
  in {
    options.modules.hyprland = let
      moduleType = types.submodule (
        {name, ...}: {
          options = {
            conf = mkOption {
              type = types.str;
            };
            mutable = mkOption {
              type = types.bool;
              default = false;
              description = ''
                Whether the hyprland.conf file should be mutable.
                Any edits will be removed next time this modules executes.
              '';
            };
            scripts = {
              up = mkOption {
                type = types.path;
                default = getExe (pkgs.writeShellScriptBin "${name}-up" ''
                  echo "${sourceX name}" >> "$HOME/${modulesConf}"
                  hyprctl reload
                '');
                description = ''
                  The script that enables this module.
                  If not set, a script will be generated that adds an include in the modules.conf file.
                '';
              };
              down = mkOption {
                type = types.path;
                default = getExe (pkgs.writeShellScriptBin "${name}-down" ''
                  sed -i "\|${sourceX name}|d" "$HOME/${modulesConf}"
                  hyprctl reload
                '');
                description = ''
                  The script that disables this module.
                  If not set, a script will be generated that removes the include in the modules.conf file.
                '';
              };
              toggle = mkOption {
                type = types.path;
                default = getExe (pkgs.writeShellScriptBin "${name}-toggle" ''
                  if grep -Fx "${sourceX name}" "$HOME/${modulesConf}"; then
                    ${cfg.modules.${name}.scripts.down}
                  else
                    ${cfg.modules.${name}.scripts.up}
                  fi
                '');
                description = ''
                  The script that toggles this module.
                  If not set, a script will be generated that removes or adds the include in the modules.conf file.
                '';
              };
            };
          };
        }
      );
    in {
      modules = mkOption {
        type = types.attrsOf moduleType;
        default = {};
        description = "Modules that can be enabled/disabled by their corresponding up/down scripts.";
      };
    };
  };

  flake.homeModules.hyprland-mods = {config, ...}: let
    cfg = config.modules.hyprland;
  in {
    config = let
      mods = cfg.modules;
      constMods = attrsets.filterAttrs (_: m: !m.mutable) mods;
      mutMods = attrsets.filterAttrs (_: m: m.mutable) mods;
    in {
      # use the extraConfig option, such that the module is sourced last
      # and can overwrite the default config.
      wayland.windowManager.hyprland.extraConfig =
        # hyprlang
        ''
          source = ~/${modulesConf}
        '';

      systemd.user.tmpfiles.rules = mkMerge [
        # modules.conf
        ["f /${config.home.homeDirectory}/${modulesConf} 0775 ${config.home.username} users - -"]

        # (mut) modules/<name>/hyprland.conf
        (
          attrsets.mapAttrsToList
          (name: module: "f+ /${config.home.homeDirectory}/${moduleXConf name} 0775 ${config.home.username} users - ${module.conf}")
          mutMods
        )
      ];

      # set up files
      home.file = mkMerge (lists.flatten [
        # (const) modules/<name>/hyprland.conf
        (
          attrsets.mapAttrsToList
          (name: module: {"${moduleXConf name}".text = module.conf;})
          constMods
        )

        # modules/<name>/scripts/<script>
        (
          attrsets.mapAttrsToList
          (
            name: module:
              attrsets.mapAttrsToList
              (script: bin: {${moduleXScriptX name script}.source = bin;})
              module.scripts
          )
          cfg.modules
        )
      ]);
    };
  };
}
