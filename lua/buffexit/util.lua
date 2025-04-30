local M = {}

--- Prevent netrw from showing
function M.hijack_netrw()
    vim.cmd("silent! autocmd! FileExplorer")
end

--- Immediately close any directory buffers
--- @param args vim.api.keyset.create_autocmd.callback_args
--- @param hijack_fn nil | fun(): nil
function M.remove_dir_buf(args, hijack_fn)
    local path = vim.fn.expand(args.match)
    if vim.fn.isdirectory(path) == 1 then
        vim.cmd("Bwipeout " .. args.buf)
        if hijack_fn then
            vim.schedule(hijack_fn)
        end
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
