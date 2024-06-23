require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- cool visual move command
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- half page move disorientation
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Search term stays in the middle
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- map for resizing vertical splits
map("n", "<M-Right>", ":vertical resize +1<CR>")
map("n", "<M-Left>", ":vertical resize -1<CR>")

-- get rid of all the trailing whitespace
map("n", "<leader>hw", [[:%s/\s\+$//e<CR>]])

-- map for session manager
map("n", "<leader>fs", function ()
    require('telescope').extensions.possession.list()
end)

-- greatest remap ever
map("v", "<leader>p", "\"_dP")
map("n", "<leader>d", "\"_d")
map("v", "<leader>d", "\"_d")

-- Add remote-nvim shortcut
map("n", "<leader>rs", ":RemoteStart<CR>")

-- Add a toggle for inlay hints
map("n", "<leader>i", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, { desc = "Toggle inlay hints" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
-- experimental
map("n", "<A-k>", "<cmd>cnext<CR>zz")
map("n", "<A-j>", "<cmd>cprev<CR>zz")
map("n", "<leader>k", "<cmd>lnext<CR>zz")
map("n", "<leader>j", "<cmd>lprev<CR>zz")

-- telescope stuff
map("n", "<leader>td", "<cmd>Telescope diagnostics<CR>", { desc = "Telescope Diagonistcs " })
map("n", "<leader>lr", "<cmd>Telescope lsp_references<CR>", { desc = "Telescope Lsp References" })
map("n", "<leader>ld", "<cmd>Telescope lsp_definitions<CR>", { desc = "Telescope Definition" })
map("n", "<leader>li", "<cmd>Telescope lsp_implementations<CR>", { desc = "Telescope Implementations" })

-- Neovide Settings
if vim.g.neovide == true then
  vim.g.neovide_scale_factor = 0.8
  vim.api.nvim_set_keymap("n", "<C-=>", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>", { silent = true })
  vim.api.nvim_set_keymap("n", "<C-->", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>", { silent = true })
  vim.api.nvim_set_keymap("n", "<C-0>", ":lua vim.g.neovide_scale_factor = 1<CR>", { silent = true })
end
