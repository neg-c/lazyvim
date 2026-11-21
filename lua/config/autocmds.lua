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

-- The explorer list is as tall as the window, and the rows under the last file
-- are empty. The cursor can sit on one of those rows while the window is
-- already at the top, so the scroll wheel does nothing.
local wheel_up = vim.api.nvim_replace_termcodes("<ScrollWheelUp>", true, false, true)
local wheel_down = vim.api.nvim_replace_termcodes("<ScrollWheelDown>", true, false, true)

local function snap_picker_list_cursor()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "snacks_picker_list" and vim.api.nvim_win_is_valid(win) then
      local row = vim.api.nvim_win_get_cursor(win)[1]
      local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""
      if not line:find("%S") then
        for i = row - 1, 1, -1 do
          local prev = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1] or ""
          if prev:find("%S") then
            vim.api.nvim_win_set_cursor(win, { i, 0 })
            break
          end
        end
      end
    end
  end
end

vim.on_key(function(key)
  if key ~= wheel_up and key ~= wheel_down then
    return
  end
  vim.schedule(snap_picker_list_cursor)
end)

-- Image viewing is off, and checkhealth still errors for it.
local image = require("snacks.image")
local image_health = image.health
function image.health()
  if not (Snacks.config.image and Snacks.config.image.enabled) then
    return
  end
  image_health()
end
