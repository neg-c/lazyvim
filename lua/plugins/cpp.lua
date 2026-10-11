local db_watchers = {}

local function same_file(a, b)
  if not a or not b then
    return false
  end
  local ra = vim.uv.fs_realpath(a) or a
  local rb = vim.uv.fs_realpath(b) or b
  return vim.fs.normalize(ra) == vim.fs.normalize(rb)
end

local function newest_compile_commands(root)
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
  return candidates[1]
end

-- The root compile_commands.json is a symlink into build/<preset>/.
-- Neovim watches it with inotifywait --no-dereference, so a rebuild that
-- rewrites the target never reaches clangd until the server starts again.
local function notify_clangd(root)
  local dest = root .. "/compile_commands.json"
  local changes = {
    { uri = vim.uri_from_fname(dest), type = vim.lsp.protocol.FileChangeType.Changed },
  }
  local real = vim.uv.fs_realpath(dest)
  if real and vim.fs.normalize(real) ~= vim.fs.normalize(dest) then
    changes[#changes + 1] = {
      uri = vim.uri_from_fname(real),
      type = vim.lsp.protocol.FileChangeType.Changed,
    }
  end
  for _, client in ipairs(vim.lsp.get_clients({ name = "clangd" })) do
    local client_root = client.config.root_dir
    if client_root and vim.fs.normalize(client_root) == vim.fs.normalize(root) then
      client:notify("workspace/didChangeWatchedFiles", { changes = changes })
    end
  end
end

local function watch_compile_commands(root, database)
  local dir = vim.fs.dirname(database)
  local state = db_watchers[root]
  if state and state.dir == dir then
    return
  end
  if state then
    state.handle:stop()
    state.handle:close()
    if state.timer then
      state.timer:stop()
      state.timer:close()
    end
  end

  local handle = vim.uv.new_fs_event()
  state = { dir = dir, handle = handle, generation = 0 }
  db_watchers[root] = state
  local _, start_err = handle:start(dir, {}, function(err, filename)
    if err or filename ~= "compile_commands.json" then
      return
    end
    if state.timer then
      state.timer:stop()
      state.timer:close()
    end
    state.generation = state.generation + 1
    local generation = state.generation
    state.timer = vim.uv.new_timer()
    state.timer:start(
      300,
      0,
      vim.schedule_wrap(function()
        if db_watchers[root] ~= state or state.generation ~= generation then
          return
        end
        notify_clangd(root)
      end)
    )
  end)
  if start_err then
    handle:close()
    db_watchers[root] = nil
  end
end

local function link_compile_commands(root)
  local dest = root .. "/compile_commands.json"
  local linked = vim.uv.fs_lstat(dest)
  if linked and not vim.uv.fs_stat(dest) then
    vim.uv.fs_unlink(dest)
    linked = nil
  end

  local newest = newest_compile_commands(root)
  if not newest then
    return
  end

  local current = linked and vim.uv.fs_realpath(dest)
  if not same_file(current, newest) then
    if linked then
      vim.uv.fs_unlink(dest)
    end
    vim.uv.fs_symlink(newest, dest)
    notify_clangd(root)
  end
  watch_compile_commands(root, newest)
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
