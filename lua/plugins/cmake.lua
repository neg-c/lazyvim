return {
  {
    "mason.nvim",
    opts = function(_, opts)
      -- Mason installs these with python3 -m venv, which fails until
      -- python3.12-venv is installed. cmakelint itself lives in ~/.local/bin.
      opts.ensure_installed = vim.tbl_filter(function(name)
        return name ~= "cmakelint" and name ~= "cmakelang"
      end, opts.ensure_installed or {})
    end,
  },
  {
    "Civitasv/cmake-tools.nvim",
    opts = {
      cmake_automatic_configuration = false,
      cmake_regenerate_on_save = false,
      cmake_use_preset = true,
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
      cmake_compile_commands_options = {
        action = "soft_link",
        target = vim.uv.cwd(),
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
