-- ~/.config/nvim/lua/plugins/auto-save.lua
return {
  {
    "Pocco81/auto-save.nvim",
    lazy = false,
    config = function()
      local auto_save = require("auto-save")

      auto_save.setup({
        enabled = true,
        trigger_events = { "FocusLost", "BufLeave" },
        execution_message = {
          message = function()
            return ""
          end,
          dim = 0,
          cleaning_interval = 0,
        },
      })

      -- important: rebuild autocmds with your custom events
      auto_save.off()
      auto_save.on()
    end,
  },
}
