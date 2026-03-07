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

            map("n", "<leader>nr", function() neotest.run.run() end, { desc = "Test: Run Nearest" })
            map("n", "<leader>nf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Test: Run File" })
            map("n", "<leader>na", function() neotest.run.run({ suite = true }) end, { desc = "Test: Run All" })
            map("n", "<leader>ns", function() neotest.summary.toggle() end, { desc = "Test: Toggle Summary" })
            map("n", "<leader>no", function() neotest.output.open({ enter = true }) end, { desc = "Test: Show Output" })
            map("n", "<leader>nO", function() neotest.output_panel.toggle() end, { desc = "Test: Toggle Output Panel" })
            map("n", "<leader>nS", function() neotest.run.stop() end, { desc = "Test: Stop" })
            map("n", "<leader>nw", function() neotest.watch.toggle() end, { desc = "Test: Watch" })
            map("n", "<leader>nd", function() neotest.run.run({ strategy = "dap" }) end, { desc = "Test: Debug Nearest" })

            -- Jump between tests
            map("n", "[t", function() neotest.jump.prev({ status = "failed" }) end, { desc = "Test: Jump to Prev Failed" })
            map("n", "]t", function() neotest.jump.next({ status = "failed" }) end, { desc = "Test: Jump to Next Failed" })

            require("which-key").add({ { "<leader>n", group = "Neotest" } })
        end,
    },
}
