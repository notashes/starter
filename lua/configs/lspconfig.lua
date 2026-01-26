-- Migrated to nvim 0.11 native LSP config API
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

-- Helper for root pattern
local function root_pattern(...)
    local patterns = {...}
    return function(fname)
        local util = vim.fs
        for _, pattern in ipairs(patterns) do
            local found = util.find(pattern, { path = fname, upward = true })
            if found and #found > 0 then
                return vim.fs.dirname(found[1])
            end
        end
    end
end

-- HTML
vim.lsp.config.html = {
    cmd = { 'vscode-html-language-server', '--stdio' },
    filetypes = { 'html' },
    root_dir = root_pattern('.git'),
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
}

-- CSS
vim.lsp.config.cssls = {
    cmd = { 'vscode-css-language-server', '--stdio' },
    filetypes = { 'css', 'scss', 'less' },
    root_dir = root_pattern('.git'),
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
}

-- TypeScript
vim.lsp.config.ts_ls = {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
    root_dir = root_pattern('tsconfig.json', 'package.json', '.git'),
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
}

-- Go
vim.lsp.config.gopls = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_dir = root_pattern('go.work', 'go.mod', '.git'),
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
                unusedparams = true,
            },
            ['ui.inlayhint.hints'] = {
                compositeLiteralFields = true,
                constantValues = true,
                parameterNames = true
            },
        },
    },
}

-- Python
vim.lsp.config.pyright = {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_dir = root_pattern('pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git'),
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        pyright = {
            disableOrganizeImports = true,
        },
        python = {
            analysis = {
                ignore = { '*' },
            },
        },
    },
}

-- Ruff
vim.lsp.config.ruff = {
    cmd = { 'ruff', 'server' },
    filetypes = { 'python' },
    root_dir = root_pattern('pyproject.toml', 'ruff.toml', '.git'),
    on_attach = function(client, bufnr)
        client.server_capabilities.hoverProvider = false
        if on_attach then on_attach(client, bufnr) end
    end,
    on_init = on_init,
    capabilities = capabilities,
    init_options = {
        settings = {
            args = {},
        }
    },
}

-- Clangd
vim.lsp.config.clangd = {
    cmd = { 'clangd' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
    root_dir = root_pattern('compile_commands.json', 'compile_flags.txt', '.git'),
    on_attach = function(client, bufnr)
        client.server_capabilities.signatureHelpProvider = false
        if on_attach then on_attach(client, bufnr) end
    end,
    capabilities = capabilities,
    settings = {
        clangd = {}
    },
}

-- Zig
vim.lsp.config.zls = {
    cmd = { 'zls' },
    filetypes = { 'zig', 'zir' },
    root_dir = root_pattern('zls.json', 'build.zig', '.git'),
}

-- WGSL
vim.lsp.config.wgsl_analyzer = {
    cmd = { 'wgsl_analyzer' },
    filetypes = { 'wgsl' },
    root_dir = root_pattern('.git'),
}

-- Tinymist (Typst)
vim.lsp.config.tinymist = {
    cmd = { 'tinymist' },
    filetypes = { 'typst' },
    single_file_support = true,
    root_dir = function()
        return vim.fn.getcwd()
    end,
    on_init = on_init,
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        formatterPrintWidth = 90,
        exportPdf = "onType",
        outputPath = "$root/target/$dir/$name",
        formatterMode = "typstyle",
    },
}
