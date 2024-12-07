return {
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
                "rust-analyzer", "gopls", "mypy", "ruff",
                "pyright", "black", "zls", "wgsl-analyzer",
            },
        },
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
                "hyprlang", "html", "css"
            },
            indent = { enable = true },
        },
    },

    {
        "nvimtools/none-ls.nvim",
        ft = { "go", "python" },
        opts = function()
            return require "configs.none-ls"
        end
    },

    {
        "rust-lang/rust.vim",
        ft = "rust",
        init = function()
            vim.g.rustfmt_autosave = 1
        end
    },

    {
        'saecki/crates.nvim',
        tag = 'stable',
        ft = { "rust", "toml" },
        config = function()
            require('crates').setup()
            require('crates').show()
        end,
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

    {
        "amitds1997/remote-nvim.nvim",
        lazy = false,
        version = "*",                       -- Pin to GitHub releases
        dependencies = {
            "nvim-lua/plenary.nvim",         -- For standard functions
            "MunifTanjim/nui.nvim",          -- To build the plugin UI
            "nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
        },
        config = true,
    },
}
