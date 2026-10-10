-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_check_order = false
vim.g.autowrite = false

-- Providers installed under $HOME because system packages need root.
vim.g.node_host_prog = vim.fn.expand("~/.local/node_modules/neovim/bin/cli.js")
vim.g.perl_host_prog = vim.fn.expand("~/.local/bin/nvim-perl")
vim.g.ruby_host_prog = vim.fn.expand("~/.local/share/gem/ruby/3.2.0/bin/neovim-ruby-host")

-- Keep the start of a line on screen when the explorer makes the window narrow.
-- sidescroll 0 centers the cursor. sidescrolloff 8 then chops that many columns
-- off the left (target_link_libraries shown as ink_libraries).
vim.opt.sidescroll = 1
vim.opt.sidescrolloff = 0
