# Claude Instructions — nvim-config

This repo contains the user's canonical Neovim configuration. When invoked on a new or existing machine, **do not blindly copy `init.vim`**. Instead follow the workflow below.

---

## Your job on a new machine

### Step 1 — Analyse the current state

Before touching anything, gather facts:

```bash
nvim --version                                          # must be 0.12+
ls ~/.config/nvim/                                      # what config files exist?
cat ~/.config/nvim/init.vim 2>/dev/null                 # read existing config if present
cat ~/.config/nvim/init.lua 2>/dev/null                 # or lua-based config
ls ~/.local/share/nvim/plugged/ 2>/dev/null             # vim-plug installed plugins
ls ~/.local/share/nvim/site/autoload/plug.vim 2>/dev/null  # is vim-plug installed?
cargo --version 2>/dev/null                             # needed by blink.cmp
node --version 2>/dev/null
dotnet --version 2>/dev/null
rg --version 2>/dev/null
fd --version 2>/dev/null
tree-sitter --version 2>/dev/null
```

Also read `init.vim` from this repo (the canonical target).

### Step 2 — Compare and identify gaps

Produce a clear diff summary:

- Which plugins from `init.vim` are already installed?
- Which are missing?
- Does the existing config conflict with anything in `init.vim` (different plugin manager, different leader key, duplicate mappings)?
- Which system dependencies (cargo, node, dotnet, rg, fd, tree-sitter CLI) are missing?

### Step 3 — Make a plan, confirm with user

Write out a numbered action plan before doing anything. Include:

1. System packages to install via brew (or apt on Linux)
2. Whether to replace or merge the existing config
3. Plugin manager setup if missing
4. Post-install steps (`:PlugInstall`, `:MasonInstall roslyn`, `:TSUpdate`)

**Ask the user to confirm the plan before executing.**

### Step 4 — Execute

Follow the confirmed plan step by step. After each major step verify it succeeded before continuing.

---

## Key facts about this config

- **Plugin manager**: vim-plug (not lazy.nvim)
- **Leader key**: `;` — set as the very first line of `init.vim` (`let mapleader = ";"`)
- **Neovim minimum**: 0.12 (nvim-treesitter v2 API requires it)
- **Config file**: single `~/.config/nvim/init.vim` — all plugin declarations and Lua config live here

### Plugins installed

| Plugin | Purpose |
|---|---|
| `nvim-lua/plenary.nvim` | Lua utility lib |
| `nvim-tree/nvim-web-devicons` | Filetype icons |
| `MunifTanjim/nui.nvim` | UI primitives (neo-tree dep) |
| `ellisonleao/gruvbox.nvim` | Colorscheme |
| `nvim-treesitter/nvim-treesitter` | Syntax parsing (v2 API) |
| `neovim/nvim-lspconfig` | LSP server configs |
| `williamboman/mason.nvim` | LSP / tool installer |
| `williamboman/mason-lspconfig.nvim` | Mason ↔ lspconfig bridge |
| `saghen/blink.lib` | Shared lib required by blink.cmp v2 |
| `saghen/blink.cmp` | Completion engine (Rust-built, needs cargo 1.85+) |
| `seblyng/roslyn.nvim` | C# LSP (uses Roslyn, same as VS Code) |
| `nvim-telescope/telescope.nvim` | Fuzzy finder (pinned 0.1.8) |
| `ibhagwan/fzf-lua` | Faster fuzzy finder (primary) |
| `nvim-neo-tree/neo-tree.nvim` | File tree (replaces NERDTree) |
| `nvim-neotest/neotest` + adapters | Test runner; Python / Vitest / dotnet adapters |
| `stevearc/overseer.nvim` | Task runner (compiler.nvim dep) |
| `Zeioth/compiler.nvim` | Build / compile commands |
| `MeanderingProgrammer/render-markdown.nvim` | In-buffer markdown rendering |
| `iamcco/markdown-preview.nvim` | Browser markdown preview |
| `lewis6991/gitsigns.nvim` | Git gutter + hunk operations |
| `sindrets/diffview.nvim` | Side-by-side diffs |
| `NeogitOrg/neogit` | Magit-style git UI |

---

## Known gotchas — read before installing

### Rust / blink.cmp v2

`blink.cmp` v2 requires Rust **1.85+** (uses `edition2024`). `brew install rust` typically provides 1.95+ (fine).

**Two breaking changes in v2 vs v1 — both must be in `init.vim`:**

1. **Sibling plugin `saghen/blink.lib` is required.** Without it nvim throws:
   ```
   E5108: Lua: blink.cmp v2 requires blink.lib ("saghen/blink.lib")
   ```
   Add `Plug 'saghen/blink.lib'` BEFORE the `Plug 'saghen/blink.cmp'` line.

2. **The build hook must call `require('blink.cmp').build()`**, not `cargo build --release`.
   Using `cargo build` produces a startup warning ("V2 uses a new build/download system…").
   The lazy.nvim docs show `build = function() require('blink.cmp').build():wait(60000) end`.
   For **vim-plug**, do NOT inline the lua call as a string — vim-plug's parser breaks on
   embedded quotes / colons (`E115: Missing quote`, `E116: Invalid arguments for function plug#`).
   Use a vim function instead:
   ```vim
   function! BuildBlinkCmp(info)
     lua require('blink.cmp').build():wait(60000)
   endfunction
   Plug 'saghen/blink.lib'
   Plug 'saghen/blink.cmp', { 'do': function('BuildBlinkCmp') }
   ```
   To trigger the build manually after editing the Plug line:
   ```
   :call BuildBlinkCmp({})
   ```
   (`:PlugUpdate blink.cmp` may report "no plugin to update" if vim hasn't re-sourced
   `init.vim` since the edit — the direct `:call` always works.)

### tree-sitter CLI
`brew install tree-sitter` (0.26.8+) installs only the **C library** — no CLI binary.
nvim-treesitter v2 needs the CLI to compile parsers. Install via cargo:
```bash
cargo install tree-sitter-cli
```

After `cargo install`, the binary lands in `~/.cargo/bin/`. If `which tree-sitter`
prints "not found", `~/.cargo/bin` is missing from PATH. Add to `~/.zshrc`:
```sh
export PATH="$HOME/.cargo/bin:$PATH"
```
nvim inherits PATH from its parent shell, so `:TSUpdate` will silently fail to
compile parsers if tree-sitter isn't reachable.

### Roslyn (C# LSP)
`roslyn` is **not** in the default Mason registry. The `mason.setup()` in `init.vim` already adds the custom registry:
```lua
"github:Crashdummyy/mason-registry"
```
After `:PlugInstall`, run inside nvim:
```
:MasonInstall roslyn
```

### nvim-treesitter v2 API
The old `require('nvim-treesitter.configs').setup()` module no longer exists. The config uses:
```lua
require('nvim-treesitter').setup({})
require('nvim-treesitter').install({ 'python', 'typescript', ... })
```

### lspconfig deprecation (nvim 0.11+)
`require('lspconfig').X.setup()` is deprecated. The config uses:
```lua
vim.lsp.config('*', { on_attach = ..., capabilities = ... })
```
mason-lspconfig v2 then auto-calls `vim.lsp.enable()` for all installed servers.

### vim-plug `do` hook may not run
If blink.cmp or markdown-preview fail after `:PlugInstall`, their build hooks may not have fired.
Build blink.cmp manually (see above). For markdown-preview:
```bash
cd ~/.local/share/nvim/plugged/markdown-preview.nvim/app && npx --yes yarn install
```

### vim-plug `do` value parsing pitfalls
vim-plug's parser is fussy about complex `do` values. Symptoms: `E115: Missing quote`,
`E116: Invalid arguments for function plug#`. The whole `Plug` line errors out, the
plugin is never registered, and downstream `require('that_plugin')` fails too.

**Avoid:**
- Lambda `{ -> luaeval("...") }` with embedded double-quoted strings
- Colon-prefixed `:lua require("...").something()` strings — embedded quotes confuse the parser

**Use instead:** define a `function!` and pass `function('Name')`. Always works:
```vim
function! MyBuildHook(info)
  lua require('plugin').build()
endfunction
Plug 'foo/bar', { 'do': function('MyBuildHook') }
```

---

## Post-install checklist

Run these inside nvim after `:PlugInstall` and relaunch:

```
:MasonInstall roslyn       " C# only
:TSUpdate                  " sync treesitter parsers
:checkhealth               " resolve any red entries
:Mason                     " verify pyright + vtsls are installed
```

---

## Full setup sequence for a clean machine

```bash
# 1. System deps
brew install neovim ripgrep fd fzf node git dotnet
brew install rust && rustup update stable
cargo install tree-sitter-cli
# Ensure ~/.cargo/bin is on PATH (zshrc) so nvim can find tree-sitter
grep -q '.cargo/bin' ~/.zshrc || echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc

# 2. vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim \
  --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# 3. Config
mkdir -p ~/.config/nvim
cp ./init.vim ~/.config/nvim/init.vim

# 4. Inside nvim
# :PlugInstall   → then quit and reopen
# :MasonInstall roslyn
# :TSUpdate
# :checkhealth
```
