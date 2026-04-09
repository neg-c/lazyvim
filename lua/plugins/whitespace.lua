return {
  {
    "ntpeters/vim-better-whitespace",
    event = "BufReadPre", -- lazy load for performance
    config = function()
      -- highlight trailing whitespace
      vim.g.better_whitespace_enabled = 1

      -- DON'T auto remove whitespace unless you want it
      vim.g.strip_whitespace_on_save = 0

      -- optional: disable in certain filetypes
      vim.g.better_whitespace_filetypes_blacklist = {
        "diff",
        "gitcommit",
        "markdown",
      }

      -- optional: custom highlight color
      vim.cmd([[highlight ExtraWhitespace guibg=#ff0000]])
    end,
  },
}
