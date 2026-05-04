# Keymap Cheat Sheet

Reference for all custom mappings in `init.vim`. Leader key is `;`.

---

## File search

| Keys | Action | Plugin |
|---|---|---|
| `;sf` | Find files (fast) | fzf-lua |
| `;sb` | Search open buffers | fzf-lua |
| `;ff` | Find files | telescope |
| `;fb` | Search open buffers | telescope |
| `;fh` | Search help tags | telescope |

`fzf-lua` is faster — prefer the `;s*` set for daily use. `;f*` is kept around for telescope-only extensions (e.g. help tags).

---

## Pattern / text search

| Keys | Action | Plugin |
|---|---|---|
| `;sg` | Live grep across project | fzf-lua |
| `;sw` | Grep word under cursor | fzf-lua |
| `;fg` | Live grep | telescope |

Built-in, useful alongside the above:
- `/pattern` — search forward in current buffer
- `?pattern` — search backward
- `n` / `N` — next / previous match
- `*` / `#` — search for word under cursor forward / backward

---

## File explorer (neo-tree)

| Keys | Action |
|---|---|
| `Ctrl-t` | Toggle file tree |
| `;e` | Focus file tree |

Inside the tree (neo-tree defaults): `<CR>` open, `s` open in vsplit, `S` open in hsplit, `a` add file, `d` delete, `r` rename, `c` copy, `m` move, `R` refresh, `H` toggle hidden files.

---

## Buffers & windows

No custom mappings — vim built-ins:

**Buffers**
- `:bn` / `:bp` — next / previous buffer
- `:b <name>` — jump to buffer by partial name (tab-complete)
- `:ls` — list buffers
- `:bd` — delete buffer

**Windows**
- `Ctrl-w s` / `Ctrl-w v` — split horizontal / vertical
- `Ctrl-w h/j/k/l` — move between windows
- `Ctrl-w c` — close window
- `Ctrl-w o` — close all other windows
- `Ctrl-w =` — equalize sizes
- `Ctrl-w +` / `Ctrl-w -` — taller / shorter
- `Ctrl-w >` / `Ctrl-w <` — wider / narrower

**Tabs**
- `:tabnew` / `:tabclose`
- `gt` / `gT` — next / previous tab
- ⚠ `gt` is also remapped to LSP type-definition while an LSP buffer is attached. In LSP buffers, use `:tabnext` / `:tabprev` for tab nav.

---

## LSP / code intelligence

Active only in buffers with an attached LSP server.

| Keys | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gt` | Go to type definition |
| `gi` | Go to implementation |
| `gr` | Find references |
| `K` | Hover documentation |
| `;ca` | Code action |
| `;rn` | Rename symbol |

---

## Diagnostics

| Keys | Action |
|---|---|
| `;ld` | Show diagnostic float (line under cursor) |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |

---

## Completion (blink.cmp)

Inside the completion menu (uses blink.cmp's `default` preset):

| Keys | Action |
|---|---|
| `Ctrl-Space` | Trigger / show menu |
| `Ctrl-n` / `Ctrl-p` | Next / previous item |
| `Tab` / `Shift-Tab` | Snippet field navigation |
| `Ctrl-y` | Accept selected |
| `Ctrl-e` | Cancel / hide |

---

## Git

**Repo-level (Neogit / Diffview)**

| Keys | Action |
|---|---|
| `;gs` | Open Neogit (magit-style status / staging) |
| `;gd` | Open Diffview (side-by-side diff vs index) |
| `;gc` | Close Diffview |

**Hunk-level (Gitsigns, active in any file)**

| Keys | Action |
|---|---|
| `]h` | Next hunk |
| `[h` | Previous hunk |
| `;hs` | Stage hunk |
| `;hu` | Undo stage hunk |
| `;hb` | Blame current line |

---

## Testing (neotest)

| Keys | Action |
|---|---|
| `;tt` | Run nearest test |
| `;tf` | Run all tests in current file |
| `;ts` | Toggle summary panel |
| `;to` | Open last test output |

---

## Build / compile (compiler.nvim)

| Keys | Action |
|---|---|
| `F6` | Pick & run build target |
| `F7` | Re-run last build |
| `F8` | Toggle results panel |

---

## Quick reference — most-used flow

1. `;sf` find a file → edit
2. `gd` jump to definition · `gr` find references · `K` hover
3. `;rn` rename · `;ca` quickfix
4. `;sg` grep across project
5. `;hs` stage hunk · `;gs` open Neogit to commit
6. `;tt` run nearest test
