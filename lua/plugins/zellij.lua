-- Zellij integration: seamless navigation with Alt+hjkl
--
-- Alt+h/j/k/l navigates everywhere:
--   In neovim normal mode: moves between splits, crosses into zellij panes at edges
--   In neovim terminal mode: same behavior
--   In zellij shell pane: zellij handles it directly (shared_except "locked")
--
-- No conflict with LuaSnip (Alt+j/l in insert mode) because
-- these bindings are only for normal + terminal mode.
--
-- Overrides NvChad's default Alt+h (horizontal term), Alt+v (vertical term),
-- Alt+i (floating term) — not needed since we use zellij for terminals.

return {
    {
        "swaits/zellij-nav.nvim",
        lazy = true,
        event = "VeryLazy",
        keys = {
            { "<A-h>", "<cmd>ZellijNavigateLeftTab<cr>", mode = { "n", "t" }, silent = true, desc = "Navigate left or tab" },
            { "<A-j>", "<cmd>ZellijNavigateDown<cr>", mode = { "n", "t" }, silent = true, desc = "Navigate down" },
            { "<A-k>", "<cmd>ZellijNavigateUp<cr>", mode = { "n", "t" }, silent = true, desc = "Navigate up" },
            { "<A-l>", "<cmd>ZellijNavigateRightTab<cr>", mode = { "n", "t" }, silent = true, desc = "Navigate right or tab" },
        },
        opts = {},
        init = function()
            vim.api.nvim_create_autocmd("VimLeave", {
                pattern = "*",
                callback = function()
                    if os.getenv("ZELLIJ") then
                        os.execute("zellij action switch-mode normal")
                    end
                end,
            })
        end,
    },
}
