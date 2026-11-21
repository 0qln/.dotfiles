---
name: add-font
description: How to add a new font to this Nix/home-manager dotfiles repo. Packages the font as its own flake repo (github:0qln/<name>), threads it through dendrites/fonts into a theme, and notes the waybar full-restart gotcha. Use when asked to add, install, package, or wire in a font for a theme, waybar, hyprlock, kitty, or terminal.
---

# Add a font

Fonts do not live in `~/.dotfiles`. Each font is its own tiny flake repo at
`github:0qln/<Name>` (checked out under `~/repos/`, naming varies in case), which
exposes an overlay adding one package named `<name>` (lowercase).
`dendrites/fonts/default.nix` is the central registry that turns that package
into a `modules.fonts.<name>.enable` option; themes opt in and then reference the
font by its **internal family name**, not the file or package name.

## 1. Find the font's family name

The `font-family` / `font_family` value in CSS/waybar/hyprlock is the font's
internal name. Read it from the extracted file:

```bash
fc-scan --format "%{family}\n" "Font File.ttf"        # e.g. "Sigokae Demo" (space included)
fc-scan --format "%{family}|%{style}|%{postscriptname}\n" "Font File.otf"
```

If the zip ships the same face as both `.otf` and `.ttf`, keep both files in
`src/` but install only the `.otf` (step 2) so fontconfig doesn't register the
family twice.

## 2. Create the font flake repo

Mirror the existing font flakes (`angel-wish`, `old-london`, `Ruritania`,
`Kingjola`, `sigokae`). Layout:

```
flake.nix      # overlays.default adds package <name>; packages."x86_64-linux".default
default.nix    # stdenvNoCC derivation installing src/*.otf -> $out/share/fonts/opentype
src/<Font>.otf
src/<Font>.ttf  # optional — kept in src but not installed when it duplicates the otf
.gitignore     # "result"
```

`flake.nix`:

```nix
{
  description = "A very basic flake";
  inputs = { nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; };
  outputs = {nixpkgs, ...}: let
    pkgs = import nixpkgs {system = "x86_64-linux";};
  in {
    overlays.default = _: prev: {
      <name> = import ./default.nix {pkgs = prev;};
    };
    packages."x86_64-linux".default = import ./default.nix {inherit pkgs;};
  };
}
```

`default.nix`:

```nix
{pkgs ? import <nixpkgs> {}, ...}:
pkgs.stdenvNoCC.mkDerivation {
  pname = "<Name> font";
  version = "v1.0.0";
  src = ./.;
  installPhase = ''
    mkdir -p "$out/share/fonts/opentype"
    cp src/*.otf "$out/share/fonts/opentype/"
  '';
}
```

Then lock, verify, and publish (goes to the `master` branch):

```bash
cd ~/repos/<Name>
git init && git add -A && git commit -m "add <Name> font flake"
nix flake lock
nix build --no-link --print-out-paths .#packages.x86_64-linux.default   # sanity check
git add flake.lock && git commit -m "lock nixpkgs"
gh repo create 0qln/<Name> --public --source=. --push   # public vs private: see gotchas
```

## 3. Thread it into the dotfiles

Three files.

`flake.nix` — add the input alongside the other fonts (`old-london`, `sigokae`, …):

```nix
<name> = {
  url = "github:0qln/<Name>";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

`dendrites/fonts/default.nix` — three additions in the `flake.homeModules.fonts`
block (the `nixosModules.fonts` overlay list above it is a separate, commented
path — home fonts don't touch it):

```nix
# options.modules.fonts
<name>.enable = mkEnableOption "<name>";

# config.nixpkgs.overlays
inputs.<name>.overlays.default

# config.home.packages
++ (optionals cfg.<name>.enable [<name>])
```

Bump the lock:

```bash
nix flake lock --update-input <name>
```

## 4. Enable + reference it in a theme

In the theme's `default.nix` (`dendrites/themes/<theme>/default.nix`), enable it
under `modules.fonts`:

```nix
modules.fonts = {
  <name>.enable = mkDefault true;   # comment the role, e.g. "waybar clock"
};
```

Then use the *family name* from step 1 where a decorative font is wanted. In
waybar that slot is the `#clock` block in `programs.waybar.style` and the clock's
`calendar.format`:

```css
#clock { font-family: "<Family Name>"; }
```

```nix
"months" = "<span font_family='<Family Name>' size='large'>{}</span>";
```

Reference: `foggy-forest-1` puts "Old London" on its clock — that's the same
decorative-font slot `sigokae` fills on the `wlop-1_chinese-festival` theme.

## 5. Rebuild and verify

```bash
dots switch <host>                    # NixOS + home-manager
fc-list | grep -i <name>              # font registered
fc-match "<Family Name>"              # resolves to the font, not a fallback
```

## Gotchas

- **Waybar needs a full restart, not a reload.** `systemctl --user reload
  waybar.service` sends `SIGUSR2`, which re-reads `style.css` — but a waybar that
  started before the font was installed keeps its stale fontconfig/Pango index
  and won't render the new font. Run `systemctl --user restart waybar.service`
  after installing a font. Same for any long-running GTK app.
- **Family name ≠ file/package name.** The repo/input/package is `<name>`
  (lowercase); the CSS uses the internal family name from `fc-scan`, which may
  have a space ("Sigokae Demo").
- **Install one format.** When a zip ships the same face as `.otf` and `.ttf`,
  install only the `.otf`, or fontconfig sees the family twice.
- **License.** Decorative/demo fonts are often "free for personal use only";
  pushing them to a *public* `github:0qln/<Name>` repo redistributes them.
  Confirm public vs private with the user first (a private repo needs a
  `git+https://github.com/0qln/<Name>.git` input URL instead of `github:0qln/<Name>`).
- **Glyph coverage.** A decorative font may lack the glyphs the target uses
  (e.g. clock digits/colon). Check `fc-query --format '%{charset}\n' <file>`
  before assuming a missing font is a wiring bug.
