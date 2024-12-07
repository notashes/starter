-- EXAMPLE 
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local servers = { "html", "cssls" }
local util = require "lspconfig/util"

for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = on_attach,
        on_init = on_init,
        capabilities = capabilities,
    }
end

-- typescript
lspconfig.ts_ls.setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
}

lspconfig.gopls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = {"gopls"},
    filetypes = {"go", "gomod", "gowork", "gotmpl"},
    root_dir = util.root_pattern("go.work", "go.mod", ".git"),
    settings = {
        gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
                unusedparams = true,
            },
            ["ui.inlayhint.hints"] = {
                compositeLiteralFields = true,
                constantValues = true,
                parameterNames = true
            },

        },
    },
}

lspconfig.pyright.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = {"python"},
    settings = {
        pyright = {
            -- Using Ruff's import organizer
            disableOrganizeImports = true,
        },
        python = {
            analysis = {
                -- Ignore all files for analysis to exclusively use Ruff for linting
                ignore = { '*' },
            },
        },
    },
}

lspconfig.ruff.setup {
    on_attach = function (client, _)
        client.server_capabilities.hoverProvider = false
    end,
    on_init = on_init,
    capabilities = capabilities,
    init_options = {
        settings = {
            -- Any extra CLI arguments for `ruff` go here.
            args = {},
        }
    }
}

lspconfig.clangd.setup {
    on_attach = function (client, bufnr)
        client.server_capabilities.signatureHelpProvider = false
        on_attach(client, bufnr)
    end,
    capabilities = capabilities,
    settings = {
        clangd = {
            -- todo 
        }
    }
}

lspconfig.zls.setup {}
lspconfig.wgsl_analyzer.setup {}

lspconfig.tinymist.setup {
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
