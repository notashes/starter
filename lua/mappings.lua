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

-- Search term stays in the middle (handled by hlslens with zzzv)
-- map("n", "n", "nzzzv")
-- map("n", "N", "Nzzzv")

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

-- Override nvim-tree toggle to prevent conflicts with DAP UI
local last_non_tree_win

local function is_dapui_open()
    local dapui_ok = pcall(require, "dapui")
    if not dapui_ok then
        return false
    end

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_name = vim.api.nvim_buf_get_name(buf)
        if buf_name:match("DAP") then
            return true
        end
    end

    return false
end

local function safe_nvimtree_toggle()
    local nvim_tree_api = require("nvim-tree.api")

    if is_dapui_open() then
        vim.notify("Close DAP UI first (Space+d+u) before opening file tree", vim.log.levels.WARN)
        return
    end

    local tree_was_visible = nvim_tree_api.tree.is_visible()
    nvim_tree_api.tree.toggle()

    if tree_was_visible then
        last_non_tree_win = nil
    end
end

-- <leader>e should jump to the tree when it is open, or return to code when already there
local function nvimtree_focus_or_cycle()
    local nvim_tree_api = require("nvim-tree.api")
    local tree_visible = nvim_tree_api.tree.is_visible()
    local current_win = vim.api.nvim_get_current_win()
    local current_buf = vim.api.nvim_win_get_buf(current_win)
    local in_tree = vim.bo[current_buf].filetype == "NvimTree"

    if tree_visible then
        if in_tree then
            if last_non_tree_win and vim.api.nvim_win_is_valid(last_non_tree_win) then
                vim.api.nvim_set_current_win(last_non_tree_win)
            else
                vim.cmd("wincmd p")
            end
        else
            last_non_tree_win = current_win
            nvim_tree_api.tree.focus()
        end
    else
        last_non_tree_win = current_win
        safe_nvimtree_toggle()
        if nvim_tree_api.tree.is_visible() then
            nvim_tree_api.tree.focus()
        end
    end
end

map("n", "<C-n>", safe_nvimtree_toggle, { desc = "Toggle nvim-tree (safe)" })
map("n", "<leader>e", nvimtree_focus_or_cycle, { desc = "Focus nvim-tree (safe)" })

map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>", { desc = "Save" })
-- experimental
-- map("n", "<A-k>", "<cmd>cnext<CR>zz")
-- map("n", "<A-j>", "<cmd>cprev<CR>zz")
map("n", "<leader>k", "<cmd>lnext<CR>zz")
map("n", "<leader>j", "<cmd>lprev<CR>zz")

-- telescope stuff
map("n", "<leader>td", "<cmd>Telescope diagnostics<CR>", { desc = "Telescope Diagonistcs " })
-- Git (Telescope) — register which-key group
local wk = require("which-key")
wk.add({
    { "<leader>b", group = "Buffer" },
    { "<leader>c", group = "Code/Crates" },
    { "<leader>d", group = "Debug" },
    { "<leader>f", group = "Find/Files" },
    { "<leader>g", group = "Git" },
    { "<leader>h", group = "Hunk" },
    { "<leader>l", group = "LSP" },
    { "<leader>m", group = "Macro/Move/Mark" },
    { "<leader>n", group = "Neotest" },
    { "<leader>q", group = "Quickfix" },
    { "<leader>r", group = "Rust/Run" },
    { "<leader>s", group = "Search" },
    { "<leader>t", group = "Terminal" },
    { "<leader>w", group = "Window/Save" },
    { "<leader>x", group = "Trouble" },
})

map("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "Git Status" })
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "Git Commits" })
map("n", "<leader>gC", "<cmd>Telescope git_bcommits<CR>", { desc = "Git Buffer Commits" })
map("n", "<leader>gb", "<cmd>Telescope git_branches<CR>", { desc = "Git Branches" })
map("n", "<leader>gS", "<cmd>Telescope git_stash<CR>", { desc = "Git Stash" })
map("n", "<leader>lr", "<cmd>Telescope lsp_references<CR>", { desc = "Telescope Lsp References" })
map("n", "<leader>ld", "<cmd>Telescope lsp_definitions<CR>", { desc = "Telescope Definition" })
map("n", "<leader>li", "<cmd>Telescope lsp_implementations<CR>", { desc = "Telescope Implementations" })
map("n", "<leader>tc", "<cmd>Telescope diagnostics bufnr=0<CR>", { desc = "Telescope Diagnostics Current Buffer" })

map("n", "<A-u>", vim.cmd.UndotreeToggle, { desc = "Toggle UndoTree"})

-- Neovide Settings
if vim.g.neovide == true then
  vim.g.neovide_scale_factor = 0.8
  vim.api.nvim_set_keymap("n", "<C-=>", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>", { silent = true })
  vim.api.nvim_set_keymap("n", "<C-->", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>", { silent = true })
  vim.api.nvim_set_keymap("n", "<C-0>", ":lua vim.g.neovide_scale_factor = 1<CR>", { silent = true })
end

-- luasnip keymaps
local ls = require("luasnip")

vim.keymap.set({"i"}, "<A-K>", function() ls.expand() end, {silent = true})
vim.keymap.set({"i", "s"}, "<A-l>", function() ls.jump( 1) end, {silent = true})
vim.keymap.set({"i", "s"}, "<A-j>", function() ls.jump(-1) end, {silent = true})

vim.keymap.set({"i", "s"}, "<C-E>", function()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end, {silent = true})

-- Scroll inside noice hover/signature windows
vim.keymap.set({ "n", "i", "s" }, "<c-f>", function()
    if not require("noice.lsp").scroll(4) then return "<c-f>" end
end, { silent = true, expr = true, desc = "Scroll hover forward" })

vim.keymap.set({ "n", "i", "s" }, "<c-b>", function()
    if not require("noice.lsp").scroll(-4) then return "<c-b>" end
end, { silent = true, expr = true, desc = "Scroll hover backward" })

-- Format with conform.nvim
map("n", "<leader>fm", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format Buffer" })

-- Better diagnostic navigation
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
map("n", "]e", function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next Error" })
map("n", "[e", function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Prev Error" })
map("n", "]w", function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
end, { desc = "Next Warning" })
map("n", "[w", function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
end, { desc = "Prev Warning" })

-- Show diagnostics in floating window
map("n", "gl", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

-- Quick access to Cargo.toml
map("n", "<leader>fC", function()
    local cargo_toml = vim.fn.findfile("Cargo.toml", ".;")
    if cargo_toml ~= "" then
        vim.cmd("edit " .. cargo_toml)
    else
        vim.notify("Cargo.toml not found", vim.log.levels.WARN)
    end
end, { desc = "Open Cargo.toml" })

-- Quick access to main.rs or lib.rs
map("n", "<leader>fe", function()
    local main_rs = vim.fn.findfile("src/main.rs", ".;")
    local lib_rs = vim.fn.findfile("src/lib.rs", ".;")
    if main_rs ~= "" then
        vim.cmd("edit " .. main_rs)
    elseif lib_rs ~= "" then
        vim.cmd("edit " .. lib_rs)
    else
        vim.notify("src/main.rs or src/lib.rs not found", vim.log.levels.WARN)
    end
end, { desc = "Open main.rs/lib.rs" })

-- Save all buffers
map("n", "<leader>wa", "<cmd>wa<CR>", { desc = "Save All Buffers" })

-- Close all other buffers
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>", { desc = "Close Other Buffers" })

-- Clear search highlighting
map("n", "<leader>nh", "<cmd>noh<CR>", { desc = "Clear Search Highlight" })

-- Better window resizing
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease Window Height" })

-- Quick save and format
map("n", "<leader>w", function()
    vim.cmd("write")
    require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Save and Format" })

-- Join lines without moving cursor
map("n", "J", "mzJ`z", { desc = "Join Lines" })

-- Toggle quickfix window
map("n", "<leader>q", function()
    for _, win in ipairs(vim.fn.getwininfo()) do
        if win.quickfix == 1 then
            vim.cmd("cclose")
            return
        end
    end
    vim.cmd("copen")
end, { desc = "Toggle Quickfix" })
