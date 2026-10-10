return {
  {
    "yetone/avante.nvim",
    dependencies = {
      { "ColinKennedy/mega.cmdparse", dependencies = { "ColinKennedy/mega.logging" } },
    },
    keys = {
      { "<leader>am", "<cmd>AvanteACPModes<CR>", desc = "Select ACP mode" },
      { "<leader>aM", "<cmd>AvanteACPModels<CR>", desc = "Select ACP model" },
      { "<leader>ap", false },
    },
    opts = {
      provider = "cursor",
      mode = "agentic",
      acp_providers = {
        cursor = {
          command = vim.fn.exepath("agent"),
          args = { "acp" },
          auth_method = "cursor_login",
          env = {
            HOME = vim.env.HOME,
            PATH = vim.env.PATH,
          },
        },
      },
    },
  },
}
