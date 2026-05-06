{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
with lib; let
  flakeInputsToUpdate = lists.subtractLists ["private" "self"] (builtins.attrNames inputs);
  inputsStr = concatStringsSep " " flakeInputsToUpdate;
  flake = config.vars.flake.dir;
in {
  format = "󰅢  {}";
  interval = 300;
  exec = let
    updateScript = pkgs.writeShellScript "check-nix-updates" ''
      if [[ -d ${flake} ]]; then
        cd ${flake} || return

        if [[ -z "$(git status --porcelain)" ]]; then

          # not using --reference-lock-file "$in" --output-lock-file "$out" bc then nix doesn't tell us about what was updated :shrug:
          updates=$(nix flake update \
            ${inputsStr} 2>&1 \
            | grep -c "Updated input"
          )

          git reset --hard > /dev/null 2>&1

          echo "$updates"
          exit 0
        fi
      fi

      echo "?"
    '';
  in "${updateScript}";
  exec-if = "test -d ${flake}";
  on-click = "${config.vars.terminal} sh -c 'cd ${flake} && nix flake update --commit-lock-file ${inputsStr} && echo \"Flake updated!\"; echo \"Press enter to exit\"; read'";
  on-click-right = "${config.vars.terminal} sh -c 'cd ${flake} && sudo nixos-rebuild switch --flake .; echo \"Press enter to exit\"; read'"; #TODO: do we need to provide the host?
  signal = 8;
  tooltip = true;
  tooltip-format = "{} Nix updates available\nLeft-click: Update flake\nRight-click: Rebuild system";
}
