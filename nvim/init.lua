-- Install packer
local execute = vim.api.nvim_command

local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '.. install_path)
end

vim.api.nvim_exec([[
  augroup Packer
    autocmd!
    autocmd BufWritePost init.lua PackerCompile
  augroup end
]], false)

-- Packer.nvim Plugins
require('packer').startup({
    function(use)
        -- Let Packer manage itself
        use {'wbthomason/packer.nvim', opt = true}

	      -- colors!
	      use {'morhetz/gruvbox'}

	      -- feel the powerline!
	      use {'itchyny/lightline.vim'}

	      -- UI to select/autocomplete
	      use {'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}} }

	      -- LSP Client
	      use 'neovim/nvim-lspconfig'
        use 'glepnir/lspsaga.nvim'

	      -- Autocompletion plugin
	      use 'hrsh7th/nvim-compe'

        -- Nerdcommenter, pretty great
        use 'preservim/nerdcommenter'

        -- Treesitter
        use 'nvim-treesitter/nvim-treesitter'

        -- Flutter integrations
        use {'akinsho/flutter-tools.nvim', requires='nvim-lua/plenary.nvim'}
    end,
})

-- Settings

-- Mouse Mode on
vim.o.mouse = 'a'

-- Colors!
vim.o.termguicolors = true
vim.cmd[[colorscheme gruvbox]]
vim.g.gruvbox_bold = true

-- Filetype plugin
vim.cmd 'syntax enable'
vim.cmd 'filetype plugin indent on'

-- Tabstops logic
-- Not 100% sure how to remap to lua...
vim.cmd[[
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

au filetype gdscript3 setl tabstop=4 shiftwidth=4 softtabstop=4 noexpandtab
au filetype go setl tabstop=4 shiftwidth=4 softtabstop=4 noexpandtab
au filetype golang setl tabstop=4 shiftwidth=4 softtabstop=4 noexpandtab
]]

-- Remaps
---- Remap 'tn' in insert mode to Escape
vim.api.nvim_set_keymap('i', 'tn', [[<ESC>]], {noremap = true, silent = true})
---- Leader
vim.g.mapleader = ','


-- Configure and map Telescope
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ["<C-u>"] = false,
        ["<C-d>"] = false,
      },
    },
    file_ignore_patterns = {
      'node_modules'
    },
    generic_sorter =  require'telescope.sorters'.get_fzy_sorter,
    file_sorter =  require'telescope.sorters'.get_fzy_sorter,
    set_env = { ['COLORTERM'] = 'truecolor' },
  }
}
vim.api.nvim_set_keymap('n', '<leader>ff', [[<cmd>lua require('telescope.builtin').find_files()<cr>]], { noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>fb', [[<cmd>lua require('telescope.builtin').buffers()<cr>]], { noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>fg', [[<cmd>lua require('telescope.builtin').live_grep()<cr>]], { noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>fh', [[<cmd>lua require('telescope.builtin').help_tags()<cr>]], { noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>fc', [[<cmd>lua require('telescope.builtin').commands()<cr>]], { noremap = true, silent = true})

-- Configure and map LSP
local nvim_lsp = require('lspconfig')
local on_attach = function(_client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap=true, silent=true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
end

-- LSP Server
local util = require('lspconfig/util')

-- do this by hand, instead of trying to be fancy for now...
require('lspconfig')['gopls'].setup {
  on_attach = on_attach,
  root_dirs = util.root_pattern('.hg', 'go.mod')
}

-- Autoformat golang on save
-- Kind of funky to go lua->vim->lua...
vim.cmd[[autocmd BufWritePre *.go lua vim.lsp.buf.formatting_sync(nil, 1000)]]


require('lspconfig')['tsserver'].setup {
  on_attach = on_attach,
  root_dirs = util.root_pattern('package.json', 'tsconfig.json', 'jsconfig.json', '.hg')
}
-- Autoformat ts on save.
-- Maybe need to do all of these
-- Kind of funky to go lua->vim->lua...
vim.cmd[[autocmd BufWritePre *.tsx lua vim.lsp.buf.formatting_sync(nil, 1000)]]

require('lspconfig')['gdscript'].setup {
  on_attach = on_attach,
  root_dir = util.root_pattern('project.godot', '.hg')
}

-- DISABLED - flutter does this for us
-- require('lspconfig')['dartls'].setup {
--   on_attach = on_attach,
--   root_dir = util.root_pattern('pubspec.yaml', '.hg')
-- }
require('flutter-tools').setup {
  lsp = {
    on_attach = on_attach,
  }
}
require('telescope').load_extension('flutter')

-- vim.lsp.set_log_level("debug")
-- Compre settings
-- needed to make it work...
vim.o.completeopt="menuone,noinsert"

-- Compe setup
require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = true;

  source = {
    path = true;
    nvim_lsp = true;
  };
}

vim.cmd[[
inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
]]

-- Treesitter setup

-- LSPSaga setup
require('lspsaga').init_lsp_saga()
vim.api.nvim_set_keymap('n', 'gh', [[:Lspsaga lsp_finder<CR>]],
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>ca', [[:Lspsaga code_action<CR>]],
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap('v', '<leader>ca :<C-U>',
                        [[:Lspsaga range_code_action<CR>]],
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'K', [[:Lspsaga hover_doc<CR>]],
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'gs', [[:Lspsaga signature_help<CR>]],
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'gr', [[:Lspsaga rename<CR>]],
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'gd', [[:Lspsaga preview_definition<CR>]],
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>cd',
                        [[:Lspsaga show_line_diagnostics<CR>]],
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>cc',
                        [[:Lspsaga show_line_diagnostics<CR>]],
                        {noremap = true, silent = true})
