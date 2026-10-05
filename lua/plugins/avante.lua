return {
  {
    "yetone/avante.nvim",
    dependencies = {
      { "ColinKennedy/mega.cmdparse", dependencies = { "ColinKennedy/mega.logging" } },
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
