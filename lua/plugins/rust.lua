return {
    {
        'mrcjkb/rustaceanvim',
        version = '^4',
        ft = { 'rust' },
        opts = function()
            local codelldb_path = vim.fn.stdpath('data') .. '/mason/bin/codelldb'
            local liblldb_path = vim.fn.stdpath('data') .. '/mason/packages/codelldb/extension/lldb/lib/liblldb.dylib'

            local cfg = require('rustaceanvim.config')

            return {
                -- DAP configuration
                dap = {
                    adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
                },
                server = {
                -- Load project-specific settings from .vscode/settings.json
                load_vscode_settings = true,

                -- Fix for slow "Roots Scanned" - enable dynamic file watching registration
                capabilities = {
                    workspace = {
                        didChangeWatchedFiles = {
                            dynamicRegistration = true,
                        },
                    },
                },
                on_attach = function(client, bufnr)
                    client.server_capabilities.semanticTokensProvider = nil

                    local map = vim.keymap.set
                    local opts = { buffer = bufnr }

                    -- ===== CODE ACTIONS & REFACTORING =====
                    map("n", "<leader>ca", function()
                        vim.cmd.RustLsp("codeAction")
                    end, vim.tbl_extend("force", opts, { desc = "Code Action" }))

                    -- Quick fix - automatically apply first available fix (clippy, compiler, etc.)
                    map("n", "<leader>qf", function()
                        vim.lsp.buf.code_action({
                            filter = function(action)
                                return action.isPreferred
                            end,
                            apply = true,
                        })
                    end, vim.tbl_extend("force", opts, { desc = "Quick Fix (Auto-apply)" }))

                    -- Alternative: show only quick fixes (no extract/refactor actions)
                    map("n", "<leader>qc", function()
                        vim.lsp.buf.code_action({
                            context = {
                                only = { "quickfix" },
                                diagnostics = {},
                            },
                            apply = true,
                        })
                    end, vim.tbl_extend("force", opts, { desc = "Clippy/Compiler Fix" }))

                    map("n", "<leader>ce", function()
                        vim.cmd.RustLsp("explainError")
                    end, vim.tbl_extend("force", opts, { desc = "Explain Error" }))

                    map("n", "<leader>cd", function()
                        vim.cmd.RustLsp("renderDiagnostic")
                    end, vim.tbl_extend("force", opts, { desc = "Render Diagnostics" }))

                    -- ===== DEBUGGING =====
                    map("n", "<leader>dr", function()
                        vim.cmd.RustLsp("debuggables")
                    end, vim.tbl_extend("force", opts, { desc = "Rust Debuggables" }))

                    map("n", "<leader>dR", function()
                        vim.cmd.RustLsp { 'debuggables', bang = true }
                    end, vim.tbl_extend("force", opts, { desc = "Rust Debug Last" }))

                    -- ===== RUNNABLES =====
                    map("n", "<leader>rr", function()
                        vim.cmd.RustLsp("runnables")
                    end, vim.tbl_extend("force", opts, { desc = "Rust Runnables" }))

                    map("n", "<leader>rR", function()
                        vim.cmd.RustLsp { 'runnables', bang = true }
                    end, vim.tbl_extend("force", opts, { desc = "Rust Run Last" }))

                    map("n", "<leader>rt", function()
                        vim.cmd.RustLsp("testables")
                    end, vim.tbl_extend("force", opts, { desc = "Rust Testables" }))

                    -- ===== CARGO COMMANDS =====
                    map("n", "<leader>rc", function()
                        vim.cmd("!cargo check")
                    end, vim.tbl_extend("force", opts, { desc = "Cargo Check" }))

                    map("n", "<leader>rb", function()
                        vim.cmd("!cargo build")
                    end, vim.tbl_extend("force", opts, { desc = "Cargo Build" }))

                    map("n", "<leader>rx", function()
                        vim.cmd("!cargo run")
                    end, vim.tbl_extend("force", opts, { desc = "Cargo Run" }))

                    map("n", "<leader>rT", function()
                        vim.cmd("!cargo test")
                    end, vim.tbl_extend("force", opts, { desc = "Cargo Test All" }))

                    map("n", "<leader>rC", function()
                        vim.cmd("!cargo clippy")
                    end, vim.tbl_extend("force", opts, { desc = "Cargo Clippy" }))

                    -- ===== MACROS & EXPANSION =====
                    map("n", "<leader>me", function()
                        vim.cmd.RustLsp("expandMacro")
                    end, vim.tbl_extend("force", opts, { desc = "Expand Macro" }))

                    map("n", "<leader>mm", function()
                        vim.cmd.RustLsp("rebuildProcMacros")
                    end, vim.tbl_extend("force", opts, { desc = "Rebuild Proc Macros" }))

                    -- ===== CRATE GRAPH & DEPENDENCIES =====
                    map("n", "<leader>rv", function()
                        vim.cmd.RustLsp("view")
                    end, vim.tbl_extend("force", opts, { desc = "View Crate Graph" }))

                    map("n", "<leader>rp", function()
                        vim.cmd.RustLsp("parentModule")
                    end, vim.tbl_extend("force", opts, { desc = "Go to Parent Module" }))

                    -- ===== MOVE & REFACTOR =====
                    map("n", "<leader>mj", function()
                        vim.cmd.RustLsp("moveItem down")
                    end, vim.tbl_extend("force", opts, { desc = "Move Item Down" }))

                    map("n", "<leader>mk", function()
                        vim.cmd.RustLsp("moveItem up")
                    end, vim.tbl_extend("force", opts, { desc = "Move Item Up" }))

                    -- ===== HOVER & DOCS =====
                    map("n", "K", function()
                        vim.cmd.RustLsp { "hover", "actions" }
                    end, vim.tbl_extend("force", opts, { desc = "Hover Actions" }))

                    map("n", "<leader>rh", function()
                        vim.cmd.RustLsp { "hover", "range" }
                    end, vim.tbl_extend("force", opts, { desc = "Hover Range" }))

                    -- ===== OPEN CARGO.TOML & DOCS =====
                    map("n", "<leader>ro", function()
                        vim.cmd.RustLsp("openCargo")
                    end, vim.tbl_extend("force", opts, { desc = "Open Cargo.toml" }))

                    map("n", "<leader>rd", function()
                        vim.cmd.RustLsp("openDocs")
                    end, vim.tbl_extend("force", opts, { desc = "Open Docs.rs" }))

                    -- ===== WORKSPACE SYMBOLS =====
                    map("n", "<leader>rw", function()
                        vim.cmd.RustLsp("workspaceSymbol")
                    end, vim.tbl_extend("force", opts, { desc = "Workspace Symbol" }))

                    -- ===== JOIN LINES (Rust-specific) =====
                    map("n", "J", function()
                        vim.cmd.RustLsp("joinLines")
                    end, vim.tbl_extend("force", opts, { desc = "Join Lines" }))

                    -- ===== STANDARD LSP KEYMAPS =====
                    map("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to Declaration" }))
                    map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
                    map("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to Implementation" }))
                    map("n", "<leader>sh", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature Help" }))
                    map("n", "<leader>D", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Type Definition" }))
                    map("n", "<leader>gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "References" }))
                    map("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename" }))
                end,
                default_settings = {
                    -- Settings will be loaded from .rust-analyzer.json automatically
                    -- Only override UI preferences here
                    ["rust-analyzer"] = {
                        -- Proc macro ignores (not in .rust-analyzer.json)
                        procMacro = {
                            ignored = {
                                ["napi-derive"] = { "napi" },
                                ["async-recursion"] = { "async_recursion" },
                            },
                        },

                        -- Inlay hints (UI only, no performance impact)
                        inlayHints = {
                            chainingHints = { enable = true },
                            closureReturnTypeHints = { enable = "with_block" },
                            lifetimeElisionHints = { enable = "skip_trivial" },
                            parameterHints = { enable = true },
                            typeHints = { enable = true },
                        },

                        -- Completion snippets
                        completion = {
                            callable = { snippets = "fill_arguments" },
                        },
                    },
                },
            },
        }
        end,
        config = function(_, opts)
            -- Call opts if it's a function
            local config = type(opts) == "function" and opts() or opts
            vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, config or {})
        end,
    },

    -- Crates.nvim - Enhanced Cargo.toml support
    {
        'saecki/crates.nvim',
        event = { "BufRead Cargo.toml" },
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local crates = require('crates')
            crates.setup({
                null_ls = {
                    enabled = true,
                    name = "crates.nvim",
                },
                popup = {
                    autofocus = true,
                    border = "rounded",
                    style = "minimal",
                },
                completion = {
                    cmp = {
                        enabled = true,
                    },
                },
            })

            -- Crates keymaps (only in Cargo.toml)
            vim.api.nvim_create_autocmd("BufRead", {
                pattern = "Cargo.toml",
                callback = function(event)
                    local opts = { buffer = event.buf }
                    local map = vim.keymap.set

                    -- Info
                    map("n", "<leader>ct", crates.toggle, vim.tbl_extend("force", opts, { desc = "Crates: Toggle" }))
                    map("n", "<leader>cr", crates.reload, vim.tbl_extend("force", opts, { desc = "Crates: Reload" }))

                    -- Show info
                    map("n", "<leader>cv", crates.show_versions_popup, vim.tbl_extend("force", opts, { desc = "Crates: Show Versions" }))
                    map("n", "<leader>cf", crates.show_features_popup, vim.tbl_extend("force", opts, { desc = "Crates: Show Features" }))
                    map("n", "<leader>cd", crates.show_dependencies_popup, vim.tbl_extend("force", opts, { desc = "Crates: Show Dependencies" }))

                    -- Update
                    map("n", "<leader>cu", crates.update_crate, vim.tbl_extend("force", opts, { desc = "Crates: Update Crate" }))
                    map("v", "<leader>cu", crates.update_crates, vim.tbl_extend("force", opts, { desc = "Crates: Update Selected" }))
                    map("n", "<leader>ca", crates.update_all_crates, vim.tbl_extend("force", opts, { desc = "Crates: Update All" }))

                    -- Upgrade
                    map("n", "<leader>cU", crates.upgrade_crate, vim.tbl_extend("force", opts, { desc = "Crates: Upgrade Crate" }))
                    map("v", "<leader>cU", crates.upgrade_crates, vim.tbl_extend("force", opts, { desc = "Crates: Upgrade Selected" }))
                    map("n", "<leader>cA", crates.upgrade_all_crates, vim.tbl_extend("force", opts, { desc = "Crates: Upgrade All" }))

                    -- Open
                    map("n", "<leader>ch", crates.open_homepage, vim.tbl_extend("force", opts, { desc = "Crates: Open Homepage" }))
                    map("n", "<leader>cR", crates.open_repository, vim.tbl_extend("force", opts, { desc = "Crates: Open Repo" }))
                    map("n", "<leader>cD", crates.open_documentation, vim.tbl_extend("force", opts, { desc = "Crates: Open Docs" }))
                    map("n", "<leader>cC", crates.open_crates_io, vim.tbl_extend("force", opts, { desc = "Crates: Open crates.io" }))
                end,
            })
        end,
    },

    -- Better Rust formatting (disabled autosave - using conform.nvim instead)
    {
        "rust-lang/rust.vim",
        ft = "rust",
        init = function()
            vim.g.rustfmt_autosave = 0  -- Disabled, using conform.nvim
            vim.g.rustfmt_emit_files = 1
            vim.g.rustfmt_fail_silently = 0
        end
    },

    -- Taplo for TOML (Cargo.toml)
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
    },
}
