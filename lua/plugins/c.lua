return {
  {
    "nvim-treesitter/nvim-treesitter",
    ft = { "c", "cpp" },
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "c", "cpp" })
      else
        opts.ensure_installed = { "c", "cpp" }
      end
    end,
  },
  {
    "williamboman/mason.nvim",
    optional = true,
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "clangd", "clang-format", "codelldb" })
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    ft = { "c", "cpp" },
    dependencies = {
      {
        "p00f/clangd_extensions.nvim",
        config = function(plugin)
          local register_keys_and_cmp = function()
            local cmp = require("cmp")
            local wk = require("which-key")
            local bufnr = vim.api.nvim_get_current_buf()

            ---@diagnostic disable-next-line: missing-fields
            cmp.setup({
              ---@diagnostic disable-next-line: missing-fields
              sorting = {
                comparators = {
                  cmp.config.compare.offset,
                  cmp.config.compare.exact,
                  cmp.config.compare.recently_used,
                  require("clangd_extensions.cmp_scores"),
                  cmp.config.compare.kind,
                  cmp.config.compare.sort_text,
                  cmp.config.compare.length,
                  cmp.config.compare.order,
                },
              },
            })

            wk.register({
              r = { "<cmd>ClangdSwitchSourceHeader<cr>", "Switch Source/Header" },
              a = { "<cmd>ClangdAST<cr>", "Display AST" },
              h = { "<cmd>ClangdToggleInlayHints<cr>", "Toggle Inlay Hints" },
              t = { "<cmd>ClangdTypeHierarchy<cr>", "Display Type Hierarchy" },
              m = { "<cmd>ClangdMemoryUsage<cr>", "Display Memory Usage" },
              s = { "<cmd>ClangdSymbolInfo<cr>", "Display Symbol Info" },
              c = { "<cmd>ClangdCallHierarchy<cr>", "Display Call Hierarchy" },
            }, {
              prefix = "<leader>cc",
              name = "+c",
              buffer = bufnr,
            })
          end

          vim.api.nvim_create_autocmd(
            "FileType",
            { pattern = { "c", "cpp", "h", "hpp" }, callback = register_keys_and_cmp }
          )

          return true
        end,
        keys = {},
        opts = {
          inlay_hints = {
            inline = vim.fn.has("nvim-0.10") == 1,
            highlight = "CopilotSuggestion",
          },
          ast = {
            role_icons = {
              type = " ",
              declaration = " ",
              expression = " ",
              specifier = " ",
              statement = " ",
              ["template argument"] = " ",
            },

            kind_icons = {
              Compound = " ",
              Recovery = " ",
              TranslationUnit = " ",
              PackExpansion = " ",
              TemplateTypeParm = " ",
              TemplateTemplateParm = " ",
              TemplateParamObject = " ",
            },
            highlights = {
              detail = "CopilotSuggestion",
            },
          },
          -- memory_usage = {
          --   border = "single",
          -- },
          -- symbol_info = {
          --   border = "single",
          -- },
        },
      },
    },
  },
}
