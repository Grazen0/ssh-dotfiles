vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Just in case
vim.opt.encoding = 'utf-8'
vim.opt.compatible = false
vim.opt.termguicolors = true
-- Numbering and stuff
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
vim.opt.scrolloff = 10
vim.opt.cursorline = true
vim.opt.cursorlineopt = 'both'

-- Wrapping
vim.opt.breakindent = true
vim.opt.linebreak = true

-- Searching
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

-- Spacing
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true

-- Misc (?)
vim.opt.showmode = false
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.autoread = true
vim.opt.mouse = 'a' -- No shame
vim.opt.splitright = true
vim.opt.undofile = true
vim.opt.updatetime = 300
vim.opt.spelllang = { 'es', 'en_us' }
vim.opt.confirm = true

local function keyset(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent or true

  vim.keymap.set(mode, lhs, rhs, opts)
end

keyset('n', 'gh', '^')
keyset('n', 'gl', '$')

vim.keymap.set('o', 'ie', ':<C-u>normal! mzggVG<CR>`z')
vim.keymap.set('x', 'ie', ':<C-u>normal! ggVG<CR>')

-- Better redo
keyset('n', 'U', '<C-r>')

-- Window navigation
keyset('n', '<C-h>', '<C-w>h')
keyset('n', '<C-j>', '<C-w>j')
keyset('n', '<C-k>', '<C-w>k')
keyset('n', '<C-l>', '<C-w>l')

-- Window positioning
keyset('n', '<A-h>', '<C-w>H')
keyset('n', '<A-j>', '<C-w>J')
keyset('n', '<A-k>', '<C-w>K')
keyset('n', '<A-l>', '<C-w>L')

-- Window resizing
keyset('n', '<A-,>', '<C-w><lt>')
keyset('n', '<A-.>', '<C-w>>')
keyset('n', '<A-->', '<C-w>-')
keyset('n', '<A-=>', '<C-w>+')

-- Soft line wrap movement
keyset('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })
keyset('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- n/N always move forwards/backwards, respectively
keyset('n', 'n', 'v:searchforward ? "n" : "N"', { expr = true })
keyset('n', 'N', 'v:searchforward ? "N" : "n"', { expr = true })

-- Floating diagnostic window
keyset('n', '<leader>d', vim.diagnostic.open_float)

-- Spell quick fix
keyset('i', '<C-l>', '<C-g>u<Esc>[s1z=`]a<C-g>u')

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    config = function(_, opts)
      require('kanagawa').setup(opts)
      vim.cmd('colorscheme kanagawa')
    end,
    opts = {
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = 'none',
            },
          },
        },
      },
      overrides = function(colors)
        local theme = colors.theme
        local palette = colors.palette
  
        local make_bg_blended_color = function(color, ratio)
          local c = require('kanagawa.lib.color')
          return {
            fg = color,
            bg = c(color):blend(theme.ui.bg, ratio or 0.95):to_hex(),
          }
        end
  
        return {
          -- Custom window separator line
          WinSeparator = { link = 'LineNr' },
  
          -- Dark completion background
          Pmenu = {
            fg = theme.ui.shade0,
            bg = theme.ui.bg,
            blend = vim.o.pumblend,
          },
          PmenuExtra = { fg = theme.syn.comment, bg = theme.ui.bg },
          PmenuSel = { fg = 'none', bg = theme.ui.bg_p2 },
          PmenuSbar = { bg = theme.ui.bg_m1 },
          PmenuThumb = { bg = theme.ui.bg_p2 },
  
          -- Transparent floating windows
          NormalFloat = { bg = 'none' },
          FloatBorder = { bg = 'none' },
          FloatTitle = { bg = 'none' },
  
          -- Tint background of diagnostic messages with their foreground color
          DiagnosticVirtualTextHint = make_bg_blended_color(theme.diag.hint), DiagnosticVirtualTextInfo = make_bg_blended_color(theme.diag.info), DiagnosticVirtualTextWarn = make_bg_blended_color(theme.diag.warning), DiagnosticVirtualTextError = make_bg_blended_color(theme.diag.error),
        }
      end,
    },
  },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    keys = {
      {
        '<leader>e',
        function()
          require('snacks').explorer({ auto_close = true, hidden = true })
        end,
        desc = 'Open explorer',
      },
      {
        '<leader>lg',
        function()
          require('snacks').lazygit()
        end,
      },
      {
        '<leader>q',
        function()
          require('snacks').bufdelete()
        end,
        desc = 'Delete buffer',
      },
      {
        '<leader>C',
        function()
          require('snacks').bufdelete.other()
        end,
        desc = 'Delete other buffers',
      },
      {
        '<F1>',
        function()
          require('snacks').picker.help()
        end,
        desc = 'Find help tags',
      },
      {
        '<leader><leader>',
        function()
          require('snacks').picker.buffers()
        end,
        desc = 'Find buffers',
      },
      {
        '<leader>ff',
        function()
          require('snacks').picker.files({ hidden = true })
        end,
        desc = 'Find files',
      },
      {
        '<leader>fg',
        function()
          require('snacks').picker.grep()
        end,
        desc = 'Find with grep',
      },
      {
        '<leader>ft',
        function()
          require('snacks').picker.pick({ source = 'todo_comments' })
        end,
        desc = 'Find todo comments',
      },
      {
        'gd',
        function()
          require('snacks').picker.lsp_definitions()
        end,
        desc = 'Goto Definition',
      },
      {
        'gD',
        function()
          require('snacks').picker.lsp_declarations()
        end,
        desc = 'Goto Declaration',
      },
      {
        'grr',
        function()
          require('snacks').picker.lsp_references()
        end,
        desc = 'References',
      },
      {
        'gI',
        function()
          require('snacks').picker.lsp_implementations()
        end,
        desc = 'Goto Implementation',
      },
    },
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      lazygit = {
        enabled = true,
        win = { border = 'single' },
      },
      indent = {
        enabled = true,
        scope = { hl = 'SignColumn' },
        animate = { enabled = false },
      },
      picker = {
        enable = true,
        win = {
          list = {
            keys = {
              -- Mostly for file explorer
              ['w'] = { { 'pick_win', 'jump' }, mode = { 'n', 'i' } },
            },
          },
        },
        layouts = {
          default = {
            layout = {
              box = 'horizontal',
              width = 0.8,
              min_width = 120,
              height = 0.8,
              {
                box = 'vertical',
                border = 'single',
                title = '{title} {live} {flags}',
                { win = 'input', height = 1, border = 'bottom' },
                { win = 'list', border = 'none' },
              },
              {
                win = 'preview',
                title = '{preview}',
                border = 'single',
                width = 0.5,
              },
            },
          },
          sidebar = {
            preview = 'main',
            layout = {
              backdrop = false,
              width = 40,
              min_width = 40,
              height = 0,
              position = 'left',
              border = 'none',
              box = 'vertical',
              {
                win = 'input',
                height = 1,
                border = 'single',
                title = '{title} {live} {flags}',
                title_pos = 'center',
              },
              { win = 'list', border = 'none' },
              {
                win = 'preview',
                title = '{preview}',
                height = 0.4,
                border = 'top',
              },
            },
          },
          select = {
            preview = false,
            layout = {
              backdrop = false,
              width = 0.5,
              min_width = 80,
              height = 0.4,
              min_height = 3,
              box = 'vertical',
              border = 'single',
              title = '{title}',
              title_pos = 'center',
              { win = 'input', height = 1, border = 'bottom' },
              { win = 'list', border = 'none' },
              {
                win = 'preview',
                title = '{preview}',
                height = 0.4,
                border = 'top',
              },
            },
          },
        },
      },
      explorer = { enable = true },
      bufdelete = { enabled = true },
    },
  },
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        globalstatus = true,
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {
          { 'filetype', icon_only = true },
          {
            'filename',
            symbols = { modified = ' ', readonly = ' ' },
          },
        },
        lualine_c = {},
        lualine_x = {
          'diagnostics',
          {
            function()
              local clients = vim.lsp.get_clients()
  
              if next(clients) == nil then
                return 'No LSP'
              end
  
              for _, client in ipairs(clients) do
                local filetypes = client.config.filetypes
                if
                  filetypes and vim.fn.index(filetypes, vim.bo.filetype) ~= -1
                then
                  return client.name
                end
              end
  
              return 'No LSP'
            end,
            cond = function()
              return vim.fn.index(
                { 'toggleterm', 'snacks_picker_list' },
                vim.bo.filetype
              ) == -1
            end,
            icon = ' ',
          },
        },
        lualine_y = {
          { 'searchcount', maxcount = 999, timeout = 120 },
          { 'branch', icon = '' },
        },
        lualine_z = { 'progress', 'location', 'fileformat' },
      },
    },
  }
}, {
  ui = { border = 'single' },
})
