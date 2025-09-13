-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- FORCE MYSELF to use hjkl instead of arrow keys
local function scold(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = "Stop using arrows!" })
end

-- Replace arrow keys with a funny warning
local arrows = {
  Up = "Use 'k' instead!",
  Down = "Use 'j' instead!",
  Left = "Use 'h' instead!",
  Right = "Use 'l' instead!",
}

for key, message in pairs(arrows) do
  for _, mode in ipairs({ "n" }) do
    vim.keymap.set(mode, "<" .. key .. ">", function()
      scold(message)
    end, { noremap = true, silent = true })
  end
end
