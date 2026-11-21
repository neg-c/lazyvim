local agent = vim.fn.expand("~/.local/bin/agent")
if vim.fn.executable(agent) == 0 then
  agent = vim.fn.exepath("agent")
end

return {
  {
    "yetone/avante.nvim",
    dependencies = {
      { "ColinKennedy/mega.cmdparse", dependencies = { "ColinKennedy/mega.logging" } },
    },
    -- Ensure the new :Avante command can lazy-load the plugin.
    cmd = {
      "Avante",
      "AvanteAsk",
      "AvanteBuild",
      "AvanteChat",
      "AvanteClear",
      "AvanteEdit",
      "AvanteFocus",
      "AvanteModels",
      "AvanteRefresh",
      "AvanteShowRepoMap",
      "AvanteStop",
      "AvanteSwitchProvider",
    },
    -- Override LazyVim extras that still bind deprecated Avante* aliases.
    keys = {
      { "<leader>aa", "<cmd>AvanteAsk<CR>", desc = "Ask Avante" },
      { "<leader>ac", "<cmd>AvanteChat<CR>", desc = "Chat with Avante" },
      { "<leader>ae", "<cmd>AvanteEdit<CR>", desc = "Edit Avante", mode = { "n", "v" } },
      { "<leader>af", "<cmd>AvanteFocus<CR>", desc = "Focus Avante" },
      { "<leader>ah", "<cmd>Avante resume<CR>", desc = "Avante History" },
      { "<leader>am", "<cmd>Avante acp modes<CR>", desc = "Select ACP mode" },
      { "<leader>aM", "<cmd>Avante acp models<CR>", desc = "Select ACP model" },
      { "<leader>an", "<cmd>AvanteChatNew<CR>", desc = "New Avante Chat" },
      { "<leader>ap", false },
      { "<leader>ar", "<cmd>AvanteRefresh<CR>", desc = "Refresh Avante" },
      { "<leader>as", "<cmd>AvanteStop<CR>", desc = "Stop Avante" },
      { "<leader>at", "<cmd>Avante toggle<CR>", desc = "Toggle Avante" },
    },
    opts = {
      provider = "cursor",
      mode = "agentic",
      acp_providers = {
        cursor = {
          -- Absolute path: Hyprland-launched nvim often lacks ~/.local/bin on PATH,
          -- so vim.fn.exepath("agent") was empty and ACP never started.
          command = agent,
          args = { "acp" },
          auth_method = "cursor_login",
          env = {
            HOME = vim.env.HOME,
            PATH = vim.fn.expand("~/.local/bin") .. ":" .. (vim.env.PATH or ""),
          },
        },
      },
    },
  },
}
