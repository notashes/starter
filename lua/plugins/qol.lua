-- Quality of Life improvements
return {
    -- Better diagnostics list with Trouble
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            auto_close = true,
            auto_open = false,
            auto_preview = true,
            auto_fold = false,
            use_diagnostic_signs = true,
        },
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
            { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
            { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions / references / ... (Trouble)" },
            { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
            { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
        },
    },

    -- Toggle terminal
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        keys = {
            { "<leader>gg", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", desc = "Lazygit" },
            { "<leader>tw", "<cmd>lua _CARGO_WATCH_TOGGLE()<CR>", desc = "Toggle Cargo Watch" },
            { "<leader>tR", "<cmd>lua _CARGO_RUN_TOGGLE()<CR>", desc = "Toggle Cargo Run Terminal" },
            { "<leader>tT", "<cmd>lua _CARGO_TEST_TOGGLE()<CR>", desc = "Toggle Cargo Test Terminal" },
            { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Toggle Horizontal Terminal" },
            { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Toggle Vertical Terminal" },
            { "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", desc = "Toggle Floating Terminal" },
        },
        opts = {
            size = function(term)
                if term.direction == "horizontal" then
                    return 15
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.4
                end
            end,
            open_mapping = [[<c-\>]],
            hide_numbers = true,
            shade_terminals = true,
            shading_factor = 2,
            start_in_insert = true,
            insert_mappings = true,
            terminal_mappings = true,
            persist_size = true,
            persist_mode = true,
            direction = "horizontal",
            close_on_exit = true,
            shell = vim.o.shell,
            float_opts = {
                border = "curved",
                winblend = 0,
            },
        },
        config = function(_, opts)
            require("toggleterm").setup(opts)

            -- Custom terminals for Rust workflows
            local Terminal = require("toggleterm.terminal").Terminal

            -- Cargo watch (auto-recompile on save)
            local cargo_watch = Terminal:new({
                cmd = "cargo watch -x check -x test -x run",
                direction = "horizontal",
                hidden = true,
            })

            function _CARGO_WATCH_TOGGLE()
                cargo_watch:toggle()
            end

            -- Cargo run
            local cargo_run = Terminal:new({
                cmd = "cargo run",
                direction = "horizontal",
                hidden = true,
                close_on_exit = false,
            })

            function _CARGO_RUN_TOGGLE()
                cargo_run:toggle()
            end

            -- Cargo test with output
            local cargo_test = Terminal:new({
                cmd = "cargo test -- --nocapture",
                direction = "horizontal",
                hidden = true,
                close_on_exit = false,
            })

            function _CARGO_TEST_TOGGLE()
                cargo_test:toggle()
            end

            -- Lazygit terminal
            local lazygit = Terminal:new({ cmd = "lazygit", direction = "float", hidden = true })
            function _LAZYGIT_TOGGLE()
                lazygit:toggle()
            end

            -- Terminal keymaps (navigation handled by zellij-nav via Alt+hjkl)
            function _G.set_terminal_keymaps()
                local opts = { buffer = 0 }
                vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
                vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
            end

            vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
        end,
    },

    -- Better code context at top of screen
    {
        "nvim-treesitter/nvim-treesitter-context",
        opts = {
            enable = true,
            max_lines = 3,
            min_window_height = 20,
            line_numbers = false,
            multiline_threshold = 2,
            trim_scope = "outer",
            mode = "cursor",
            separator = nil,
        },
    },

    -- Auto-pairs for brackets
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local npairs = require("nvim-autopairs")
            local Rule = require("nvim-autopairs.rule")
            local cond = require("nvim-autopairs.conds")

            npairs.setup({
                check_ts = true,
                ts_config = {
                    lua = { "string" },
                    javascript = { "template_string" },
                    rust = { "string_literal", "raw_string_literal" },
                },
                fast_wrap = {
                    map = "<M-e>",
                    chars = { "{", "[", "(", '"', "'" },
                    pattern = [=[[%'%"%>%]%)%}%,]]=],
                    end_key = "$",
                    keys = "qwertyuiopzxcvbnmasdfghjkl",
                    check_comma = true,
                    highlight = "Search",
                    highlight_grey = "Comment",
                },
            })

            -- Add spaces inside brackets
            local brackets = { { "(", ")" }, { "[", "]" }, { "{", "}" } }
            npairs.add_rules({
                Rule(" ", " "):with_pair(function(opts)
                    local pair = opts.line:sub(opts.col - 1, opts.col)
                    return vim.tbl_contains({
                        brackets[1][1] .. brackets[1][2],
                        brackets[2][1] .. brackets[2][2],
                        brackets[3][1] .. brackets[3][2],
                    }, pair)
                end),
            })
            for _, bracket in pairs(brackets) do
                npairs.add_rules({
                    Rule(bracket[1] .. " ", " " .. bracket[2])
                        :with_pair(function()
                            return false
                        end)
                        :with_move(function(opts)
                            return opts.prev_char:match(".%" .. bracket[2]) ~= nil
                        end)
                        :use_key(bracket[2]),
                })
            end

            -- Integrate with cmp
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            local cmp = require("cmp")
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },

    -- Better folding
    {
        "kevinhwang91/nvim-ufo",
        dependencies = {
            "kevinhwang91/promise-async",
        },
        event = "BufReadPost",
        opts = {
            provider_selector = function(bufnr, filetype, buftype)
                return { "treesitter", "indent" }
            end,
        },
        config = function(_, opts)
            require("ufo").setup(opts)

            -- Folding keymaps
            vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
            vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
            vim.keymap.set("n", "zr", function()
                require("ufo").openFoldsExceptKinds({ "comment", "imports" })
            end, { desc = "Open folds except comments/imports" })
            vim.keymap.set("n", "zm", function()
                require("ufo").closeFoldsWith(1)
            end, { desc = "Close folds to level 1" })
            vim.keymap.set("n", "<CR>", "za", { desc = "Toggle fold under cursor" })
            vim.keymap.set("n", "zp", require("ufo").peekFoldedLinesUnderCursor, { desc = "Peek fold" })

            -- Set fold level
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true
            vim.o.foldcolumn = "0"  -- Disabled - no fold column numbers
        end,
    },

    -- Illuminate - highlight word under cursor
    {
        "RRethy/vim-illuminate",
        event = "BufReadPost",
        opts = {
            delay = 200,
            large_file_cutoff = 2000,
            large_file_overrides = {
                providers = { "lsp" },
            },
            filetypes_denylist = {
                "dirvish",
                "fugitive",
                "alpha",
                "NvimTree",
                "lazy",
                "neogitstatus",
                "Trouble",
                "lir",
                "Outline",
                "spectre_panel",
                "toggleterm",
                "DressingSelect",
                "TelescopePrompt",
            },
        },
        config = function(_, opts)
            require("illuminate").configure(opts)

            -- Keymaps for navigating illuminated words
            vim.keymap.set("n", "]]", function()
                require("illuminate").goto_next_reference(false)
            end, { desc = "Next Reference" })

            vim.keymap.set("n", "[[", function()
                require("illuminate").goto_prev_reference(false)
            end, { desc = "Prev Reference" })
        end,
    },

    -- Better quickfix/loclist
    {
        "kevinhwang91/nvim-bqf",
        ft = "qf",
        opts = {
            auto_resize_height = true,
            preview = {
                win_height = 12,
                win_vheight = 12,
                delay_syntax = 80,
                border = "rounded",
            },
            func_map = {
                vsplit = "",
                ptogglemode = "z,",
                stoggleup = "",
            },
            filter = {
                fzf = {
                    action_for = { ["ctrl-s"] = "split" },
                    extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
                },
            },
        },
    },

    -- Git signs with better integration
    {
        "lewis6991/gitsigns.nvim",
        event = "BufReadPre",
        opts = {
            -- signs = {
            --     add = { text = "▎" },
            --     change = { text = "▎" },
            --     delete = { text = "" },
            --     topdelete = { text = "" },
            --     changedelete = { text = "▎" },
            --     untracked = { text = "▎" },
            -- },
            -- signcolumn = true,
            -- numhl = false,
            -- linehl = false,
            -- word_diff = false,
            -- watch_gitdir = {
            --     interval = 1000,
            --     follow_files = true,
            -- },
            -- attach_to_untracked = true,
            -- current_line_blame = false,
            -- current_line_blame_opts = {
            --     virt_text = true,
            --     virt_text_pos = "eol",
            --     delay = 1000,
            --     ignore_whitespace = false,
            -- },
            -- sign_priority = 6,
            -- update_debounce = 100,
            -- status_formatter = nil,
            -- max_file_length = 40000,
            -- preview_config = {
            --     border = "rounded",
            --     style = "minimal",
            --     relative = "cursor",
            --     row = 0,
            --     col = 1,
            -- },
        },
        config = function(_, opts)
            require("gitsigns").setup(opts)

            -- Keymaps for git operations
            local gs = require("gitsigns")

            vim.keymap.set("n", "]h", gs.next_hunk, { desc = "Next Git Hunk" })
            vim.keymap.set("n", "[h", gs.prev_hunk, { desc = "Prev Git Hunk" })
            vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { desc = "Preview Hunk" })
            vim.keymap.set("n", "<leader>gl", gs.blame_line, { desc = "Blame Line" })
            vim.keymap.set("n", "<leader>gL", function()
                gs.blame_line({ full = true })
            end, { desc = "Blame Line (full)" })
            vim.keymap.set("n", "<leader>gd", gs.diffthis, { desc = "Diff This" })
            vim.keymap.set("n", "<leader>gD", function()
                gs.diffthis("~")
            end, { desc = "Diff This ~" })

            -- Stage/reset hunks
            vim.keymap.set("n", "<leader>hs", gs.stage_hunk, { desc = "Stage Hunk" })
            vim.keymap.set("n", "<leader>hr", gs.reset_hunk, { desc = "Reset Hunk" })
            vim.keymap.set("v", "<leader>hs", function()
                gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, { desc = "Stage Hunk" })
            vim.keymap.set("v", "<leader>hr", function()
                gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, { desc = "Reset Hunk" })

            -- Toggle git blame
            vim.keymap.set("n", "<leader>gt", gs.toggle_current_line_blame, { desc = "Toggle Git Blame" })
        end,
    },

    -- Zen mode for focused coding
    {
        "folke/zen-mode.nvim",
        cmd = "ZenMode",
        opts = {
            window = {
                backdrop = 0.95,
                width = 120,
                height = 1,
                options = {
                    signcolumn = "no",
                    number = false,
                    relativenumber = false,
                    cursorline = false,
                    cursorcolumn = false,
                    foldcolumn = "0",
                    list = false,
                },
            },
            plugins = {
                options = {
                    enabled = true,
                    ruler = false,
                    showcmd = false,
                },
                twilight = { enabled = false },
                gitsigns = { enabled = false },
                tmux = { enabled = false },
            },
        },
        keys = {
            { "<leader>z", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" },
        },
    },

    -- Better UI: hover, cmdline, messages, notifications
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            {
                "rcarriga/nvim-notify",
                opts = {
                    stages = "static",
                    timeout = 3000,
                },
            },
        },
        opts = {
            views = {
                hover = {
                    border = {
                        style = { "", "─", "", "", "", "─", "", "" },
                        padding = { 0, 1 },
                    },
                    win_options = {
                        winhighlight = { Normal = "Folded", FloatBorder = "Folded" },
                        winblend = 0,
                    },
                },
            },
            lsp = {
                progress = { enabled = false }, -- keep fidget.nvim for this
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
                hover = { enabled = true },
                signature = { enabled = true },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
                lsp_doc_border = true,
            },
        },
    },

    -- Better search and replace
    {
        "nvim-pack/nvim-spectre",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        keys = {
            {
                "<leader>sr",
                function()
                    require("spectre").open()
                end,
                desc = "Search & Replace (Spectre)",
            },
            {
                "<leader>sw",
                function()
                    require("spectre").open_visual({ select_word = true })
                end,
                desc = "Search current word",
            },
            {
                "<leader>sf",
                function()
                    require("spectre").open_file_search({ select_word = true })
                end,
                desc = "Search in current file",
            },
        },
    },

    -- Surround text objects
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        opts = {},
    },

    -- Flash.nvim for quick navigation
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
            { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
            { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
            { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
        },
    },

    -- TODO comments highlighting and searching
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "BufReadPost",
        opts = {},
        keys = {
            { "]T", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
            { "[T", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
            { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "Find TODOs" },
        },
    },

    -- Diffview for git diffs
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory" },
        keys = {
            { "<leader>gv", "<cmd>DiffviewOpen<CR>", desc = "Git Diff View" },
            { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Git File History" },
            { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Git Repo History" },
            { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Close Diffview" },
        },
    },

    -- Incremental rename
    {
        "smjonas/inc-rename.nvim",
        cmd = "IncRename",
        opts = {},
    },

    -- Indent guides
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = "BufReadPost",
        opts = {
            indent = { char = "│" },
            scope = { enabled = true, show_start = true, show_end = false },
            exclude = {
                filetypes = { "help", "alpha", "dashboard", "NvimTree", "Trouble", "lazy", "mason", "toggleterm" },
            },
        },
    },

    -- Inline color preview
    {
        "NvChad/nvim-colorizer.lua",
        event = "BufReadPost",
        opts = {
            filetypes = { "*" },
            user_default_options = {
                css = true,
                css_fn = true,
                names = false,
                mode = "virtualtext",
                virtualtext = "■",
                suppress_deprecation = true,
            },
        },
    },

    -- File bookmarks (Harpoon v2)
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>ma", function() require("harpoon"):list():add() end, desc = "Harpoon Add File" },
            { "<C-e>", function() local harpoon = require("harpoon") harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Harpoon Menu" },
            { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "Harpoon File 1" },
            { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "Harpoon File 2" },
            { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "Harpoon File 3" },
            { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "Harpoon File 4" },
        },
        config = function()
            require("harpoon"):setup()
        end,
    },

    -- Subword motions (camelCase/snake_case aware)
    {
        "chrisgrieser/nvim-spider",
        keys = {
            { "w", function() require("spider").motion("w") end, mode = { "n", "o", "x" }, desc = "Spider w" },
            { "e", function() require("spider").motion("e") end, mode = { "n", "o", "x" }, desc = "Spider e" },
            { "b", function() require("spider").motion("b") end, mode = { "n", "o", "x" }, desc = "Spider b" },
        },
    },

    -- Search counter virtual text
    {
        "kevinhwang91/nvim-hlslens",
        event = "CmdlineEnter",
        opts = { calm_down = true, nearest_only = true },
        config = function(_, o)
            require("hlslens").setup(o)
            local kopts = { noremap = true, silent = true }
            vim.keymap.set("n", "n", [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>zzzv]], kopts)
            vim.keymap.set("n", "N", [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>zzzv]], kopts)
            vim.keymap.set("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
            vim.keymap.set("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
        end,
    },

    -- Yank ring
    {
        "gbprod/yanky.nvim",
        event = "VeryLazy",
        opts = {
            ring = { history_length = 50, storage = "shada" },
            highlight = { on_put = true, on_yank = true, timer = 200 },
        },
        keys = {
            { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Yanky put after" },
            { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Yanky put before" },
            { "]y", "<Plug>(YankyCycleForward)", desc = "Cycle yank forward" },
            { "[y", "<Plug>(YankyCycleBackward)", desc = "Cycle yank backward" },
            { "<leader>fy", function() require("telescope").extensions.yank_history.yank_history({}) end, desc = "Yank History" },
        },
        config = function(_, o)
            require("yanky").setup(o)
            require("telescope").load_extension("yank_history")
        end,
    },

}
