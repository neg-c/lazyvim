-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Noice owns vim.notify and flushes on a timer. Snacks' health probe only waits
-- 500ms, so hand that probe straight to Snacks.
local notify = vim.notify
vim.notify = function(msg, level, opts)
  if type(opts) == "table" and opts.checkhealth then
    return require("snacks.notifier").notify(msg, level, opts)
  end
  return notify(msg, level, opts)
end

-- Image viewing is off, and checkhealth still errors for it.
local image = require("snacks.image")
local image_health = image.health
function image.health()
  if not (Snacks.config.image and Snacks.config.image.enabled) then
    return
  end
  image_health()
end
