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
