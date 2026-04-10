return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        neocmake = {
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("CMakePresets.json", "CMakeLists.txt")(fname) or util.dirname(fname)
          end,
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
