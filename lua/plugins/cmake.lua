return {
  {
    "Civitasv/cmake-tools.nvim",
    opts = {
      cmake_automatic_configuration = false,
      cmake_regenerate_on_save = false,
      cmake_use_preset = true,
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
      cmake_compile_commands_options = {
        action = "soft_link",
        target = vim.loop.cwd,
      },
      cmake_executor = {
        name = "quickfix",
        opts = {},
      },
      cmake_runner = {
        name = "terminal",
        opts = {},
      },
    },
    keys = {
      { "<leader>cg", "<cmd>CMakeGenerate<cr>", desc = "CMake Generate" },
      { "<leader>cb", "<cmd>CMakeBuild<cr>", desc = "CMake Build" },
      { "<leader>cr", "<cmd>CMakeRun<cr>", desc = "CMake Run" },
      { "<leader>ct", "<cmd>CMakeRunTest<cr>", desc = "CMake Test" },
      { "<leader>cT", "<cmd>CMakeSelectBuildTarget<cr>", desc = "CMake Target" },
      { "<leader>cp", "<cmd>CMakeSelectConfigurePreset<cr>", desc = "CMake Preset" },
      { "<leader>cs", "<cmd>CMakeSettings<cr>", desc = "CMake Settings" },
    },
  },
}
