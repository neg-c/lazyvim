local snippet = [[
#include <string>
#include <string_view>

namespace demo {

enum class Status { Ok, Missing, Failed };

struct Job {
  std::string name;
  int retries = 3;

  // Skip empty input and exhausted retries.
  Status run(std::string_view input) const {
    if (input.empty() || retries <= 0) {
      return Status::Missing;
    }
    return name == input ? Status::Ok : Status::Failed;
  }
};

} // namespace demo

int main() {
  const demo::Job job{ "build", 2 };
  const auto status = job.run("build");
  return status == demo::Status::Ok ? 0 : 1;
}
]]

local scheme_file = vim.fn.stdpath("state") .. "/colorscheme"

local function saved_colorscheme()
  if vim.fn.filereadable(scheme_file) == 0 then
    return nil
  end
  local name = vim.trim(vim.fn.readfile(scheme_file)[1] or "")
  return name ~= "" and name or nil
end

local function picker_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
    if ft == "snacks_picker_input" or ft == "snacks_picker_list" then
      return true
    end
  end
  return false
end

-- Remember a confirmed colorscheme. Skip startup and picker preview, which
-- also fire ColorScheme while the previous scheme is still the one to keep.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("persist_colorscheme", { clear = true }),
  callback = function()
    if not vim.g.colorscheme_persist or picker_open() then
      return
    end
    local name = vim.g.colors_name
    if not name or name == "" or name == "default" then
      return
    end
    vim.fn.writefile({ name }, scheme_file)
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    vim.g.colorscheme_persist = true
  end,
})

local function show_snippet(ctx)
  if not ctx.preview.win:valid() then
    return
  end
  ctx.preview:reset()
  ctx.preview:set_title(ctx.item.text)
  ctx.preview:set_lines(vim.split(snippet, "\n", { plain = true }))
  ctx.preview:highlight({ ft = "cpp" })
end

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        local name = saved_colorscheme()
        if name and pcall(vim.cmd.colorscheme, name) then
          return
        end
        require("tokyonight").load()
      end,
    },
  },
  {
    "nvchad/base46",
    branch = "v3.0",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>uC",
        function()
          Snacks.picker.colorschemes()
        end,
        desc = "Colorscheme with Preview",
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        win = {
          input = {
            wo = {
              -- The prompt is one line, with the match count on the right.
              -- The global sidescrolloff scrolls that line before it is full.
              sidescrolloff = 0,
            },
          },
        },
        sources = {
          colorschemes = {
            preview = function(ctx)
              Snacks.picker.preview.colorscheme(ctx)
              show_snippet(ctx)
              vim.schedule(function()
                show_snippet(ctx)
              end)
            end,
          },
        },
      },
    },
  },
}
