# Copilot Instructions

NixOS/Home Manager dotfiles managed as a Nix flake using [flake-parts](https://github.com/hercules-ci/flake-parts).

## Build & Deploy Commands

All commands are in `bin/` and available in the dev shell (`nix develop`).

```bash
# NixOS rebuild (local)
dots <switch|boot|test> <hostname>

# Home Manager switch
home <switch|build> <user>-<host>-<env>-<theme>

# Deploy to remote host
dots-remote <root@host> <action> <hostname>

# Deploy to lifbrasir (server)
dots-lifbrasir <switch|boot>

# List all available outputs
meta

# Format Nix files
alejandra .

# Rotate SOPS encryption keys
update-sops-keys [path-pattern]   # default pattern: '.*secrets.*'
```

Home Manager output names follow this pattern: `{user}-{host}-{env}-{theme}[-{profile}]`
- envs: `gui`, `tui`, `wsl`
- themes: from `home/themes/` and `dendrites/themes/` (e.g., `apoth-1_light`, `cogecha-2_oni`)

## Architecture

### Top-level layout

- `flake.nix` — Orchestrates everything; builds `nixosConfigurations` and `homeConfigurations` from the combination of hosts × users × envs × themes × profiles
- `hosts/` — Per-host NixOS configurations; `_common/` is shared config imported by all hosts
- `home/` — Home Manager: `users/` (per-user entry points), `themes/`, `modules/` (reusable HM modules)
- `modules/` — Reusable NixOS modules
- `dendrites/` — flake-parts modules that export both `nixosModules` and `homeModules`; each is a self-contained feature unit (e.g., `hyprland`, `waybar`, `vars`, `utils`)
- `dendrites/themes/` — Dendritic themes (flake-parts modules), preferred for new themes
- `profiles/` — Optional cross-host/user overlays (e.g., `ws`, `ws.odoo`, `python`)
- `bin/` — Shell scripts for common operations

### Dendrites

**Dendrites are the preferred pattern for all new modules and themes.** A dendrite is a directory under `dendrites/` (or `dendrites/themes/`) with a `default.nix`. They are flake-parts modules and can export:
- `flake.nixosModules.<name>` — a NixOS module
- `flake.homeModules.<name>` — a Home Manager module

An `opts.nix` alongside `default.nix` declares the module's option types and is auto-imported into every configuration via `nixosOptsModules` / `homeOptsModules`.

When writing a new NixOS module, Home Manager module, or theme, create it as a dendrite in `dendrites/` (or `dendrites/themes/` for themes) rather than adding it directly to `modules/` or `home/modules/`.

### File discovery conventions (in `utils.mods`)

- Directories starting with `_` are **ignored** (`isHidden`)
- Directories matching `*?dendrite` are flake-parts modules, not regular NixOS modules (`isDendrite`)
- `collectMods dir` returns all non-hidden, non-dendrite subdirectories — used to auto-discover hosts, users, themes, profiles

### Multiple nixpkgs inputs

| Input | Used for |
|---|---|
| `nixpkgs` | Default unstable; most packages |
| `nixpkgs-stable` | Stable packages (`pkgs-stable`) |
| `nixpkgs-server` | Server hosts |
| `nixpkgs-hot` | Packages needing the latest unstable |
| `nixpkgs-freyja-kernel` | Pinned independently for freyja's kernel fix |

### Secrets

SOPS + `age` + YubiKey. Keys are defined in `.sops.yaml`. Secret files must match path regexes in `.sops.yaml` to be encrypted with the correct key set. The `private` flake input is a separate private repo with additional secrets/config.

### `vars` dendrite

Provides typed NixOS/HM options under `config.vars` (home dirs, user UID, flake path, cloud dir, etc.). Defaults are set per-user in `home/users/<user>/home.nix` and per-host in `hosts/<host>/home-vars.nix`.

### `utils` dendrite

Provides helper functions at `config.utils` in HM modules:
- `mkIfElse`, `mkEnableOption` (with default)
- Color formatters: `fmtColor_rgbaFn`, `fmtColorWithOpacity_rgbaFn`
- `mkForceCopySecret` — systemd unit to hard-copy a SOPS secret (needed for services that can't follow symlinks)
- `mkCopy` — HM activation script helper
- `buildFirefoxXpiAddon` — build a Firefox extension from a URL

## Key Conventions

- **Formatter**: `alejandra` — run before committing
- **Module options**: Always declare options with types via `mkOption`; use `utils.mkEnableOption name default` for boolean toggles
- **Hosts with `.` in the name** (e.g., `loki.gylfi`) have their dots sanitized to `-` via `utilz.sanitizeHostName` when used as Nix attribute names
- **`lif?dendrite`**: The `?` is a glob wildcard — this directory is a dendrite (flake-parts module) for the `lif` host, loaded separately from regular host directories
- **Inline language hints**: String literals with `# bash`, `#sh`, `# nix` comments before them are used as syntax hints for the editor (not functional)
- **`dots-prepare`**: Always run before rebuild — updates the `private` flake input and stages changes with `git add`
- **`--impure`**: All rebuilds use `--impure` because of runtime-dependent values
