# CLAUDE.md

Nix flake configuring NixOS machines and home-manager users (personal dotfiles
of `0qln`).

## Layout

- `dendrites/` — the dendritic pattern: self-contained feature modules
  (`default.nix`, optional `opts.nix`), auto-collected by the flake. Preferred
  for new modules. `home/modules/` and `modules/` still hold not-yet-migrated
  modules.
- `hosts/` — per-machine NixOS configs (`lif`, `lifbrasir`, `freyja`, `gylfi`,
  `loki`, …), with `_common` shared.
- `home/` — home-manager users, themes, and unmigrated home modules.
- `profiles/` — home-manager profiles.
- `bin/` — helper scripts (`home`, `dots`, `dots-push`, `dots-update`, …), on
  PATH inside the devshell (`direnv use flake`).

## Secrets

Secrets never live in this repo. They live in the separate private flake
`~/.private` (SOPS-encrypted), pulled in through the `private` input from gitea.
To add one, invoke the `add-secret` skill.

## Rebuild

- `home switch <output>` — home-manager for a user.
- `dots switch <host>` — `nixos-rebuild` for a machine.
- `dots-update` — `nix flake update` + commit + push.
