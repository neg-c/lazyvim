local M = {}

function M.apply(theme, colorscheme)
  require("nvconfig").base46.theme = theme
  require("base46").load_all_highlights()
  vim.g.colors_name = colorscheme or theme
end

return M
