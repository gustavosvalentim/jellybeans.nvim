-- Run from the repository root: nvim --headless -u NONE -l tests/mini_pick.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())

local function check(opts, palette_name)
  require("jellybeans").setup(opts)
  local colors = assert(require("jellybeans").load(palette_name))
  local expected_bg = not opts.transparent and tonumber(colors.background:sub(2), 16) or nil
  for _, name in ipairs({ "MiniPickNormal", "MiniPickBorder", "MiniPickBorderText" }) do
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    assert(hl.bg == expected_bg, name .. " background does not match editor")
    assert(hl.fg ~= nil, name .. " foreground is missing")
  end
end

for _, palette in ipairs(vim.fn.glob("lua/jellybeans/palettes/*.lua", false, true)) do
  local name = vim.fn.fnamemodify(palette, ":t:r")
  if name ~= "init" then
    for _, transparent in ipairs({ false, true }) do
      for _, flat_ui in ipairs({ false, true }) do
        check({ plugins = { mini = true }, transparent = transparent, flat_ui = flat_ui }, name)
      end
    end
  end
end

-- Standalone mini.pick must activate the integration under lazy.nvim too.
package.loaded.lazy = {}
package.loaded["lazy.core.config"] = { plugins = { ["mini.pick"] = {} } }
check({ plugins = { auto = true } }, "jellybeans")

print("mini.pick highlight checks passed")
