-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key before lazy setup
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Load lazy.nvim
require("lazy").setup({
  -- Sensible defaults
  { "tpope/vim-sensible" },
  
  -- File navigation
  { "ctrlpvim/ctrlp.vim" },
  { 
    "wincent/command-t",
    build = "cd lua/wincent/commandt/lib && make",
    init = function()
      vim.g.CommandTRefreshMap = '<C-t>'
      vim.g.CommandTMatchWindowAtTop = 1
      vim.g.CommandTMaxFiles = 50000
      vim.g.CommandTMaxCachedDirectories = 10000
      vim.g.CommandTFileScanner = 'git'
      vim.g.CommandTWildIgnore = vim.o.wildignore .. ",build/**,thirdparty/src/**,thirdparty/build/**,logs/**,**/target/**,**/CMakeFiles/**"
    end
  },
  
  -- File explorer
  { "scrooloose/nerdtree" },
  
  -- Git integration
  { "tpope/vim-fugitive" },
  
  -- Session management
  { "tpope/vim-obsession" },
  
  -- Text manipulation
  { "tpope/vim-surround" },
  { "tpope/vim-repeat" },
  
  -- Search
  { 
    "mpercy/ack.vim",
    init = function()
      vim.g.ackprg = 'ag -t --depth 100 --nogroup --nocolor --column'
    end
  },
  
  -- Tmux integration
  { "christoomey/vim-tmux-navigator" },
  { "tmux-plugins/vim-tmux-focus-events" },
  
  -- Alternate files
  { "mpercy/a.vim" },
  
  -- Alignment
  { "godlygeek/tabular" },
  
  -- Language support
  { "plasticboy/vim-markdown" },
  { "derekwyatt/vim-scala" },
  { "asciidoc/vim-asciidoc" },
  
  -- Colorschemes
  { "vim-scripts/mayansmoke" },
  { "NLKNguyen/papercolor-theme" },
  { "mpercy/wombat256cpp2.vim" },
  
  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c", "cpp", "lua", "vim", "vimdoc", "query",  -- Core
          "rust", "python", "go", "typescript", "javascript",  -- Languages
          "bash", "json", "yaml", "toml", "markdown", "markdown_inline",  -- Config/Docs
          "html", "css", "sql", "dockerfile", "cmake",  -- Web/Tools
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = "<C-s>",
            node_decremental = "<C-backspace>",
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
          },
        },
      })
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
  },
  
  -- LSP Support
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- LSP installer
      { "williamboman/mason.nvim", config = true },
      { "williamboman/mason-lspconfig.nvim" },
      
      -- Autocompletion
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "L3MON4D3/LuaSnip" },
      { "saadparwaiz1/cmp_luasnip" },
      
      -- Better LSP UI
      { "j-hui/fidget.nvim", opts = {} },
      
      -- Trouble for better diagnostics display
      { 
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
      },
      
      -- Code lens support (shows references/implementations inline)
      {
        "VidocqH/lsp-lens.nvim",
        opts = {
          enable = true,
          include_declaration = false,
          sections = {
            definition = false,
            references = true,
            implementations = true,
          },
        },
      },
    },
    config = function()
      -- Setup Mason first
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { 
          "clangd",           -- C/C++
          "rust_analyzer",    -- Rust
          "pyright",          -- Python
          "gopls",            -- Go
          "ts_ls",            -- TypeScript/JavaScript
        },
        automatic_installation = true,
      })
      
      -- Setup completion
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
      
      -- LSP settings
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      
      -- Global LSP keymaps
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          -- Similar to YCM mappings
          vim.keymap.set('n', '<leader>jd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', '<leader>jD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', '<leader>ji', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<leader>jt', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<leader>jr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<leader>jh', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>js', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', '<leader>f', function()
            vim.lsp.buf.format { async = true }
          end, opts)
          
          -- YCM-style mappings
          vim.keymap.set('n', '<leader>yf', vim.lsp.buf.code_action, opts) -- FixIt
          vim.keymap.set('n', '<leader>yd', vim.lsp.buf.hover, opts) -- GetDoc
          vim.keymap.set('n', '<leader>yt', vim.lsp.buf.type_definition, opts) -- GetType
          vim.keymap.set('n', '<leader>ye', vim.diagnostic.open_float, opts) -- Show diagnostics
          
          -- Navigate diagnostics
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        end,
      })
      
      -- Trouble keymaps (diagnostics UI)
      vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle() end, { desc = "Toggle Trouble" })
      vim.keymap.set("n", "<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end, { desc = "Workspace Diagnostics" })
      vim.keymap.set("n", "<leader>xd", function() require("trouble").toggle("document_diagnostics") end, { desc = "Document Diagnostics" })
      vim.keymap.set("n", "<leader>xq", function() require("trouble").toggle("quickfix") end, { desc = "Quickfix List" })
      vim.keymap.set("n", "<leader>xl", function() require("trouble").toggle("loclist") end, { desc = "Location List" })
      vim.keymap.set("n", "<leader>xr", function() require("trouble").toggle("lsp_references") end, { desc = "LSP References" })
      
      -- Code lens keymaps
      vim.keymap.set("n", "<leader>lr", vim.lsp.codelens.run, { desc = "Run code lens" })
      vim.keymap.set("n", "<leader>lR", vim.lsp.codelens.refresh, { desc = "Refresh code lens" })
      
      -- Configure clangd
      lspconfig.clangd.setup({
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      })
      
      -- Configure rust-analyzer
      lspconfig.rust_analyzer.setup({
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            imports = {
              granularity = {
                group = "module",
              },
              prefix = "self",
            },
            cargo = {
              buildScripts = {
                enable = true,
              },
            },
            procMacro = {
              enable = true,
            },
            checkOnSave = {
              command = "clippy",
            },
          },
        },
      })
      
      -- Configure pyright (Python)
      lspconfig.pyright.setup({
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "workspace",
              useLibraryCodeForTypes = true,
              typeCheckingMode = "basic",
            },
          },
        },
      })
      
      -- Configure gopls (Go)
      lspconfig.gopls.setup({
        capabilities = capabilities,
        settings = {
          gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
          },
        },
      })
      
      -- Configure ts_ls (TypeScript/JavaScript)
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayVariableTypeHintsWhenTypeMatchesName = false,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayVariableTypeHintsWhenTypeMatchesName = false,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      })
    end,
  },
})

-- Basic settings
vim.opt.compatible = false
vim.opt.encoding = "utf-8"
vim.opt.hidden = true
vim.opt.number = true
vim.opt.ruler = true
vim.opt.autoindent = true
vim.opt.tabstop = 8
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.splitright = true
vim.opt.lazyredraw = true
vim.opt.mouse = "a"
vim.opt.cursorline = true
vim.opt.laststatus = 2

-- Terminal color settings
if vim.fn.has('termguicolors') == 1 and vim.env.TERM ~= 'xterm-256color' then
  vim.opt.termguicolors = true
else
  vim.opt.t_Co = 256
end

-- Set colorscheme
vim.opt.background = "dark"
vim.cmd.colorscheme("wombat256cpp2")

-- If the background appears too dark compared to Vim, uncomment the following line:
-- vim.cmd("highlight Normal ctermbg=234")  -- Adjust 234 to 235 or 236 for lighter greys

-- Don't double space after periods when joining lines
vim.opt.joinspaces = false

-- Clipboard settings
if vim.fn.system('uname -s'):match("Darwin") then
  vim.opt.clipboard = "unnamed" -- macOS
else
  vim.opt.clipboard = "unnamedplus" -- Linux
end

-- Better word boundaries
vim.opt.iskeyword:append("^,")
vim.opt.iskeyword:append("^-")
vim.opt.iskeyword:append("^.")
vim.opt.iskeyword:append("^:")

-- Persistent undo
if vim.fn.has('persistent_undo') == 1 then
  vim.opt.undofile = true
  vim.opt.undodir = vim.fn.expand("~/.config/nvim/undo")
  -- Create undo directory if it doesn't exist
  vim.fn.mkdir(vim.fn.expand("~/.config/nvim/undo"), "p")
end

-- C++ indent options
vim.opt.cinoptions = "l1,g2,h1"

-- Wildmenu settings
vim.opt.wildchar = vim.api.nvim_replace_termcodes("<Tab>", true, true, true):byte()
vim.opt.wildmenu = true
vim.opt.wildmode = "full"
vim.opt.wildignore:append("*.o,*.class")

-- vim-markdown settings
vim.g.vim_markdown_folding_disabled = 1
vim.g.vim_markdown_fenced_languages = {'html', 'python', 'bash=sh', 'java', 'c++'}
vim.g.vim_markdown_new_list_item_indent = 2

-- CtrlP settings
vim.g.ctrlp_map = '<Leader>p'
vim.g.ctrlp_match_window_bottom = 1
vim.g.ctrlp_match_window_reversed = 1
vim.g.ctrlp_custom_ignore = '\\v\\~$|\\.(o|swp|pyc|wav|mp3|ogg|blend)$|(^|[/\\\\])\\.(hg|git|bzr)($|[/\\\\])|__init__\\.py'
vim.g.ctrlp_working_path_mode = 0
vim.g.ctrlp_dotfiles = 0
vim.g.ctrlp_switch_buffer = 0

-- Key mappings
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Escape remapping
keymap('i', 'jk', '<esc>', opts)
keymap('c', 'jk', '<C-c><esc>', opts)

-- Clear search highlighting
keymap('n', '<Leader>/', ':nohlsearch<CR>', opts)

-- Paste toggle (pastetoggle is deprecated in Neovim)
keymap('n', '<F2>', ':set paste!<CR>', opts)

-- Session management
keymap('n', '<F4>', ':mksession!<CR>', { noremap = true })

-- NERDTree
keymap('n', '<F5>', ':NERDTreeToggle<CR>', opts)

-- Alternate file
keymap('n', '<C-a>', ':call AlternateFile("n")<CR>', opts)

-- Window resizing
keymap('n', '<Leader>h-', ':resize -20<CR>', opts)
keymap('n', '<Leader>h+', ':resize +20<CR>', opts)
keymap('n', '<Leader>h=', ':resize +20<CR>', opts)
keymap('n', '<Leader>v-', ':vertical resize -20<CR>', opts)
keymap('n', '<Leader>v+', ':vertical resize +20<CR>', opts)
keymap('n', '<Leader>v=', ':vertical resize +20<CR>', opts)

-- Window navigation helpers
keymap('n', '<Leader>w=', '<C-w>=', opts)
keymap('n', '<Leader>w_', '<C-w>_', opts)
keymap('n', '<Leader>w|', '<C-w>|', opts)

-- Buffer navigation
keymap('n', '<Leader>a', ':bprev<CR>', opts)
keymap('n', '<Leader>s', ':bnext<CR>', opts)
keymap('n', '<Leader>d', ':bprevious<CR>:bdelete #<CR>', opts)
keymap('n', '<Leader>f', ':b ', { noremap = true })
keymap('n', ';', ':CtrlPBuffer<CR>', opts)

-- Ack shortcuts
keymap('n', '<leader>as', ':Ack! \'\\b<cword>\\b\' src/kudu/<CR>', opts)
keymap('n', '<leader>ag', ':Ack! \'\\b<cword>\\b\'<CR>', opts)

-- CTRL-click handling
keymap('n', '<C-LeftMouse>', '<LeftMouse>', opts)

-- Autocommands
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Markdown filetype
autocmd({"BufNewFile", "BufReadPost"}, {
  pattern = "*.md",
  command = "set filetype=markdown"
})

-- Python settings
autocmd("FileType", {
  pattern = "python",
  command = "setlocal sw=4 sts=4 ts=8 expandtab cindent"
})

-- Restore cursor position
autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line("'\"")
    if line > 0 and line <= vim.fn.line("$") then
      vim.cmd('normal! g`"')
    end
  end
})

-- Large file handling
vim.g.LargeFile = 1024 * 1024 * 10
local large_file_group = augroup("LargeFile", { clear = true })
autocmd("BufReadPre", {
  group = large_file_group,
  pattern = "*",
  callback = function()
    local f = vim.fn.getfsize(vim.fn.expand("<afile>"))
    if f > vim.g.LargeFile or f == -2 then
      -- Disable features for large files
      vim.opt_local.number = false
      vim.opt_local.ruler = false
      vim.opt_local.autoindent = false
      vim.opt_local.shiftround = false
      vim.opt_local.eventignore:append("FileType")
      vim.opt_local.bufhidden = "unload"
      vim.opt_local.buftype = "nowrite"
      vim.opt_local.undolevels = -1
      vim.schedule(function()
        vim.notify("Large file detected. Some features disabled for performance.", vim.log.levels.INFO)
      end)
    end
  end
})

-- WatchForChanges functionality
local function watch_for_changes(bufname, options)
  options = options or {}
  local autoread = options.autoread or false
  local toggle = options.toggle or false
  local disable = options.disable or false
  local more_events = options.more_events == nil and true or options.more_events
  local while_in_this_buffer_only = options.while_in_this_buffer_only or false
  
  local id, bufspec, event_bufspec
  
  if bufname == '*' then
    id = 'WatchForChangesAnyBuffer'
    bufspec = ''
    event_bufspec = '*'
  else
    local bufnr = vim.fn.bufnr(bufname)
    if bufnr == -1 then
      vim.notify("Buffer " .. bufname .. " doesn't exist", vim.log.levels.ERROR)
      return
    end
    id = 'WatchForChanges' .. bufnr
    bufspec = bufname
    event_bufspec = while_in_this_buffer_only and bufname or '*'
  end
  
  -- Check if autocommand group exists
  local existing = pcall(vim.api.nvim_get_autocmds, { group = id })
  
  if not existing then
    if autoread then
      if bufname == '*' then
        vim.opt.autoread = true
      else
        vim.api.nvim_buf_set_option(vim.fn.bufnr(bufname), 'autoread', true)
      end
    end
    
    local group = augroup(id, { clear = true })
    
    if bufname ~= '*' then
      autocmd("BufDelete", {
        group = group,
        pattern = bufname,
        callback = function()
          vim.api.nvim_del_augroup_by_name(id)
        end
      })
    end
    
    local events = {"BufEnter", "CursorHold", "CursorHoldI"}
    if more_events then
      table.insert(events, "CursorMoved")
      table.insert(events, "CursorMovedI")
    end
    
    autocmd(events, {
      group = group,
      pattern = event_bufspec,
      command = "checktime " .. bufspec
    })
  elseif disable or (toggle and existing) then
    if autoread then
      if bufname == '*' then
        vim.opt.autoread = false
      else
        vim.api.nvim_buf_set_option(vim.fn.bufnr(bufname), 'autoread', false)
      end
    end
    vim.api.nvim_del_augroup_by_name(id)
  end
end

-- Create commands for WatchForChanges
vim.api.nvim_create_user_command('WatchForChanges', function(opts)
  watch_for_changes(vim.fn.expand('%'), { toggle = true, autoread = opts.bang })
end, { bang = true })

vim.api.nvim_create_user_command('WatchForChangesWhileInThisBuffer', function(opts)
  watch_for_changes(vim.fn.expand('%'), { toggle = true, autoread = opts.bang, while_in_this_buffer_only = true })
end, { bang = true })

vim.api.nvim_create_user_command('WatchForChangesAllFile', function(opts)
  watch_for_changes('*', { toggle = true, autoread = opts.bang })
end, { bang = true })

-- Enable watch for changes on all files by default
watch_for_changes('*', { autoread = true })

-- Function to convert HTML links to Markdown
vim.api.nvim_create_user_command('HtmlLinksToMarkdown', function()
  vim.cmd([[%s/<a.\{-}href="\(.\{-}\)".\{-}>\(.\{-}\)<\/a>/[\2](\1)/g]])
end, {})