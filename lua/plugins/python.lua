return {
    {
        "linux-cultist/venv-selector.nvim",
        cmd = "VenvSelect",
        opts = {
            name = {
                "venv",
                ".venv",
            }
        },
        keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv" } },
    },
    {
        "hrsh7th/nvim-cmp",
        opts = function(_, opts)
            opts.auto_brackets = opts.auto_brackets or {}
            table.insert(opts.auto_brackets, "python")
        end,
    },
    {
        "kmontocam/nvim-conda",
        dependencies = { "nvim-lua/plenary.nvim" }
    }
}
