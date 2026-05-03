# Neovim Setup Guide (for Claude on a new laptop)

This document tells Claude how to reproduce the user's Neovim configuration on a fresh machine. Follow it top-to-bottom; verify each step before moving on.

## Target environment

- **Neovim**: 0.12+ (treesitter v2 API requires it)
- **OS**: macOS (Darwin) primary; Linux instructions noted where they differ
- **Plugin manager**: [vim-plug](https://github.com/junegunn/vim-plug)
- **Shell**: zsh
- **Leader key**: `;`

## 1. System prerequisites

Install these before launching nvim — several plugins build native components on first install.

### macOS (Homebrew)

```bash
brew install neovim
brew install ripgrep fd        # required by telescope / fzf-lua live_grep + files
brew install fzf               # binary backing fzf-lua
brew install rust              # blink.cmp builds with cargo on install
brew install git
brew install node              # markdown-preview uses npx/yarn
brew install gh                # optional, used by some workflows
brew install dotnet            # only if you use the C# / roslyn LSP
brew install python            # neotest-python adapter target
```

> **Important — tree-sitter CLI**: `brew install tree-sitter` (0.26.8+) installs only the **C library**, not the CLI binary. The CLI is required by nvim-treesitter v2 to compile parsers. Install it via cargo instead:
>
> ```bash
> cargo install tree-sitter-cli
> ```
>
> After this, `tree-sitter --version` should print `0.26.x` or later.

> **Important — Rust version**: `blink.cmp` requires Rust 1.85+ (uses `edition2024`). `brew install rust` may give an older version. If `cargo build --release` fails with `feature 'edition2024' is required`, update via:
>
> ```bash
> rustup update stable
> ```
>
> Then manually rebuild blink.cmp:
>
> ```bash
> cd ~/.local/share/nvim/plugged/blink.cmp && cargo build --release
> ```

### Linux (apt example)

```bash
sudo apt install neovim ripgrep fd-find fzf git nodejs npm python3
# Install Rust via rustup: https://rustup.rs
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Verify

```bash
nvim --version | head -1   # expect 0.12+
rg --version
fd --version
cargo --version
node --version
```

## 2. Install vim-plug

```bash
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

## 3. Drop the init.vim in place

Copy the canonical `init.vim` (committed alongside this guide) to `~/.config/nvim/init.vim`:

```bash
mkdir -p ~/.config/nvim
cp ./init.vim ~/.config/nvim/init.vim
```

If a previous config exists, back it up first:

```bash
[ -f ~/.config/nvim/init.vim ] && mv ~/.config/nvim/init.vim ~/.config/nvim/init.vim.backup
```

## 4. Install plugins

Open nvim — the config tolerates the first-run state where plugins are not yet present (it warns and skips Lua setup):

```bash
nvim
```

Inside nvim:

```
:PlugInstall
```

Then **quit and relaunch** nvim so the Lua plugin config block runs against the now-installed plugins.

## 5. Post-install steps inside nvim

Run these once, in order:

```
:MasonInstall roslyn      " only if you use C# — roslyn package comes from Crashdummyy registry
:TSUpdate                 " treesitter parsers (the config also installs a curated set on schedule)
:checkhealth              " sanity-check everything; resolve any red entries
```

Mason should auto-install `pyright` and `vtsls` on first LSP attach (configured via `ensure_installed`).

## 6. Plugin inventory (what gets installed and why)

| Plugin | Purpose |
|---|---|
| `nvim-lua/plenary.nvim` | Lua utility lib (telescope/neotest/gitsigns dep) |
| `nvim-tree/nvim-web-devicons` | Filetype icons |
| `MunifTanjim/nui.nvim` | UI primitives (neo-tree dep) |
| `ellisonleao/gruvbox.nvim` | Colorscheme |
| `nvim-treesitter/nvim-treesitter` | Syntax / parsing (v2 API) |
| `neovim/nvim-lspconfig` | LSP server configs |
| `williamboman/mason.nvim` | LSP / tool installer |
| `williamboman/mason-lspconfig.nvim` | Bridge between mason and lspconfig |
| `saghen/blink.cmp` | Completion engine (Rust-built) |
| `seblyng/roslyn.nvim` | C# LSP integration |
| `nvim-telescope/telescope.nvim` | Fuzzy finder (pinned to `0.1.8`) |
| `ibhagwan/fzf-lua` | Faster fuzzy finder (primary) |
| `nvim-neo-tree/neo-tree.nvim` | File explorer (replaces NERDTree) |
| `nvim-neotest/neotest` + adapters | Test runner UI; adapters for Python, Vitest, .NET |
| `stevearc/overseer.nvim` | Task runner (compiler.nvim dep) |
| `Zeioth/compiler.nvim` | Build / compile commands |
| `MeanderingProgrammer/render-markdown.nvim` | In-buffer markdown rendering |
| `iamcco/markdown-preview.nvim` | Browser-based markdown preview |
| `lewis6991/gitsigns.nvim` | Git gutter signs + hunks |
| `sindrets/diffview.nvim` | Side-by-side diffs |
| `NeogitOrg/neogit` | Magit-style git UI |

## 6b. Shell aliases

No nvim-specific aliases are currently set in `~/.zshrc`. Optionally add these for convenience on a new machine:

```bash
# ~/.zshrc
alias vi="nvim"
alias vim="nvim"
```

Without them, you must type `nvim` to launch the editor. `vi` and `vim` will fall back to whatever the system has installed (usually an older Vim).

## 7. Key bindings cheat sheet

### Leader key

Leader is set to `;`. This is the **first line** of `init.vim`, before any keymaps:

```vim
let mapleader = ";"
```

It must come before `call plug#begin()` and all `nnoremap` calls, otherwise keymaps defined earlier will use the default leader (`\`).

### File / text search
- `;sf` — fzf-lua **f**iles (filename fuzzy search) — *primary*
- `;sg` — fzf-lua live **g**rep (text content via ripgrep)
- `;sb` — fzf-lua **b**uffers
- `;sw` — fzf-lua grep **w**ord under cursor
- `;ff`, `;fg`, `;fb`, `;fh` — same via Telescope (kept for help tags / extensions)

### File tree (neo-tree)
- `<C-t>` — toggle tree
- `;e` — focus tree

### LSP (set on attach)
- `gd` definition · `gD` declaration · `gt` type-def · `gr` references · `gi` implementations
- `K` hover · `;ca` code action · `;rn` rename · `;ld` line diagnostics · `[d` / `]d` prev / next diagnostic

### Testing (neotest)
- `;tt` run nearest · `;tf` run file · `;ts` summary toggle · `;to` open output

### Build (compiler.nvim)
- `<F6>` open · `<F7>` redo · `<F8>` toggle results

### Git
- `;gs` Neogit · `;gd` DiffviewOpen · `;gc` DiffviewClose
- `]h` / `[h` next / prev hunk · `;hs` stage · `;hu` undo stage · `;hb` blame line

## 8. Verifying the install

After plugin install + relaunch:

```
:checkhealth
:LspInfo               " open a .py / .ts / .cs file first
:Telescope find_files  " confirm Telescope works
```

`;sf` and `;sg` should both open fzf-lua pickers. If they error out about a missing module, plugins haven't been installed — re-run `:PlugInstall` and relaunch.

## 9. Putting this on GitHub

Recommended layout for the repo:

```
nvim-config/
├── README.md          (this file, renamed)
├── init.vim
└── (optional) screenshots/
```

To bootstrap on a new laptop after the repo is online:

```bash
git clone <repo-url> ~/ai/nvim
mkdir -p ~/.config/nvim
ln -s ~/ai/nvim/init.vim ~/.config/nvim/init.vim   # or `cp` if you don't want a symlink
```

Then follow sections 1, 2, 4, 5.

## 10. Troubleshooting

### blink.cmp fails to build (`edition2024` error)

`cargo 1.78` (from `brew install rust`) is too old. blink.cmp 1.x requires Rust 1.85+.

```bash
rustup update stable
cd ~/.local/share/nvim/plugged/blink.cmp && cargo build --release
```

If `rustup` is not found, install it first:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### blink.cmp `do` hook didn't run after `:PlugInstall`

vim-plug's `do` hook sometimes doesn't execute on first install. Build manually:
```bash
cd ~/.local/share/nvim/plugged/blink.cmp && cargo build --release
```

### tree-sitter CLI not found (`ENOENT: 'tree-sitter'`)

`brew install tree-sitter` 0.26.8+ is **library only** — no CLI binary is installed. The binary is at `/opt/homebrew/Cellar/tree-sitter/0.25.6/bin/tree-sitter` if an older version was previously installed, but that version is below the 0.26.1 requirement. Use cargo:

```bash
cargo install tree-sitter-cli
```

### `require('nvim-treesitter.configs')` module not found

nvim-treesitter v2 (required for nvim 0.12) removed this module entirely. The config must use the new API:

```lua
-- WRONG (old API, removed in v2)
require('nvim-treesitter.configs').setup({ highlight = { enable = true } })

-- CORRECT (v2 API)
require('nvim-treesitter').setup({})
require('nvim-treesitter').install({ 'python', 'typescript', 'c_sharp', ... })
```

### `require('lspconfig').X.setup()` deprecation warning

nvim 0.11+ deprecates the old lspconfig call API. The config uses the new approach:

```lua
-- WRONG (deprecated)
require('lspconfig').pyright.setup({ on_attach = ..., capabilities = ... })

-- CORRECT (nvim 0.11+ API)
vim.lsp.config('*', { on_attach = ..., capabilities = ... })
-- mason-lspconfig automatically calls vim.lsp.enable() for installed servers
```

### Roslyn (`roslyn`) not found in `:Mason`

It is **not** in the default `mason-org/mason-registry`. The `mason.setup()` call must include the custom registry:

```lua
require("mason").setup({
  registries = {
    "github:mason-org/mason-registry",
    "github:Crashdummyy/mason-registry",   -- provides roslyn + roslyn-unstable
  },
})
```

After that, `:MasonInstall roslyn` works. The package installs the same Roslyn server used by the VS Code C# extension.

### `dotnet tool install Microsoft.CodeAnalysis.LanguageServer` fails

The package is not on public NuGet. Use Mason with the Crashdummyy registry (see above) instead of `dotnet tool install`.

### `fzf-lua` ignores files

Respects `.gitignore` by default. Toggle hidden via picker keys, or pass `--no-ignore` flags in setup.

### Clipboard doesn't sync to system

Install `pbcopy` (macOS, built-in) or `xclip` / `wl-clipboard` (Linux). The config sets `clipboard=unnamedplus`.
