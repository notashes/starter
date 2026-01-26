require "nvchad.options"

-- add yours here!
local opt = vim.opt
local o = vim.o

-- Default LSP position encoding to suppress warnings when plugins omit it
do
    local util = vim.lsp.util
    local orig_make_position_params = util.make_position_params

    util.make_position_params = function(win, encoding)
        win = win or 0

        if not encoding then
            local ok, buf = pcall(vim.api.nvim_win_get_buf, win)
            if ok then
                local clients = vim.lsp.get_clients({ bufnr = buf })
                encoding = (clients[1] and clients[1].offset_encoding) or "utf-16"
            else
                encoding = "utf-16"
            end
        end

        return orig_make_position_params(win, encoding)
    end
end

opt.scrolloff = 15
-- vim.opt.wrap = false
opt.relativenumber = true  -- Change to false if you want absolute line numbers

-- Option to disable fold column (remove the leftmost column)
-- opt.foldcolumn = "0"  -- Uncomment to hide fold column

-- o.cursorlineopt ='both' -- to enable cursorline!
--
-- tab should be 4 spaces
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4

-- use undodir instead of backups
vim.opt.wrap = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.config/undodir"
vim.opt.undofile = true

if vim.g.neovide then
    local alpha = function()
      return string.format("%x", math.floor(255 * vim.g.transparency))
    end
    -- g:neovide_opacity should be 0 if you want to unify transparency of content and title bar.
    vim.g.neovide_opacity = 0.4
    vim.g.transparency = 0.8
    -- vim.g.neovide_background_color = "#0f1117" .. alpha()
    vim.g.neovide_window_blurred = true
    vim.g.neovide_show_border = true
    vim.g.neovide_input_macos_option_key_is_meta = 'both'
    vim.g.neovide_background_color = "#0c0d11" .. alpha()
end

-- ===== QUALITY OF LIFE IMPROVEMENTS =====

-- Better diagnostics display
vim.diagnostic.config({
    virtual_text = {
        prefix = "●",
        source = "if_many",
        spacing = 4,
    },
    float = {
        source = "always",
        border = "rounded",
        header = "",
        prefix = "",
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

-- Better completion and LSP experience
o.updatetime = 250  -- Faster completion and diagnostics
o.timeoutlen = 300  -- Faster which-key popup

-- Better search
o.ignorecase = true  -- Ignore case in search
o.smartcase = true   -- Unless uppercase is used
o.hlsearch = true    -- Highlight search results
o.incsearch = true   -- Incremental search

-- Better splits (already set by NvChad but good to have)
o.splitbelow = true
o.splitright = true

-- Better mouse support
o.mouse = "a"

-- System clipboard integration
o.clipboard = "unnamedplus"

-- Show invisible characters (useful for debugging whitespace)
o.list = true
o.listchars = "tab:→ ,trail:·,nbsp:␣,extends:⟩,precedes:⟨"

-- Better diff
o.diffopt = "internal,filler,closeoff,hiddenoff,algorithm:histogram,indent-heuristic"

-- Better command line
o.cmdheight = 1
o.showcmd = true

-- Spell checking (disabled by default, enable with :set spell)
o.spell = false
o.spelllang = "en_us"

-- Better folding (for ufo plugin)
o.foldlevel = 99
o.foldlevelstart = 99
o.foldenable = true
o.foldcolumn = "0"  -- No fold column (removes leftmost numbers)

-- Auto-save on focus lost
vim.api.nvim_create_autocmd("FocusLost", {
    pattern = "*",
    callback = function()
        vim.cmd("silent! wa")
    end,
    desc = "Auto-save on focus lost",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
    desc = "Highlight on yank",
})

-- Remember last position in file
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*",
    callback = function()
        local line = vim.fn.line("'\"")
        if line > 1 and line <= vim.fn.line("$") then
            vim.cmd('normal! g`"')
        end
    end,
    desc = "Remember last cursor position",
})

-- Auto-create directories when saving a file
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local dir = vim.fn.expand("<afile>:p:h")
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, "p")
        end
    end,
    desc = "Auto-create directories",
})

-- Close certain windows with 'q'
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "qf", "help", "man", "lspinfo", "spectre_panel", "startuptime" },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
    desc = "Close with q",
})

-- Better formatting for Rust
vim.api.nvim_create_autocmd("FileType", {
    pattern = "rust",
    callback = function()
        -- Set comment string for rust
        vim.bo.commentstring = "// %s"

        -- Set text width for comments
        vim.bo.textwidth = 100
    end,
    desc = "Rust-specific settings",
})
