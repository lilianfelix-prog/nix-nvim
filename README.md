# Nix Neovim

Reproducible Neovim setup: editor, plugins, LSP servers, and dev tools all
pinned and built via a single flake. No vim-plug, no `:PlugInstall`, no
manual tool installs.

## Layout

```
flake.nix    # defines plugins, LSP/dev tools, and the nvim wrapper
init.lua     # editor config, baked into the build via customRC
```

## Quick start

```bash
nix run .                 # build + launch nvim, no install
```

## Install for daily use

```bash
nix profile install .     # puts `nvim` on your $PATH
```

Verify it's actually being used (and not an old manual install shadowing it):

```bash
which nvim                # should be ~/.nix-profile/bin/nvim or /nix/store/...
```

If it points elsewhere (e.g. `/opt/nvim/bin/nvim`), remove the old install
or fix your `$PATH` order so `~/.nix-profile/bin` comes first.

## Update after editing `flake.nix` or `init.lua`

```bash
nix profile upgrade nix-nvim
```

If that fails to pick up local changes, fall back to:

```bash
nix profile remove nix-nvim
nix profile install .
```

## Update pinned dependencies (nixpkgs, plugins, etc.)

```bash
nix flake update
```

This rewrites `flake.lock`. Commit the lockfile so the build stays
reproducible across machines.

## Add a plugin

Add it to the `plugins` list in `flake.nix` (must exist in
`pkgs.vimPlugins`), then reinstall:

```bash
nix profile upgrade nix-nvim
```

## Add a CLI/LSP tool

Add the package to `extraPackages` in `flake.nix`, then reinstall the
same way. Tools land on `$PATH` alongside `nvim`.

## Add a treesitter grammar

Add the language to the `nvim-treesitter.withPlugins` list in
`flake.nix`, then add it to `ts_langs` in `init.lua` (controls which
filetypes get `vim.treesitter.start()` on open).

## Health check

```bash
nvim +checkhealth
```

Useful for catching missing parsers, broken LSP servers, or plugin
load failures after an update.

## Notes

- `init.lua` is baked into the Nix store at build time (`customRC`).
  Editing it requires a rebuild (`nix profile upgrade nix-nvim`) to take
  effect — there's no live-reload.
- LSP servers are configured via the native `vim.lsp.config` /
  `vim.lsp.enable` API (Neovim 0.11+), not `require('lspconfig')`.
- Treesitter uses the new `main`-branch API
  (`require("nvim-treesitter").setup()` + `vim.treesitter.start()`),
  not the old `nvim-treesitter.configs` module.
