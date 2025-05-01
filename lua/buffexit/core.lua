local util = require("buffexit.util")
local state = require("buffexit.state")

--- @class BECore
local M = {}

--- Create a fresh placeholder buffer
--- @return integer bufnr
function M.create_placeholder()
    -- Create an unlisted, scratch buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
    vim.api.nvim_set_option_value("buftype", "", { buf = buf })
    vim.api.nvim_set_option_value("buflisted", false, { buf = buf })
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    vim.api.nvim_buf_set_var(buf, state.module .. "_placeholder", true)

    -- Display in current window
    vim.api.nvim_win_set_buf(0, buf)
    return buf
end

--- Core delete logic
--- @param action "bdelete" | "bwipeout"
--- @param bang boolean
--- @param buffer_name? string | integer
--- @param callback? fun(bufnr: integer): nil
function M.do_delete(action, bang, buffer_name, callback)
    local winvar = state.module .. "_back"
    local bufnr = util.str2bufnr(buffer_name)

    if bufnr < 0 then
        return util.report_error("E516: No buffer matches '" .. tostring(buffer_name) .. "'")
    end

    -- Remember current window to restore later
    local current_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_var(current_win, winvar, 1)

    -- Handle modified buffers using Lua API
    if vim.api.nvim_get_option_value("modified", { buf = bufnr }) and not bang then
        return util.report_error("E89: No write since last change for buffer " .. bufnr)
    elseif vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
        vim.fn.setbufvar(bufnr, "&bufhidden", "hide")
    end

    -- Iterate all windows and handle deletion
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(winid) == bufnr then
            vim.api.nvim_set_current_win(winid)

            -- Try alternate (#) or previous
            local alt = vim.fn.bufnr("#")
            if alt > 0 and vim.fn.buflisted(alt) == 1 then
                vim.api.nvim_set_current_buf(alt)
            else
                local buflist = vim.fn.getbufinfo({ buflisted = 1 })
                table.sort(buflist, function(a, b) return a.bufnr < b.bufnr end)

                local idx = 0
                for i, b in ipairs(buflist) do
                    if b.bufnr == bufnr then
                        idx = i
                        break
                    end
                end

                local bprev = idx < 1 and -1 or buflist[idx > 1 and (idx - 1) or #buflist].bufnr
                pcall(vim.api.nvim_set_current_buf, bprev)
            end

            -- If still the same buffer, call placeholder
            if vim.api.nvim_get_current_buf() == bufnr then
                local pre_fn = state.config.pre_placeholder_fn
                if pre_fn then
                    pre_fn()
                end

                local placeholder_bufnr = M.create_placeholder()

                local post_fn = state.config.post_placeholder_fn
                if post_fn then
                    post_fn(placeholder_bufnr)
                end
            end
        end
    end

    -- Restore original window
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
        local ok, val = pcall(vim.api.nvim_win_get_var, winid, winvar)
        if ok and val == 1 then
            vim.api.nvim_set_current_win(winid)
            vim.api.nvim_win_del_var(winid, winvar)
            break
        end
    end

    -- Finally delete or wipe
    if vim.fn.buflisted(bufnr) == 1 and bufnr ~= vim.api.nvim_get_current_buf() then
        vim.api.nvim_command(action .. (bang and "!" or "") .. " " .. bufnr)
    end

    -- Call the callback if it exists
    if callback then
        callback(vim.api.nvim_get_current_buf())
    end
end

--- @class BEActionOpts
local default_opts = {
    bang = false, --- @type nil | boolean  forces deletion of modified
    cb = nil,  --- @type nil | fun(bufnr: integer): nil  function to run after the action succeeds
}

--- Programmatic buffer delete
--- @param buffer? string | integer (optional) buffer name or id
--- @param opts? BEActionOpts (optional) options for bdelete action
function M.bdelete(buffer, opts)
    local o = vim.tbl_deep_extend("force", default_opts, opts or {})
    M.do_delete("bdelete", o.bang, buffer, o.cb)
end

--- Programmatic buffer wipeout
--- @param buffer? string | number (optional) buffer name or id
--- @param opts? BEActionOpts (optional) options for bwipeout action
function M.bwipeout(buffer, opts)
    local o = vim.tbl_deep_extend("force", default_opts, opts or {})
    M.do_delete("bwipeout", o.bang, buffer, o.cb)
end

return M
