return {
    -- In-editor markdown rendering
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
        },
        ft = { 'markdown' },
        opts = {
            -- Headings with different colors and icons
            headings = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
            -- Enable code block highlighting
            code = {
                enabled = true,
                sign = true,
                style = 'full',
                position = 'left',
                width = 'full',
                left_pad = 0,
                right_pad = 0,
                min_width = 0,
                border = 'thin',
                above = '▄',
                below = '▀',
                highlight = 'RenderMarkdownCode',
            },
            -- Bullet points and checkboxes
            bullet = {
                enabled = true,
                icons = { '●', '○', '◆', '◇' },
                right_pad = 0,
                highlight = 'RenderMarkdownBullet',
            },
            -- Checkboxes
            checkbox = {
                enabled = true,
                unchecked = { icon = '󰄱 ', highlight = 'RenderMarkdownUnchecked' },
                checked = { icon = '󰱒 ', highlight = 'RenderMarkdownChecked' },
            },
            -- Block quotes
            quote = {
                enabled = true,
                icon = '▋',
                highlight = 'RenderMarkdownQuote',
            },
            -- Horizontal rules
            dash = {
                enabled = true,
                icon = '─',
                width = 'full',
                highlight = 'RenderMarkdownDash',
            },
            -- Inline code
            pipe_table = {
                enabled = true,
                style = 'full',
                cell = 'padded',
                border = {
                    '┌', '┬', '┐',
                    '├', '┼', '┤',
                    '└', '┴', '┘',
                    '│', '─',
                },
                head = 'RenderMarkdownTableHead',
                row = 'RenderMarkdownTableRow',
                filler = 'RenderMarkdownTableFill',
            },
            -- Links
            link = {
                enabled = true,
                image = '󰥶 ',
                hyperlink = '󰌹 ',
                highlight = 'RenderMarkdownLink',
            },
            -- LaTeX
            latex = {
                enabled = true,
                converter = 'latex2text',
                highlight = 'RenderMarkdownMath',
            },
            win_options = {
                conceallevel = {
                    default = vim.api.nvim_get_option_value('conceallevel', {}),
                    rendered = 2,
                },
                concealcursor = {
                    default = vim.api.nvim_get_option_value('concealcursor', {}),
                    rendered = 'nc',
                },
            },
        },
        config = function(_, opts)
            require('render-markdown').setup(opts)

            -- Keymaps
            vim.keymap.set('n', '<leader>mr', '<cmd>RenderMarkdown toggle<cr>', { desc = 'Toggle Markdown Render' })
            vim.keymap.set('n', '<leader>me', '<cmd>RenderMarkdown enable<cr>', { desc = 'Enable Markdown Render' })
            vim.keymap.set('n', '<leader>md', '<cmd>RenderMarkdown disable<cr>', { desc = 'Disable Markdown Render' })
        end,
    },

    -- Optional: Markdown table mode for easy table editing
    {
        'dhruvasagar/vim-table-mode',
        ft = { 'markdown' },
        config = function()
            vim.g.table_mode_corner = '|'
            vim.g.table_mode_corner_corner = '|'
            vim.g.table_mode_header_fillchar = '-'

            -- Keymaps (only in markdown files)
            vim.api.nvim_create_autocmd('FileType', {
                pattern = 'markdown',
                callback = function()
                    vim.keymap.set('n', '<leader>tm', '<cmd>TableModeToggle<cr>', { buffer = true, desc = 'Toggle Table Mode' })
                    vim.keymap.set('n', '<leader>tt', '<cmd>Tableize<cr>', { buffer = true, desc = 'Tableize' })
                end,
            })
        end,
    },
}
