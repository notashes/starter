return {
    -- Fix nvim-tree window ratio issues
    {
        "nvim-tree/nvim-tree.lua",
        opts = function()
            return require "configs.nvimtree"
        end,
    },

    {
        "stevearc/conform.nvim",
        -- event = 'BufWritePre', -- uncomment for format on save
        config = function()
            require "configs.conform"
        end,
    },

    -- These are some examples, uncomment them if you want to see them work!
    {
        "neovim/nvim-lspconfig",
        opts = {
            inlay_hints = { enabled = true },
        },
        config = function()
            require("nvchad.configs.lspconfig").defaults()
            require "configs.lspconfig"
        end,
    },

    {
        "mbbill/undotree",
        lazy = false,
    },

    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "lua-language-server", "stylua", "tinymist",
                "html-lsp", "hyprls", "css-lsp", "prettier", "black",
                "gopls", "mypy", "ruff",
                "pyright", "black", "zls", "wgsl-analyzer",
                "jdtls", "java-debug-adapter", "java-test",
                "codelldb",  -- Rust debugger
                "taplo",     -- TOML LSP for Cargo.toml
            },
        },
    },

      {
        "nvim-telescope/telescope.nvim",
        opts = {
          defaults = {
                wrap_results = true,
          },
        },
      },

    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        dependencies = "nvim-telescope/telescope.nvim",
        config = function()
            require("telescope").load_extension("fzf")
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-context",
        lazy = false,
        opts = {
            mode = 'cursor', -- options
            max_lines = 3,
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "vim", "lua", "vimdoc", "rust", "wgsl",
                "hyprlang", "html", "css", "java", "thrift"
            },
            indent = { enable = true },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = "BufReadPost",
        config = function()
            require("nvim-treesitter.configs").setup({
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = { query = "@function.outer", desc = "Around function" },
                            ["if"] = { query = "@function.inner", desc = "Inside function" },
                            ["ac"] = { query = "@class.outer", desc = "Around class/impl" },
                            ["ic"] = { query = "@class.inner", desc = "Inside class/impl" },
                            ["aa"] = { query = "@parameter.outer", desc = "Around argument" },
                            ["ia"] = { query = "@parameter.inner", desc = "Inside argument" },
                            ["ai"] = { query = "@conditional.outer", desc = "Around conditional" },
                            ["ii"] = { query = "@conditional.inner", desc = "Inside conditional" },
                            ["al"] = { query = "@loop.outer", desc = "Around loop" },
                            ["il"] = { query = "@loop.inner", desc = "Inside loop" },
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = {
                            ["]f"] = { query = "@function.outer", desc = "Next function" },
                            ["]c"] = { query = "@class.outer", desc = "Next class/impl" },
                            ["]a"] = { query = "@parameter.inner", desc = "Next argument" },
                        },
                        goto_next_end = {
                            ["]F"] = { query = "@function.outer", desc = "Next function end" },
                            ["]C"] = { query = "@class.outer", desc = "Next class/impl end" },
                        },
                        goto_previous_start = {
                            ["[f"] = { query = "@function.outer", desc = "Prev function" },
                            ["[c"] = { query = "@class.outer", desc = "Prev class/impl" },
                            ["[a"] = { query = "@parameter.inner", desc = "Prev argument" },
                        },
                        goto_previous_end = {
                            ["[F"] = { query = "@function.outer", desc = "Prev function end" },
                            ["[C"] = { query = "@class.outer", desc = "Prev class/impl end" },
                        },
                    },
                    swap = {
                        enable = true,
                        swap_next = {
                            ["<leader>a"] = { query = "@parameter.inner", desc = "Swap with next arg" },
                        },
                        swap_previous = {
                            ["<leader>A"] = { query = "@parameter.inner", desc = "Swap with prev arg" },
                        },
                    },
                },
            })
        end,
    },

    {
        "nvimtools/none-ls.nvim",
        ft = { "go", "python" },
        opts = function()
            return require "configs.none-ls"
        end
    },

    {
        "hrsh7th/nvim-cmp",
        opts = function()
            local M = require "nvchad.configs.cmp"
            table.insert(M.sources, { name = "crates" })
            return M
        end
    },

    {
        "amitds1997/remote-nvim.nvim",
        version = "*",                       -- Pin to GitHub releases
        dependencies = {
            "nvim-lua/plenary.nvim",         -- For standard functions
            "MunifTanjim/nui.nvim",          -- To build the plugin UI
            "nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
        },
        config = true,
    },

    {
        "jedrzejboczar/possession.nvim",
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        opts = {
            commands = {
                save = 'SS',
                load = 'SLoad',
                delete = 'SDelete',
                list = 'SList',
            },
        },
    },
    {
        "ThePrimeagen/vim-be-good",
    },

    {
        "j-hui/fidget.nvim",
        lazy = false,
        opts = {
            -- options
        },
    },

    {   "olimorris/codecompanion.nvim",
        lazy = false
    }
}
