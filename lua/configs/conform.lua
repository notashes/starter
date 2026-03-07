local options = {
    formatters_by_ft = {
        lua = { "stylua" },
        -- css = { "prettier" },
        -- html = { "prettier" },
        rust = { "rustfmt" },  -- Use system rustfmt (cargo fmt)
    },

    -- Custom formatters configuration
    formatters = {
        rustfmt = {
            command = "rustfmt",
            args = { "--edition", "2024" },  -- Adjust edition as needed
        },
    },

    format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 1000,
        lsp_fallback = true,
    },
}

require("conform").setup(options)
