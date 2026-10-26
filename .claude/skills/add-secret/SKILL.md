---
name: add-secret
description: How to add a secret (API key, token, password, private key) to this Nix/home-manager dotfiles repo. Secrets live in the separate ~/.private flake, SOPS-encrypted, never in ~/.dotfiles. Use when asked to add, store, create, or rotate a secret, credential, API key, or token for a module.
---

# Add a secret

Secrets never live in `~/.dotfiles`. They live in the separate private flake at
`~/.private`, are encrypted with SOPS, and reach this flake through its
`private` input (fetched from gitea). Adding one has four steps: encrypt in
`~/.private`, wire it into a module, push `~/.private`, then bump the lock and
rebuild.

## 1. Place the plaintext under a `secrets/` path

Create the file under `~/.private` so its path contains `secrets` (that is what
`~/.private/.sops.yaml` matches to pick the encryption keys). Two common shapes:

- `home/users/oq/secrets/<name>/variables.env` — dotenv (`KEY=value`), for keys
  that become environment variables. Keep the `.env` extension: SOPS detects
  dotenv by it.
- `home/users/oq/secrets/<name>/<file>` — anything else (JSON, raw, keypair),
  for secrets a module reads directly.

## 2. Encrypt in place

```bash
cd ~/.private
sops encrypt -i home/users/oq/secrets/<name>/<file>
```

Verify it took (values turn into `ENC[AES256_GCM,data:…]`) and round-trips with
your key:

```bash
sops -d home/users/oq/secrets/<name>/<file>
```

## 3. Wire it into a module

Env-var (dotenv) secrets are registered once in
`~/.private/home/users/oq/home.nix` under `bash.secretFiles`, and get sourced
into `~/.bashrc` as exported variables:

```nix
bash.secretFiles = {
  <name> = ./secrets/<name>/variables.env;
};
```

Other secrets point a module's `sops.secrets` at the file:

```nix
sops.secrets."<name>" = {
  sopsFile = ./secrets/<name>/<file>;
  format = "binary"; # or "dotenv", "json", "yaml"
};
```

The consuming module then reads `config.sops.secrets."<name>".path`. The secret
itself and its `sopsFile` wiring stay in `~/.private`, not in the consuming
module.

## 4. Push and rebuild

The dotfiles flake reads `~/.private` from gitea, so a new secret is invisible
until it is pushed and the lock bumped.

```bash
cd ~/.private
git add -A && git commit -m "add <name> secret" && git push

cd ~/.dotfiles
nix flake lock --update-input private
git add flake.lock && git commit -m "update private input" && git push
```

Then rebuild the target that activates the module: `home switch …` for a user
secret, `dots switch …` / `nixos-rebuild` for a host secret. Open a new shell so
`bash.secretFiles` entries are sourced.

## Gotchas

- Never write the plaintext into `~/.dotfiles` or commit it — encrypt before
  `git add` in `~/.private`.
- Run `sops encrypt` from `~/.private` so its `.sops.yaml` applies.
- `home switch` (user) vs `dots switch` (host) — pick the one that activates the
  module you wired into.
