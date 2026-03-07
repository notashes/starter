return {
    -- Core DAP plugin
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "folke/which-key.nvim",
            -- UI for DAP
            {
                "rcarriga/nvim-dap-ui",
                dependencies = {
                    "nvim-neotest/nvim-nio"
                },
                config = function()
                    local dap, dapui = require("dap"), require("dapui")

                    -- Setup dapui
                    dapui.setup({
                        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
                        mappings = {
                            -- Use a table to apply multiple mappings
                            expand = { "<CR>", "<2-LeftMouse>" },
                            open = "o",
                            remove = "d",
                            edit = "e",
                            repl = "r",
                            toggle = "t",
                        },
                        layouts = {
                            {
                                elements = {
                                    { id = "scopes", size = 0.4 },
                                    { id = "breakpoints", size = 0.2 },
                                    { id = "stacks", size = 0.2 },
                                    { id = "watches", size = 0.2 },
                                },
                                size = 50,
                                position = "left",
                            },
                            {
                                elements = {
                                    { id = "repl", size = 0.6 },
                                    { id = "console", size = 0.4 },
                                },
                                size = 15,  -- Increased from 10 to 15 lines (taller bottom panel)
                                position = "bottom",  -- Back to bottom
                            },
                        },
                        floating = {
                            max_height = nil,
                            max_width = nil,
                            border = "rounded",
                            mappings = {
                                close = { "q", "<Esc>" },
                            },
                        },
                        windows = { indent = 1 },
                        render = {
                            max_type_length = nil,
                            max_value_lines = 100,
                        }
                    })

                    -- Auto-open/close DAP UI
                    dap.listeners.after.event_initialized["dapui_config"] = function()
                        -- Close nvim-tree if it's open to prevent layout conflicts
                        local nvim_tree_api = require("nvim-tree.api")
                        if nvim_tree_api.tree.is_visible() then
                            nvim_tree_api.tree.close()
                        end
                        dapui.open()
                    end
                    dap.listeners.before.event_terminated["dapui_config"] = function()
                        dapui.close()
                    end
                    dap.listeners.before.event_exited["dapui_config"] = function()
                        dapui.close()
                    end
                end
            },

            -- Virtual text for variable values
            {
                "theHamsta/nvim-dap-virtual-text",
                opts = {
                    enabled = true,
                    enabled_commands = true,
                    highlight_changed_variables = true,
                    highlight_new_as_changed = false,
                    show_stop_reason = true,
                    commented = false,
                    only_first_definition = true,
                    all_references = false,
                    filter_references_pattern = '<module',
                    virt_text_pos = 'eol',
                    all_frames = false,
                    virt_lines = false,
                    virt_text_win_col = nil
                }
            },
        },

        config = function()
            local dap = require("dap")
            local wk = require("which-key")

            -- Register codelldb adapter globally
            local codelldb_path = vim.fn.stdpath('data') .. '/mason/bin/codelldb'
            dap.adapters.codelldb = {
                type = 'server',
                port = '${port}',
                executable = {
                    command = codelldb_path,
                    args = { '--port', '${port}' },
                },
            }

            -- Register Rust configurations explicitly
            dap.configurations.rust = {
                {
                    name = "Launch",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    args = {},
                    sourceLanguages = { 'rust' },  -- Enable Rust type summaries
                    -- Avoid stepping into dependencies when using F10
                    initCommands = {
                        'settings set target.process.thread.step-avoid-regexp ".*/\\.cargo/registry/.*|.*/rustc/.*|.*/target/debug/deps/.*|.*/\\.rustup/toolchains/.*"'
                    },
                },
            }

            -- Configure signs for breakpoints
            vim.fn.sign_define('DapBreakpoint', { text='🔴', texthl='', linehl='', numhl='' })
            vim.fn.sign_define('DapBreakpointCondition', { text='🟡', texthl='', linehl='', numhl='' })
            vim.fn.sign_define('DapBreakpointRejected', { text='🚫', texthl='', linehl='', numhl='' })
            vim.fn.sign_define('DapLogPoint', { text='📝', texthl='', linehl='', numhl='' })
            vim.fn.sign_define('DapStopped', { text='→', texthl='', linehl='debugPC', numhl='' })

            -- Set up highlight for stopped line
            vim.api.nvim_set_hl(0, 'debugPC', { bg = '#1f3442' })

            -- Keymaps
            local map = vim.keymap.set
            local skip_patterns = {
                "/%.cargo/registry/",
                "/rustc/",
                "/target/debug/deps/",
                "/target/release/deps/",
                "/%.rustup/toolchains/",
            }

            local function frame_in_skip(frame)
                if not frame or not frame.source or not frame.source.path then
                    return false
                end
                local path = frame.source.path
                for _, patt in ipairs(skip_patterns) do
                    if path:find(patt) then
                        return true
                    end
                end
                return false
            end

            local function step_over_user_code()
                local dap = require("dap")
                local function handle_stop()
                    local session = dap.session()
                    if not session or not session.current_frame then
                        dap.listeners.after.event_stopped["dap_skip_deps"] = nil
                        return
                    end

                    if frame_in_skip(session.current_frame) then
                        dap.step_out()
                    else
                        dap.listeners.after.event_stopped["dap_skip_deps"] = nil
                    end
                end

                dap.listeners.after.event_stopped["dap_skip_deps"] = handle_stop
                dap.step_over()
            end

            -- Main debugging controls (Function keys - classic debugger style)
            map('n', '<F5>', function() require('dap').continue() end, { desc = 'Debug: Start/Continue' })
            map('n', '<F10>', step_over_user_code, { desc = 'Debug: Step Over (skip deps)' })
            map('n', '<F11>', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
            map('n', '<F12>', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })
            map('n', '<F9>', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })

            -- Leader-based alternatives (for those who prefer leader key)
            map('n', '<leader>dc', function() require('dap').continue() end, { desc = 'Debug: Continue' })
            map('n', '<leader>ds', step_over_user_code, { desc = 'Debug: Step Over (skip deps)' })
            map('n', '<leader>di', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
            map('n', '<leader>do', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })
            map('n', '<leader>db', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
            map('n', '<leader>jd', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint (Quick)' })

            -- Advanced breakpoints
            map('n', '<leader>dB', function()
                require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
            end, { desc = 'Debug: Conditional Breakpoint' })
            map('n', '<leader>dlp', function()
                require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
            end, { desc = 'Debug: Log Point' })

            -- UI controls
            map('n', '<leader>du', function() require('dapui').toggle() end, { desc = 'Debug: Toggle UI' })
            map('n', '<leader>de', function() require('dapui').eval() end, { desc = 'Debug: Eval' })
            map('v', '<leader>de', function() require('dapui').eval() end, { desc = 'Debug: Eval Selection' })

            -- Session controls
            map('n', '<leader>dq', function() require('dap').terminate() end, { desc = 'Debug: Terminate' })
            map('n', '<leader>dR', function() require('dap').restart() end, { desc = 'Debug: Restart' })
            map('n', '<leader>dP', function() require('dap').pause() end, { desc = 'Debug: Pause' })

            -- Breakpoint management
            map('n', '<leader>dbc', function() require('dap').clear_breakpoints() end, { desc = 'Debug: Clear All Breakpoints' })

            -- REPL
            map('n', '<leader>drl', function() require('dap').repl.open() end, { desc = 'Debug: Open REPL' })
            map('n', '<leader>drr', function() require('dap').repl.run_last() end, { desc = 'Debug: Run Last' })

            -- Hover variables (multiple ways to access)
            map('n', '<leader>dh', function() require('dap.ui.widgets').hover() end, { desc = 'Debug: Hover Variables' })
            map('n', '<leader>dk', function() require('dap.ui.widgets').hover() end, { desc = 'Debug: Hover (K alternative)' })
            map('n', '<leader>dw', function()
                local widgets = require('dap.ui.widgets')
                widgets.centered_float(widgets.scopes)
            end, { desc = 'Debug: Scopes' })

            -- Alternative: Use gK for debug hover (doesn't conflict with normal K)
            map('n', 'gK', function()
                local dap = require('dap')
                if dap.session() then
                    require('dap.ui.widgets').hover()
                else
                    vim.notify("Not in a debug session. Use K for LSP hover.", vim.log.levels.INFO)
                end
            end, { desc = 'Debug Hover' })

            -- Print variable in REPL (for complex types)
            map('n', '<leader>dp', function()
                local word = vim.fn.expand('<cword>')
                local dap = require('dap')
                if dap.session() then
                    -- Use dbg! macro style in REPL
                    dap.repl.execute('p ' .. word)
                    vim.notify("Evaluating: " .. word, vim.log.levels.INFO)
                else
                    vim.notify("Not in debug session", vim.log.levels.WARN)
                end
            end, { desc = 'Print variable in REPL' })

            -- Evaluate with format (better for collections)
            map('n', '<leader>df', function()
                local word = vim.fn.expand('<cword>')
                local dap = require('dap')
                if dap.session() then
                    dap.repl.execute('p ' .. word)
                    -- Open REPL if not visible
                    require('dapui').open()
                    vim.notify("Check REPL for output: " .. word, vim.log.levels.INFO)
                else
                    vim.notify("Not in debug session", vim.log.levels.WARN)
                end
            end, { desc = 'Format print variable' })

            -- Create simple user commands
            vim.api.nvim_create_user_command('Bp', function()
                require('dap').toggle_breakpoint()
            end, { desc = 'Toggle Breakpoint' })

            vim.api.nvim_create_user_command('DapAttach', function()
                local pid = vim.fn.input('Enter PID to attach: ')
                if pid and pid ~= '' then
                    require('dap').run({
                        name = 'Attach to process ' .. pid,
                        type = 'codelldb',
                        request = 'attach',
                        pid = tonumber(pid),
                        stopOnEntry = false,
                        cwd = vim.fn.getcwd(),
                        sourceLanguages = { 'rust' },  -- Keep Rust pretty-printing when attaching
                    })
                end
            end, { desc = 'Attach debugger to process' })

            -- Register with which-key for better discoverability
            wk.add({
                { "<leader>d", group = "Debug" },
                { "<leader>db", desc = "Toggle Breakpoint" },
                { "<leader>dB", desc = "Conditional Breakpoint" },
                { "<leader>jd", desc = "Toggle Breakpoint (Quick)" },
                { "<leader>dc", desc = "Continue" },
                { "<leader>ds", desc = "Step Over" },
                { "<leader>di", desc = "Step Into" },
                { "<leader>do", desc = "Step Out" },
                { "<leader>du", desc = "Toggle UI" },
                { "<leader>de", desc = "Eval" },
                { "<leader>dq", desc = "Quit" },
                { "<leader>dR", desc = "Restart" },
                { "<leader>dP", desc = "Pause" },
                { "<leader>dh", desc = "Hover" },
                { "<leader>dw", desc = "Widgets" },
                { "<leader>dl", group = "Log/REPL" },
                { "<leader>dlp", desc = "Log Point" },
                { "<leader>drl", desc = "Open REPL" },
                { "<leader>drr", desc = "Run Last" },
                { "<leader>dbc", desc = "Clear All Breakpoints" },
            })
        end,
    },
}
