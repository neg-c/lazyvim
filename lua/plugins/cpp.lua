local function link_compile_commands(root)
  local dest = root .. "/compile_commands.json"
  local linked = vim.uv.fs_lstat(dest)
  if linked and not vim.uv.fs_stat(dest) then
    vim.uv.fs_unlink(dest)
    linked = nil
  end
  if linked then
    return
  end

  local candidates = {}
  local build = root .. "/build/compile_commands.json"
  if vim.uv.fs_stat(build) then
    candidates[#candidates + 1] = build
  end
  local build_dir = root .. "/build"
  if vim.uv.fs_stat(build_dir) then
    for name, typ in vim.fs.dir(build_dir) do
      if typ == "directory" then
        local path = build_dir .. "/" .. name .. "/compile_commands.json"
        if vim.uv.fs_stat(path) then
          candidates[#candidates + 1] = path
        end
      end
    end
  end
  table.sort(candidates, function(a, b)
    local sa = vim.uv.fs_stat(a)
    local sb = vim.uv.fs_stat(b)
    return ((sa and sa.mtime.sec) or 0) > ((sb and sb.mtime.sec) or 0)
  end)
  if candidates[1] then
    vim.uv.fs_symlink(candidates[1], dest)
  end
end

return {
  { import = "lazyvim.plugins.extras.dap.core" }, -- optional, for debugging
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      local clangd = opts.servers.clangd or {}
      opts.servers.clangd = clangd

      -- Preset builds write the database under build/<preset>/, which clangd
      -- does not search. Link it to the workspace root and pass that directory.
      clangd.root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local root = vim.fs.root(fname, "CMakePresets.json") or vim.fs.root(fname, ".git")
        if not root then
          return
        end
        link_compile_commands(root)
        on_dir(root)
      end

      local prev_on_init = clangd.on_init
      clangd.on_init = function(client, init_result)
        if prev_on_init then
          prev_on_init(client, init_result)
        end
        local root = client.config.root_dir
        if not root or root == "" then
          return
        end
        link_compile_commands(root)
      end

      -- Replace LazyVim's cmd. clangd 23 rejects a bare --function-arg-placeholders.
      local root = vim.fs.root(vim.fn.getcwd(), "CMakePresets.json") or vim.fn.getcwd()
      link_compile_commands(root)
      clangd.cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders=true",
        "--fallback-style=llvm",
        "--compile-commands-dir=" .. root,
      }
      return opts
    end,
  },
}
