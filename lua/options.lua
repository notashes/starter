require "nvchad.options"

-- add yours here!
local opt = vim.opt
local o = vim.o

opt.scrolloff = 15
vim.opt.wrap = false
opt.relativenumber = true

-- o.cursorlineopt ='both' -- to enable cursorline!
--
-- tab should be 4 spaces
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4

-- use undodir instead of backups
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.config/undodir"
vim.opt.undofile = true
