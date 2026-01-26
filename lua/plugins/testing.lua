return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "rouge8/neotest-rust",  -- Rust adapter
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-rust") {
                        args = { "--no-capture" },
                        dap_adapter = "codelldb",
                    }
                },
                quickfix = {
                    enabled = true,
                    open = false,
                },
                status = {
                    enabled = true,
                    signs = true,
                    virtual_text = true,
                },
                icons = {
                    passed = "✓",
                    running = "●",
                    failed = "✗",
                    skipped = "○",
                    unknown = "?",
                },
                floating = {
                    border = "rounded",
                    max_height = 0.8,
                    max_width = 0.9,
                },
            })

            -- Keymaps for testing
            local map = vim.keymap.set
            local neotest = require("neotest")

            map("n", "<leader>tr", function() neotest.run.run() end, { desc = "Test: Run Nearest" })
            map("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Test: Run File" })
            map("n", "<leader>ta", function() neotest.run.run({ suite = true }) end, { desc = "Test: Run All" })
            map("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "Test: Toggle Summary" })
            map("n", "<leader>to", function() neotest.output.open({ enter = true }) end, { desc = "Test: Show Output" })
            map("n", "<leader>tO", function() neotest.output_panel.toggle() end, { desc = "Test: Toggle Output Panel" })
            map("n", "<leader>tS", function() neotest.run.stop() end, { desc = "Test: Stop" })
            map("n", "<leader>tw", function() neotest.watch.toggle() end, { desc = "Test: Watch" })
            map("n", "<leader>td", function() neotest.run.run({ strategy = "dap" }) end, { desc = "Test: Debug Nearest" })

            -- Jump between tests
            map("n", "[t", function() neotest.jump.prev({ status = "failed" }) end, { desc = "Test: Jump to Prev Failed" })
            map("n", "]t", function() neotest.jump.next({ status = "failed" }) end, { desc = "Test: Jump to Next Failed" })
        end,
    },
}
