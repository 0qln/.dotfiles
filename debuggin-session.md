# HANDOFF — Hyprland hyprlang→lua migration: fixing broken binds

**Context date:** 2026-08-03. Host: `freyja`. Hyprland `0.56.0` (0.55+ deprecated
hyprlang in favor of lua). home-manager locked rev `bf9ce9fec78f95f374e8dd3b503863a3ec128ebe`.

This session already migrated the whole Hyprland config to `configType = "lua"`
(see checkpoints 001/002 + the 10 done todos). The user is now reporting that
**some binds don't work at runtime** even though the config builds. Two concrete
reports:

1. **hyprshot binds don't work** (screenshot keybinds).
2. **Two-step submap binds don't work**: `SUPER + W` then a number to go to a
   workspace does nothing. (The `resize` submap `SUPER + R` + arrows is the same
   mechanism and almost certainly equally broken.)

> ⚠️ **In the session where these bugs were reported, the `bash` tool was DOWN**
> ("Failed to start bash process"), so I could NOT build, run `alejandra`, inspect
> the generated `~/.config/hypr/hyprland.lua`, or `git diff`. The user is starting a
> **new session with working bash**. **FIRST THING TO DO THERE:** read the actual
> generated lua and reproduce, don't just trust this doc.

---

## 0. First commands to run in the new (working-bash) session

```bash
cd /home/oq/.dotfiles
# See what home-manager actually generated:
cat ~/.config/hypr/hyprland.lua        # <-- THE most important artifact
# Build the freyja config to catch eval errors (pick the right home config name):
meta                                    # lists home configuration names
home build oq-freyja-<env>-<theme>      # e.g. oq-freyja-gui-<theme>
alejandra .                             # format
# Live-debug a bind after switching:
hyprctl binds | less                    # shows every registered bind + submap
hyprctl dispatch 'hl.dsp.submap("reset")'   # escape a stuck submap
# Check submap actually entered:
hyprctl submap                          # or watch `hyprctl activewindow`
```

Also clean up the stray blanked scratch file if still present:
```bash
rm -f dendrites/hyprland/input.nix.new
```

---

## 1. How the lua renderer works (home-manager, this rev) — VERIFIED from source

Source: `modules/services/window-managers/hyprland/{default.nix,lib.nix}` at the
locked rev. Key facts:

- `settings.X = v`  →  `hl.X(<renderLuaArgs v>)`. If `v` is a **list**, one
  `hl.X(...)` per element.
- `{ _args = [a b c]; }`  →  `hl.X(a, b, c)` (args joined by `, `, each via `toLua`).
- `{ _var = "SUPER"; name?; }`  →  `local <name|attr> = SUPER`.
- `lib.generators.mkLuaInline "raw"`  →  raw lua, emitted verbatim.
- **Ordering:** setting names are sorted alphabetically, BUT names matching
  `importantPrefixes` (default `["$" "bezier" "curve" "name" "output"]`) are hoisted
  to the top. `curve` is hoisted (so curves render before animations — good).
- **Final file assembly order** (from `luaConfig` in `lib.nix`):
  1. header comment
  2. `renderPluginLoad`
  3. `renderLuaFiles` (require() of extraLuaFiles)
  4. `renderSettings`  ← all your `settings.*` (config/bind/window_rule/...)
  5. `renderSubmaps`   ← **home-manager's NATIVE `submaps` option** (see §3)
  6. `renderStartHook` (systemd `hl.on("hyprland.start", ...)`)
  7. `renderShutdownHook`
  8. `renderSection "extraConfig" config.extraConfig`  ← **appended DEAD LAST**

### CRUCIAL discovery: there are TWO different "submaps"
- `wayland.windowManager.hyprland.submaps` — **home-manager NATIVE option**. Renders
  proper `hl.define_submap(name, onDispatch?, function() ... end)` for lua. Only
  attribute-set bind entries render in lua (string entries are hyprlang-only and are
  silently skipped in lua mode; and vice-versa).
- `config.modules.hyprland.input.submaps` — **the repo's OWN custom option**
  (declared in `dendrites/hyprland/opts.nix`). This one hand-writes raw lua text into
  `wayland.windowManager.hyprland.extraConfig` inside `dendrites/hyprland/input.nix`.

The current migration uses the **custom** one (raw lua in extraConfig). That raw lua
is what's suspected of being wrong. **Strongly consider switching to the native
`submaps` option instead** — it's purpose-built, less error-prone, and gets the
`assertion` that no submap is named `reset`. See §5 for the recommended refactor.

---

## 2. hyprshot bug — file `dendrites/hyprshot/default.nix`

Current state (post-migration):
```nix
bind = [
  (bind "PRINT" (exec "${hyprshotCmd} -m output"))
  (bind "SUPER + PRINT" (exec "${hyprshotCmd} -m window"))
  (bind "SHIFT + SUPER + PRINT" (exec "${hyprshotCmd} -m region"))
  # These 3 were `&`-chords in hyprlang, translated best-effort to `+`:
  (bind "SHIFT_R + SUPER_L + S" (exec "${hyprshotCmd} -m output"))
  (bind "SHIFT_R + SUPER_L + SHIFT_L + S" (exec "${hyprshotCmd} -m window"))
  (bind "SHIFT_R + SUPER_L + SHIFT_L + ALT_L + S" (exec "${hyprshotCmd} -m region"))
];
```

**Original hyprlang** (from git `533e33ee`, before migration commit `a9f032e`):
```
bind = [
  ", PRINT, exec, ${hyprshotCmd} -m output"
  "SUPER, PRINT, exec, ${hyprshotCmd} -m window"
  "SHIFT SUPER, PRINT, exec, ${hyprshotCmd} -m region"
];
binds = [   # note: `binds` (plural) = the `bind[l]`/global variant list in this repo's opts
  "SHIFT_R & SUPER_L, S, exec, ${hyprshotCmd} -m output"
  "SHIFT_R & SUPER_L & SHIFT_L, S, exec, ${hyprshotCmd} -m window"
  "SHIFT_R & SUPER_L & SHIFT_L & ALT_L, S, exec, ${hyprshotCmd} -m region"
];
```

### Hypotheses to check IN ORDER
1. **`hyprshotCmd` has a trailing space and a `-z` then args.** It's
   `HYPRSHOT_DIR="..." <exe> -z ` then `-m output` is appended → `... -z  -m output`.
   Double space is harmless. But verify `-z` (freeze) + `-m` ordering is valid for the
   installed hyprshot version. Run the exact command in a terminal:
   `HYPRSHOT_DIR="$dir" hyprshot -z  -m output` and see if it errors. This is the
   **most likely** real cause if even `PRINT` alone doesn't screenshot.
2. **`PRINT` keysym name.** The correct xkb keysym is `Print` (or `Print`/`Sys_Req`).
   In hyprlang `PRINT` worked case-insensitively; in **lua the keysym after the mod is
   passed to xkb and may be case-sensitive** (see the wiki `unbind` note: keys are
   case-sensitive). Try `"Print"` instead of `"PRINT"`. Confirm with `wev` what the
   key reports. THIS is a strong candidate.
3. **The `&`-chord translation is almost certainly wrong.** In hyprlang, `A & B, KEY`
   meant a *multi-key held chord* (the `bind`-with-`&` "held keys" feature). There is
   **no documented lua equivalent** — the lua `keys` string uses `+` to join a
   modmask + single key, where the mods must be real modifiers (SHIFT/SUPER/ALT/CTRL),
   NOT arbitrary keysyms like `SHIFT_R`/`SUPER_L`. So `"SHIFT_R + SUPER_L + S"` is
   likely rejected or never matches. Options:
   - Ask the user if they still need the "imposter keyboard" chords at all (they were
     a workaround for a laptop without a Print key). If not, **delete those 3 binds**.
   - If they DO need it: the closest lua approach is a normal modmask, e.g.
     `"SHIFT + SUPER + S"` (uses generic SHIFT+SUPER, not the L/R-specific syms) — but
     that collides with nothing? verify. Confirm via `hyprctl binds` that it registers.
   - Verify keysym names against xkb (`SUPER_L` is `Super_L` in xkb; case matters).
4. Confirm the bind registered at all: `hyprctl binds | grep -A2 -i print`.

### Recommended concrete fix (pending user confirmation on the chords)
- Change `PRINT` → `Print` in all three PRINT binds.
- For the 3 chord binds: prefer replacing with plain modmask binds
  (`"SHIFT + SUPER + S"` etc.) OR drop them. Do NOT keep `SHIFT_R + SUPER_L + ...`.
- Sanity-check the `hyprshotCmd` string actually runs.

---

## 3. Two-step submap bug (`SUPER + W` → number) — the big one

### Where it's defined
- **User submaps**: `home/users/oq/home.nix` lines ~168–204:
  ```nix
  input.submaps = {
    "workspace" = {
      key = "W";
      binds = map (w: { flags=""; keys=", ${toString w}"; dispatch="workspace ${toString w}"; reset=true; }) (lists.range 0 9);
    };
    "resize" = {
      key = "R";
      binds = [ {flags="e"; keys=", right"; dispatch="resizeactive 10 0";} ... ];
    };
  };
  ```
- **steam_bongocat ALSO defines** `input.submaps.workspace` in
  `dendrites/steam_bongocat/hyprland.nix` (~line 14): a single `keys=", b"` bind with
  no `key`. Because `submaps` is `attrsOf submodule`, these **merge** into one
  `workspace` submap (key `W`, binds = user's 10 ++ steam's 1). Not necessarily a bug
  but be aware when reading generated lua.

### The generator: `dendrites/hyprland/input.nix` lines ~148–204
It writes raw lua into `wayland.windowManager.hyprland.extraConfig`:
```nix
mkSubmap = name: { key ? null, binds }:
  concatStringsSep "\n" (
    (optional (key != null) ''hl.bind(${toLua "${mainMod} + ${key}"}, hl.dsp.submap(${toLua name}))'')
    ++ [''hl.define_submap(${toLua name}, function()'']
    ++ (map (b: "  " + mkSubmapBind b) binds)
    ++ [ ''  hl.bind("escape", hl.dsp.submap("reset"))''
         ''  hl.bind("catchall", hl.dsp.submap("reset"))''
         ''end)'' ]
  );
```
and `mkSubmapBind` turns each `{keys,dispatch,reset,flags}` into (for reset=true):
```lua
hl.bind("<KEY>", function()
  hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch workspace <N>"))
  hl.dispatch(hl.dsp.submap("reset"))
end)
```
(non-reset → `hl.bind("<KEY>", hl.dsp.exec_cmd("hyprctl dispatch <disp>")<flags>)`).

### WHY IT'S PROBABLY BROKEN — candidate root causes (check against real lua!)
1. **`extraConfig` is appended DEAD LAST in hyprland.lua (after the start hook).**
   That position itself is fine for defining submaps. BUT note the `SUPER + W` ENTER
   bind lives in extraConfig while all other binds live in `renderSettings`. If
   ANYTHING above it in the file is malformed lua, the whole file fails to load and
   Hyprland silently falls back — but then NOTHING would work, not just submaps. Since
   only *some* binds fail, the file probably loads. Still: eyeball the file.
2. **The indirection `hl.dsp.exec_cmd("hyprctl dispatch workspace N")` is fragile and
   wrong-ish.** Instead of a native dispatcher it shells out to `hyprctl`. Problems:
   - `workspace 0` is INVALID in Hyprland (numerical workspaces must be ≥1). The user's
     `range 0 9` includes `0` → `SUPER+W` then `0` can never work. (Workspace 10 was
     the "real" one historically; the `0` binding was probably always meaningless or
     mapped differently in hyprlang. CONFIRM what the user actually wants: likely keys
     1-9 + 0→workspace 10.)
   - Racy: the submap `reset` dispatch fires immediately while `hyprctl` runs async.
   - It's just ugly. **Replace with the proper dispatcher** `hl.dsp.focus({ workspace = N })`
     (that's what the main config already uses for `ALT+SHIFT+n`, see input.nix ~line 102).
3. **`convertKeys` + `strings.trim`**: `mkSubmapBind` calls `convertKeys bnd.keys` which
   uses `strings.trim`. If the config BUILDS, `strings.trim` exists — fine. For
   `keys=", 0"` it yields key `"0"` (no mods). Good. Verify the emitted key string in
   the lua is exactly `"0"`, `"1"`, ... and `"right"`/`"left"` for resize.
4. **Submap key case:** `hl.define_submap("workspace", ...)` and the reset uses
   `"escape"`/`"catchall"`. Those are fine. But double-check the ENTER key `SUPER + W`
   didn't get shadowed by another `SUPER + W` bind (grep the lua).

### STRONGLY RECOMMENDED FIX: switch to home-manager's NATIVE `submaps`
Rather than patching the raw-lua generator, migrate the custom
`modules.hyprland.input.submaps` to emit the native option
`wayland.windowManager.hyprland.submaps`, which renders correct
`hl.define_submap(...)`. Shape (verified from default.nix example + lib.nix renderer):

```nix
wayland.windowManager.hyprland.submaps.workspace = {
  onDispatch = "reset";           # auto-return to default after any dispatch
  settings.bind = [
    # each entry is an `{ _args = [...] }` attrset (string entries are IGNORED in lua!)
    { _args = [ "1" (mkLuaInline ''hl.dsp.focus({ workspace = 1 })'') ]; }
    { _args = [ "2" (mkLuaInline ''hl.dsp.focus({ workspace = 2 })'') ]; }
    # ... 3..9, and 0 -> workspace 10 (NOT 0, which is invalid)
    { _args = [ "escape" (mkLuaInline ''hl.dsp.submap("reset")'') ]; }
    { _args = [ "catchall" (mkLuaInline ''hl.dsp.submap("reset")'') ]; }
  ];
};
# And the ENTER bind stays a normal bind in settings.bind:
# (bind "${mainMod} + W" ''hl.dsp.submap("workspace")'')
```
Notes on native submaps:
- `onDispatch = "reset"` means you DON'T need per-bind reset lambdas — Hyprland auto-
  resets after any dispatch. This directly replaces the old `reset = true` behavior and
  removes the racy exec_cmd/reset lambda.
- With `onDispatch="reset"` you may still want the explicit `escape`/`catchall` resets
  for keys that DON'T dispatch (so the user can bail).
- Home-manager asserts no submap may be named `reset` (it's reserved) — fine here.
- The renderer only emits attrset (`_args`/mkLuaInline) entries in lua and skips plain
  strings, so keep everything as `_args`.
- The ENTER bind (`hl.dsp.submap("workspace")`) is a REGULAR bind — put it in
  `settings.bind`, not in the submap.

This requires:
- Adding a helper (or inline) that maps the repo's `{keys,dispatch,reset,flags}` shape
  → native `settings.bind` `_args` entries, translating dispatch strings to real
  `hl.dsp.*` calls (`workspace N`→`focus({workspace=N})`, `resizeactive X Y`→
  `window.resize({ x = X, y = Y, relative = true })`, `workspace <steam_id>`→
  `focus({ workspace = <id> })`).
- OR: change the source-of-truth options (opts.nix / home.nix / steam) to already speak
  the native shape. Discuss scope with the user — the minimal fix is to keep the custom
  option but have `input.nix` translate it into the NATIVE `submaps` option instead of
  raw `extraConfig`.

### Minimal fix (if user wants smallest change, keep raw-lua generator)
In `dendrites/hyprland/input.nix` `mkSubmapBind`, stop shelling out to hyprctl. Map
dispatch strings to native dispatchers:
- `"workspace N"`      → `hl.dsp.focus({ workspace = N })`   (N≥1; map user's 0→10)
- `"resizeactive X Y"` → `hl.dsp.window.resize({ x = X, y = Y, relative = true })`
- generic fallback     → keep `hl.dsp.exec_cmd("hyprctl dispatch ...")` but ONLY as last resort
Then verify `SUPER+W`→`1..9` works and fix the `0` case.

---

## 4. Dispatcher / bind / submap lua API cheat-sheet (VERIFIED from 0.56 wiki)

- **Bind:** `hl.bind(keys, dispatcher [, { flags }])`. Keys: `"SUPER + SHIFT + Q"`,
  bare `"XF86AudioMute"`, mouse `"SUPER + mouse:272"` (+ `{mouse=true}`), wheel
  `"SUPER + mouse_down"`, keycode `"SUPER + code:28"`. **Keys are case-sensitive**
  (`Tab` ≠ `TAB`). Modifier-only bind needs `r`/`release` flag + target modmask.
- **Multi-action bind:** pass a lua `function()` that calls `hl.dispatch(hl.dsp.X())`
  multiple times. (In a bind's 2nd arg you pass `hl.dsp.X()` directly; INSIDE a
  function you wrap with `hl.dispatch(...)` or call `hl.exec_cmd(...)`.)
- **Flags:** `locked, release, click, drag, long_press, repeating, non_consuming,`
  `auto_consuming, mouse, transparent, ignore_mods, description, dont_inhibit,`
  `submap_universal, device, allow_input_capture`. (repeating replaces hyprlang `e`;
  locked replaces `l`; release replaces `r`.)
- **Submap:** `hl.bind("MOD + K", hl.dsp.submap("name"))` to enter;
  `hl.define_submap("name" [, "onReset"] , function() ... end)`. Auto-close variant:
  `hl.define_submap("A", "B", function() ... end)` → after any dispatch, go to submap B
  (or `"reset"`). Must provide `hl.bind("escape", hl.dsp.submap("reset"))` and/or
  `hl.bind("catchall", hl.dsp.submap("reset"))` to escape. `submap_universal` flag =
  active in all submaps.
- **Key dispatchers** (`hl.dsp.`): `exec_cmd(cmd[, rules])`, `exec_raw(cmd)`,
  `focus({direction|monitor|workspace|window|last|urgent_or_last})`, `submap(name)`,
  `layout(msg)`, `pass`, `send_shortcut`, `global`, `exit`, `no_op`.
- **Window** (`hl.dsp.window.`): `close, kill, float({action?}), fullscreen,`
  `fullscreen_state({internal,client,action?}), pseudo, move({direction|workspace|`
  `monitor|x,y}), center, drag(), resize()/resize({x,y,relative?}), tag({tag}),`
  `swap({direction})`, ...
- **Workspace** (`hl.dsp.workspace.`): `toggle_special(name), move, rename, change_id`.
- **fullscreen_state values:** internal/client: `-1`=current, `0`=none, `1`=maximized,
  `2`=fullscreen. (steam_bongocat uses `fullscreen_state = "1"` as a WINDOW RULE, not a
  dispatcher — that's a different code path; see §6.)
- **Workspace selectors:** numeric MUST be 1..2147483647. **`0` and negatives are NOT
  allowed.** relative `+1/-1`, `e+1` (incl. empty), `special:name`, `name:Foo`, etc.
- **exec with rules:** `hl.dsp.exec_cmd("kitty", { float = true, move = {0,0} })`.

---

## 5. Uncertain spots still open from the migration (re-verify on device)

1. **hyprshot chords** (§2) — almost certainly broken; needs user decision.
2. **hyprshot `Print` vs `PRINT`** — try `Print`.
3. **steam_bongocat `window_rule` `fullscreen_state = "1"`** (dendrites/steam_bongocat/
   hyprland.nix line 38) — verify the window-rule EFFECT name + value format in lua.
   Wiki window-rules page (content/Configuring/Basics/Window-Rules.md) has the lua
   `hl.window_rule({...})` effect list — CHECK the exact key (`fullscreen_state`) and
   whether value is a string `"1"` or a table.
4. **steam_bongocat `workspace` submap merge** with user's `workspace` submap (§3).
5. **`workspace 0`** in the user's `range 0 9` — invalid; decide mapping (likely 0→10).
6. **`strings.trim`** — exists if build succeeds; not a runtime concern.
7. **rotate-screen toggle module** — intentionally a no-op (mods.nix `extraConfig=""`).
   User previously said IGNORE it. Don't touch unless asked.

---

## 6. Key files (with line anchors as of this session)

| File | What / lines |
|---|---|
| `dendrites/hyprland/default.nix` | core settings; `configType="lua"` (~88), monitor/workspace_rule/config/curve/animation/window_rule |
| `dendrites/hyprland/input.nix` | **input + all binds + submap raw-lua generator**. config (~19-44), settings.bind (~46-145), extraConfig submap gen (~148-204). `mkSubmapBind` (~173), `convertKeys` (~151). Uses `u = config.utils.hyprLua`. |
| `dendrites/hyprland/opts.nix` | custom `modules.hyprland.input.submaps` option (~16-42): `{key?; binds=[{flags,keys,dispatch,reset}|str];}`; `mainMod` (~43). |
| `dendrites/hyprland/mods.nix` | toggle-module system; `extraConfig=""` no-op (~95). Leave alone. |
| `dendrites/utils/default.nix` | `hyprLua` helpers (~139-150): `inline=mkLuaInline`, `toLua`, `exec cmd`, `bind keys disp`, `bindF keys disp flags`. `fmtMonitor_lua` (~128-135). |
| `dendrites/hyprshot/default.nix` | **BUG §2**. bind list (~25-38). `hyprshotCmd` (~22). |
| `dendrites/steam_bongocat/hyprland.nix` | workspace submap (~14-22), window_rule w/ `fullscreen_state="1"` (~38). |
| `home/users/oq/home.nix` | **user submaps source of truth** (~168-204): workspace(key W, range 0 9), resize(key R). |
| `dendrites/hyprlock/default.nix`, `dendrites/hyprpaper/default.nix` | migrated exec-once→`hl.on`; bind→lua. |

Generated output to inspect at runtime: `~/.config/hypr/hyprland.lua`.
Home-manager module source (this rev):
`nix-community/home-manager@bf9ce9fec78f95f374e8dd3b503863a3ec128ebe`
→ `modules/services/window-managers/hyprland/{default.nix,lib.nix}`.
Example lua: `hyprwm/Hyprland@main:example/hyprland.lua`.
Wiki (0.56 lua): `hyprwm/hyprland-wiki@main:content/Configuring/Basics/{Binds,Dispatchers,Window-Rules,Workspace-Rules}.md`.

---

## 7. Recommended plan for the working-bash session

1. `cat ~/.config/hypr/hyprland.lua` — READ IT. Confirm which of §2/§3 hypotheses is real.
2. `hyprctl binds` — see if hyprshot + `SUPER+W` binds/submap even registered.
3. **hyprshot:** run the raw command manually; fix `PRINT`→`Print` if needed; resolve
   the `&`-chord binds with the user (drop or convert to plain modmask). Rebuild, test.
4. **submaps:** replace the `hyprctl dispatch` indirection with native `hl.dsp.*`
   dispatchers; fix `workspace 0`; ideally migrate to the native `submaps` option with
   `onDispatch = "reset"`. Rebuild, test `SUPER+W`→1..9 and `SUPER+R`→arrows.
5. `alejandra .`, then `home switch oq-freyja-<env>-<theme>`.
6. `rm -f dendrites/hyprland/input.nix.new` if present.
7. Re-verify §5 uncertain spots.

**Ask the user before big refactors:** (a) do they still want the imposter-keyboard
hyprshot chords? (b) for `SUPER+W`+`0`, should `0` map to workspace 10?
