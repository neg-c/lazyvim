return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        neocmake = {
          root_markers = { "CMakePresets.json", "CMakeLists.txt" },
          init_options = {
            scan_cmake_in_package = false,
            semantic_token = true,
            format = { enable = true },
            lint = { enable = true },
          },
        },
      },
    },
  },
}
