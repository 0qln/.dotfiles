{inputs, ...}:
with inputs.nixpkgs.lib; let
  modulesConf = ".config/hypr/modules.lua";
  moduleXConf = x: ".config/hypr/modules/${x}/hyprland.lua";
  moduleXScripts = x: ".config/hypr/modules/${x}/scripts";
  moduleXScriptX = x: y: "${moduleXScripts x}/${y}";
  # A lua `dofile(...)` line that loads a module's config on (re)load.
  # The path is resolved at runtime so the same literal string is written,
  # matched and removed by the up/down/toggle scripts below.
  sourceX = x: ''dofile(os.getenv("HOME") .. "/${moduleXConf x}")'';
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
                Whether the hyprland.lua file should be mutable.
                Any edits will be removed next time this modules executes.
              '';
            };
            scripts = {
              up = mkOption {
                type = types.path;
                default = getExe (pkgs.writeShellScriptBin "${name}-up" ''
                  echo '${sourceX name}' >> "$HOME/${modulesConf}"
                  hyprctl reload
                '');
                description = ''
                  The script that enables this module.
                  If not set, a script will be generated that adds a `dofile` include in the modules.lua file.
                '';
              };
              down = mkOption {
                type = types.path;
                default = getExe (pkgs.writeShellScriptBin "${name}-down" ''
                  tmp="$(mktemp)"
                  grep -vFx '${sourceX name}' "$HOME/${modulesConf}" > "$tmp" || true
                  mv "$tmp" "$HOME/${modulesConf}"
                  hyprctl reload
                '');
                description = ''
                  The script that disables this module.
                  If not set, a script will be generated that removes the `dofile` include in the modules.lua file.
                '';
              };
              toggle = mkOption {
                type = types.path;
                default = getExe (pkgs.writeShellScriptBin "${name}-toggle" ''
                  if grep -qFx '${sourceX name}' "$HOME/${modulesConf}"; then
                    ${cfg.modules.${name}.scripts.down}
                  else
                    ${cfg.modules.${name}.scripts.up}
                  fi
                '');
                description = ''
                  The script that toggles this module.
                  If not set, a script will be generated that removes or adds the `dofile` include in the modules.lua file.
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
      # `configType = "lua"` has no hyprlang `source =`, so we `dofile` the
      # modules.lua at the very end of hyprland.lua (extraConfig is appended
      # dead last). Each up/down/toggle script edits modules.lua and runs
      # `hyprctl reload`, which re-executes hyprland.lua and thus re-loads (or
      # drops) the module. The load is guarded so a missing file or a broken
      # module doesn't take down the whole config.
      wayland.windowManager.hyprland.extraConfig = ''
        do
          local __hm_modules = os.getenv("HOME") .. "/${modulesConf}"
          local __hm_f = io.open(__hm_modules, "r")
          if __hm_f ~= nil then
            __hm_f:close()
            local __hm_ok, __hm_err = pcall(dofile, __hm_modules)
            if not __hm_ok then
              print("hyprland: failed to load " .. __hm_modules .. ": " .. tostring(__hm_err))
            end
          end
        end
      '';

      systemd.user.tmpfiles.rules = mkMerge [
        # modules.lua
        ["f /${config.home.homeDirectory}/${modulesConf} 0775 ${config.home.username} users - -"]

        # (mut) modules/<name>/hyprland.lua
        (
          attrsets.mapAttrsToList
          (name: module: "f+ /${config.home.homeDirectory}/${moduleXConf name} 0775 ${config.home.username} users - ${module.conf}")
          mutMods
        )
      ];

      # set up files
      home.file = mkMerge (lists.flatten [
        # (const) modules/<name>/hyprland.lua
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
