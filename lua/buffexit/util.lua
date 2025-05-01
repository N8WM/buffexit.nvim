local M = {}

--- Prevent netrw from showing
function M.hijack_netrw()
    vim.cmd("silent! autocmd! FileExplorer")
end

--- Immediately close any directory buffers
--- @param args vim.api.keyset.create_autocmd.callback_args
--- @param state BEState
--- @param core BECore
function M.remove_dir_buf(args, state, core)
    local path = vim.fn.expand(args.match)
    if vim.fn.isdirectory(path) == 1 then
        core.bwipeout(args.buf, { cb = state.config.post_hijack_fn })
    end
end

--- Show an error without full stacktrace
--- @param msg string
function M.report_error(msg)
    vim.api.nvim_echo({ { msg, "ErrorMsg" } }, true, {})
    vim.api.nvim_set_vvar("errmsg", msg)
end

--- Convert buffer name/number to bufnr
--- @param buffer? string | integer
--- @return integer
function M.str2bufnr(buffer)
    if buffer == nil or buffer == "" then
        return vim.fn.bufnr("%")
    elseif tostring(buffer):match("^%d+$") then
        return vim.fn.bufnr(tonumber(buffer))
    else
        return vim.fn.bufnr(buffer)
    end
end

return M
