local util = require("buffexit.util")
local state = require("buffexit.state")
local core = require("buffexit.core")

local M = {}

--- User Configuration Table
--- @class BEConfig
state.config = {
    --- Whether to avoid opening netrw when nvim opens a directory
    hijack_netrw = false, --- @type nil | boolean

    --- Function to run after hijacking netrw
    post_hijack_fn = nil, --- @type nil | fun(): nil

    --- Function to run before creating and opening placeholder buffer
    pre_placeholder_fn = nil, --- @type nil | fun(): nil

    --- Function to run after creating and opening placeholder buffer
    --- (placeholder's buffer number as parameter)
    post_placeholder_fn = nil, --- @type nil | fun(bufnr: integer): nil
}

--- Setup function for package manager or manual require
--- @param opts? BEConfig
function M.setup(opts)
    state.config = vim.tbl_deep_extend("force", state.config, opts or {})

    if state.initialized then return end
    state.initialized = true

    -- User commands
    vim.api.nvim_create_user_command("Bdelete", function(cmd)
        core.bdelete(cmd.args, cmd.bang)
    end, { bang = true, nargs = "?", complete = "buffer", desc = "User friendly bdelete" })

    vim.api.nvim_create_user_command("Bwipeout", function(cmd)
        core.bwipeout(cmd.args, cmd.bang)
    end, { bang = true, nargs = "?", complete = "buffer", desc = "User friendly bwipeout" })

    -- Autocommands
    if not state.config.hijack_netrw then return end

    local grp = vim.api.nvim_create_augroup(state.module, { clear = true })

    vim.api.nvim_create_autocmd("VimEnter", {
        group = grp,
        callback = function()
            util.hijack_netrw()
        end,
    })

    vim.api.nvim_create_autocmd("BufEnter", {
        group = grp,
        callback = function(args)
            util.remove_dir_buf(args, state.config.post_hijack_fn)
        end,
    })
end

return M
