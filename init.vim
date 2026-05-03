let mapleader = ";"

set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching
set ignorecase              " case insensitive
set mouse=a                 " enable mouse click
set hlsearch                " highlight search
set incsearch               " incremental search
set tabstop=4               " number of columns occupied by a tab
set softtabstop=4           " see multiple spaces as tabstops
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions
set cc=80                   " set an 80 column border
filetype plugin indent on   " allow auto-indenting depending on file type
syntax on                   " syntax highlighting
set clipboard=unnamedplus   " using system clipboard
filetype plugin on
set cursorline              " highlight current cursorline
set ttyfast                 " speed up scrolling in Vim

" ============================================================
" PLUGINS
" ============================================================
call plug#begin()

" Core utilities
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'MunifTanjim/nui.nvim'

" Colorscheme
Plug 'ellisonleao/gruvbox.nvim'

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" LSP foundation
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'

" Completion  (requires: brew install rust)
Plug 'saghen/blink.cmp', { 'do': 'cargo build --release' }

" C# LSP
Plug 'seblyng/roslyn.nvim'

" Fuzzy finder
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
Plug 'ibhagwan/fzf-lua', {'branch': 'main'}

" File tree  (replaces NERDTree)
Plug 'nvim-neo-tree/neo-tree.nvim'

" Testing
Plug 'nvim-neotest/nvim-nio'
Plug 'nvim-neotest/neotest'
Plug 'nvim-neotest/neotest-python'
Plug 'marilari88/neotest-vitest'
Plug 'Issafalcon/neotest-dotnet'

" Build / compile  (overseer is required by compiler.nvim)
Plug 'stevearc/overseer.nvim'
Plug 'Zeioth/compiler.nvim'

" Markdown
Plug 'MeanderingProgrammer/render-markdown.nvim'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }

" Git
Plug 'lewis6991/gitsigns.nvim'
Plug 'sindrets/diffview.nvim'
Plug 'NeogitOrg/neogit'

call plug#end()

" ============================================================
" COLORSCHEME
" ============================================================
set background=dark
colorscheme gruvbox

" ============================================================
" KEYBINDINGS — file navigation
" ============================================================

" fzf-lua (primary — faster, better rg integration)
nnoremap <leader>sf <cmd>FzfLua files<cr>
nnoremap <leader>sg <cmd>FzfLua live_grep<cr>
nnoremap <leader>sb <cmd>FzfLua buffers<cr>
nnoremap <leader>sw <cmd>FzfLua grep_cword<cr>

" Telescope (kept for help tags / extensions)
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Neo-tree (replaces NERDTree — <C-t> kept as toggle)
nnoremap <C-t>     :Neotree toggle<CR>
nnoremap <leader>e :Neotree focus<CR>

" ============================================================
" KEYBINDINGS — testing (neotest)
" ============================================================
nnoremap <leader>tt <cmd>lua require('neotest').run.run()<cr>
nnoremap <leader>tf <cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>
nnoremap <leader>ts <cmd>lua require('neotest').summary.toggle()<cr>
nnoremap <leader>to <cmd>lua require('neotest').output.open({ enter = true })<cr>

" ============================================================
" KEYBINDINGS — build (compiler.nvim)
" ============================================================
nnoremap <F6> :CompilerOpen<CR>
nnoremap <F7> :CompilerRedo<CR>
nnoremap <F8> :CompilerToggleResults<CR>

" ============================================================
" KEYBINDINGS — git
" ============================================================
nnoremap <leader>gs <cmd>Neogit<cr>
nnoremap <leader>gd <cmd>DiffviewOpen<cr>
nnoremap <leader>gc <cmd>DiffviewClose<cr>

" ============================================================
" LUA PLUGIN CONFIGURATION
" ============================================================
lua << EOF

-- Skip all plugin config if plugins are not yet installed (before :PlugInstall)
if not pcall(require, 'mason') then
  vim.notify('Plugins not installed. Run :PlugInstall', vim.log.levels.WARN)
  return
end

-- Mason (LSP/tool installer)
-- Crashdummyy/mason-registry provides the 'roslyn' package not in the default registry
require("mason").setup({
  registries = {
    "github:mason-org/mason-registry",
    "github:Crashdummyy/mason-registry",
  },
})
require("mason-lspconfig").setup({
  ensure_installed      = { "pyright", "vtsls" },
  automatic_installation = true,
  -- mason-lspconfig auto-calls vim.lsp.enable() for installed servers
})

-- Shared LSP keybindings applied on server attach
local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr, silent = true }
  vim.keymap.set('n', 'gd',         vim.lsp.buf.definition,     opts)
  vim.keymap.set('n', 'gD',         vim.lsp.buf.declaration,    opts)
  vim.keymap.set('n', 'gt',         vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', 'gr',         vim.lsp.buf.references,     opts)
  vim.keymap.set('n', 'gi',         vim.lsp.buf.implementation,  opts)
  vim.keymap.set('n', 'K',          vim.lsp.buf.hover,          opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action,    opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,         opts)
  vim.keymap.set('n', '<leader>ld', vim.diagnostic.open_float,  opts)
  vim.keymap.set('n', '[d',         vim.diagnostic.goto_prev,   opts)
  vim.keymap.set('n', ']d',         vim.diagnostic.goto_next,   opts)
end

local capabilities = require('blink.cmp').get_lsp_capabilities()

-- Apply on_attach and capabilities to all LSP servers (nvim 0.11+ API)
vim.lsp.config('*', {
  on_attach    = on_attach,
  capabilities = capabilities,
})

-- C# (roslyn.nvim — after :PlugInstall run :MasonInstall roslyn)
-- LSP settings go through vim.lsp.config, plugin behaviour through require('roslyn').setup
vim.lsp.config('roslyn', {
  on_attach    = on_attach,
  capabilities = capabilities,
  settings = {
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types  = true,
    },
    ["csharp|code_lens"] = {
      dotnet_enable_references_code_lens = true,
    },
  },
})

require('roslyn').setup({
  broad_search = false,
  lock_target  = false,
})

-- Completion
require('blink.cmp').setup({
  keymap  = { preset = 'default' },
  sources = { default = { 'lsp', 'path', 'buffer', 'snippets' } },
})

-- fzf-lua
require('fzf-lua').setup({ 'default' })

-- Neo-tree
require("neo-tree").setup({
  close_if_last_window = true,
  window = { width = 30 },
  filesystem = {
    filtered_items = {
      hide_dotfiles   = false,
      hide_gitignored = false,
    },
    follow_current_file = { enabled = true },
  },
})

-- Treesitter (nvim-treesitter v2 API — requires nvim 0.12)
require('nvim-treesitter').setup({})
vim.schedule(function()
  require('nvim-treesitter').install({
    'c_sharp', 'python', 'typescript', 'javascript',
    'markdown', 'markdown_inline', 'lua',
  })
end)

-- Neotest
require('neotest').setup({
  adapters = {
    require('neotest-python')({ dap = { justMyCode = false } }),
    require('neotest-vitest'),
    require('neotest-dotnet')({ dap = { justMyCode = false } }),
  },
})

-- Overseer (required by compiler.nvim)
require('overseer').setup()

-- render-markdown (in-buffer markdown rendering)
require('render-markdown').setup({
  file_types = { 'markdown' },
})

-- Gitsigns
require('gitsigns').setup({
  signs = {
    add    = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
  },
  on_attach = function(bufnr)
    local gs   = package.loaded.gitsigns
    local opts = { buffer = bufnr, silent = true }
    vim.keymap.set('n', ']h',         gs.next_hunk,       opts)
    vim.keymap.set('n', '[h',         gs.prev_hunk,       opts)
    vim.keymap.set('n', '<leader>hs', gs.stage_hunk,      opts)
    vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, opts)
    vim.keymap.set('n', '<leader>hb', gs.blame_line,      opts)
  end,
})

-- Neogit
require('neogit').setup({
  integrations = { diffview = true },
})

-- Diffview
require('diffview').setup()

EOF
