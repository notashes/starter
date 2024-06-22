require "nvchad.options"

-- add yours here!
local opt = vim.opt
local o = vim.o

opt.scrolloff = 15
opt.relativenumber = true

-- vim.lsp.inlay_hint.enable(0, false)
-- o.cursorlineopt ='both' -- to enable cursorline!
--
-- tab should be 4 spaces
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
