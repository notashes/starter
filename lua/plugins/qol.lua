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

            -- Keymaps for custom terminals
            vim.keymap.set("n", "<leader>tw", "<cmd>lua _CARGO_WATCH_TOGGLE()<CR>", { desc = "Toggle Cargo Watch" })
            vim.keymap.set("n", "<leader>tR", "<cmd>lua _CARGO_RUN_TOGGLE()<CR>", { desc = "Toggle Cargo Run Terminal" })
            vim.keymap.set("n", "<leader>tT", "<cmd>lua _CARGO_TEST_TOGGLE()<CR>", { desc = "Toggle Cargo Test Terminal" })

            -- General terminal keymaps
            vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", { desc = "Toggle Horizontal Terminal" })
            vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", { desc = "Toggle Vertical Terminal" })
            vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", { desc = "Toggle Floating Terminal" })

            -- Better terminal navigation
            function _G.set_terminal_keymaps()
                local opts = { buffer = 0 }
                vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
                vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
                vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
                vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
                vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
                vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
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
            vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
            vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with" })
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
            vim.keymap.set("n", "<leader>gb", gs.blame_line, { desc = "Blame Line" })
            vim.keymap.set("n", "<leader>gB", function()
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
            vim.keymap.set("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "Toggle Git Blame" })
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
}
