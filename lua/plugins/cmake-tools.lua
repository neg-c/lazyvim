return {
  {
    "Civitasv/cmake-tools.nvim",
    opts = {
      cmake_automatic_configuration = false,
      cmake_regenerate_on_save = false,
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
    },
  },
}
