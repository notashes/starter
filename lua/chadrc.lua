-- This file  needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

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
--     statusline = {
--         order = {"mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "cwd", "cursor", "session"}, -- check stl/utils.lua file in ui repo 
--         modules = {
--             session = function()
--                 local session_name = require('possession.session').get_session_name() or ''
--                 return session_name
--             end
--         }
--     }
}

M.base46 = {
    theme = "ayu_dark_better"
}

M.nvdash = {
  load_on_startup = true,
}

return M
