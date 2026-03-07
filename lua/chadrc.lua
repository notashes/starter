-- This file  needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

local stbufnr = function()
  return vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
end

M.ui = {
    nvdash = {
        load_on_startup = true,
        buttons = {
            { "  Find File", "Spc f f", "Telescope find_files" },
            { "󰈚  Recent Files", "Spc f o", "Telescope oldfiles" },
            { "󰈭  Find Word", "Spc f w", "Telescope live_grep" },
            { "  Bookmarks", "Spc m a", "Telescope marks" },
            { "  Themes", "Spc t h", "Telescope themes" },
            { "  Sessions", "Spc f s", "Ssession List" },
            { "  Mappings", "Spc c h", "NvCheatsheet" },
        },
    },
    -- hl_override = {
    -- 	Comment = { italic = true },
    -- 	["@comment"] = { italic = true },
    -- },
    statusline = {
        order = {"mode", "relativepath", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "cwd", "cursor", "session"}, -- check stl/utils.lua file in ui repo 
        modules = {
            session = function()
                local session_name = require('possession.session').get_session_name() or ''
                return session_name
            end,
            relativepath = function()
                local path = vim.api.nvim_buf_get_name(stbufnr())

                if path == "" then
                  return ""
                end

                return "%#St_relativepath#  " .. vim.fn.expand("%:.:h") .. " /"
            end,
        }
    }
}

M.base46 = {
    theme = "ayu_dark"
}

M.nvdash = {
  -- load_on_startup = true,
}

-- hl_add = {
--     St_relativepath = {
--       bg = "black2",
--     },
-- },

-- M.plugins = {
--     -- ...
--     ["nvim-telescope/telescope.nvim"] = {
--         override_options = function()
--             return {
--                 defaults = {
--                     wrap_results = true;
--                 },
--             }
--         end,
--     },
--     -- ...
-- }

return M
