return {
    {
        'mrcjkb/rustaceanvim',
        version = '^4', -- Recommended
        ft = { 'rust' },
        opts = {
            server = {
                on_attach = function(client, bufnr)
                    client.server_capabilities.semanticTokensProvider = nil,
                    vim.keymap.set("n", "<leader>cr", function()
                        vim.cmd.RustLsp("codeAction")
                    end, { desc = "Code Action", buffer = bufnr })
                    vim.keymap.set("n", "<leader>dr", function()
                        vim.cmd.RustLsp("debuggables")
                    end, { desc = "Rust Debuggables", buffer = bufnr })
                    vim.keymap.set("n", "<leader>me", function()
                        vim.cmd.RustLsp("expandMacro")
                    end, { desc = "Expand Macros Recursively", buffer = bufnr })
                    vim.keymap.set("n", "<leader>ce", function()
                        vim.cmd.RustLsp("explainError")
                    end, { desc = "Expand Error", buffer = bufnr })
                    vim.keymap.set("n", "<leader>cd", function()
                        vim.cmd.RustLsp("renderDiagnostic")
                    end, { desc = "Render Diagnostics", buffer = bufnr })
                    vim.keymap.set("n", "K", function()
                        vim.cmd.RustLsp{"hover", "actions"}
                    end, { desc = "Hover Actions", buffer = bufnr })

                    -- normal lsp keymaps
                    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Lsp Go to declaration", buffer = bufnr })
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Lsp Go to definition", buffer = bufnr })
                    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Lsp Go to implementation", buffer = bufnr })
                    vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, { desc = "Show signature help", buffer = bufnr })
                    vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "Go to type definition", buffer = bufnr })
                    vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "Show references", buffer = bufnr })

                    -- map("n", "K", vim.lsp.buf.hover, opts "Lsp hover information")
                end,
                default_settings = {
                    -- rust-analyzer language server configuration
                    ["rust-analyzer"] = {
                        cargo = {
                            allFeatures = true,
                            loadOutDirsFromCheck = true,
                            runBuildScripts = true,
                        },
                        -- Add clippy lints for Rust.
                        checkOnSave = {
                            allFeatures = true,
                            command = "clippy",
                            extraArgs = { "--no-deps" },
                        },
                        procMacro = {
                            enable = true,
                            ignored = {
                                ["async-trait"] = { "async_trait" },
                                ["napi-derive"] = { "napi" },
                                ["async-recursion"] = { "async_recursion" },
                            },
                        },
                    },
                },
            },
        },
        config = function(_, opts)
            vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
        end,
    },

    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                rust_analyzer = {},
                taplo = {
                    keys = {
                        {
                            "K",
                            function()
                                if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
                                    require("crates").show_popup()
                                else
                                    vim.lsp.buf.hover()
                                end
                            end,
                            desc = "Show Crate Documentation",
                        },
                    },
                },
            },
            setup = {
                rust_analyzer = function()
                    return true
                end,
            },
        },
    }
}
