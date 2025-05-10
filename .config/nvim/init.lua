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

-- Restore cursor position on buffer enter
vim.api.nvim_create_autocmd('BufReadPost', {
  command = 'silent! normal g`"zv',
})

-- Highlight yanked text
vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = 'YankHighlight',
  callback = function()
    vim.highlight.on_yank({ higroup = 'Search', timeout = 500 })
  end,
})

local function alias_with_bang(cmd)
  return function(args)
    if args.bang then
      vim.cmd(cmd .. '!')
    else
      vim.cmd(cmd)
    end
  end
end

-- I'm kinda clumsy
vim.api.nvim_create_user_command('W', alias_with_bang('w'), { bang = true })
vim.api.nvim_create_user_command('Wa', alias_with_bang('wa'), { bang = true })
vim.api.nvim_create_user_command('X', alias_with_bang('x'), { bang = true })
vim.api.nvim_create_user_command('Xa', alias_with_bang('xa'), { bang = true })
vim.api.nvim_create_user_command('Q', alias_with_bang('q'), { bang = true })
vim.api.nvim_create_user_command('Qa', alias_with_bang('qa'), { bang = true })
vim.api.nvim_create_user_command('Bd', alias_with_bang('bd'), { bang = true })


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
    'tpope/vim-obsession',
    event = 'VeryLazy',
  },
  {
    'kylechui/nvim-surround',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },
  {
    'numToStr/comment.nvim',
    event = 'InsertEnter',
    opts = {},
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
  {
    'nvim-pack/nvim-spectre',
    cmd = 'Spectre',
    opts = {},
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
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
  
          -- -- Dark completion background
          -- Pmenu = {
          --   fg = theme.ui.shade0,
          --   bg = theme.ui.bg,
          --   blend = vim.o.pumblend,
          -- },
          -- PmenuExtra = { fg = theme.syn.comment, bg = theme.ui.bg },
          -- PmenuSel = { fg = 'none', bg = theme.ui.bg_p2 },
          -- PmenuSbar = { bg = theme.ui.bg_m1 },
          -- PmenuThumb = { bg = theme.ui.bg_p2 },
  
          -- -- Transparent floating windows
          -- NormalFloat = { bg = 'none' },
          -- FloatBorder = { bg = 'none' },
          -- FloatTitle = { bg = 'none' },
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
      lazygit = { enabled = true },
      indent = {
        enabled = true,
        scope = { hl = 'SignColumn' },
        animate = { enabled = false },
      },
      picker = { enable = true },
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
    },
  }
}, {
  ui = { border = 'rounded' },
})
