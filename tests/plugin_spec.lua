local function is_placeholder(bufnr)
    if not bufnr then
        bufnr = vim.api.nvim_get_current_buf()
    end
    local ok, val = pcall(vim.api.nvim_buf_get_var, bufnr, "buffexit_placeholder")
    return ok and (val == true)
end

describe("buffexit", function()
    local be = require("buffexit")

    before_each(function()
        package.loaded["buffexit"] = nil
        be = require("buffexit")
    end)

    it("can be required", function() end)

    it("can be set up", function()
        be.setup()
    end)

    it("can be set up with options", function()
        be.setup({
            pre_placeholder_fn = function() end,
            post_placeholder_fn = function(_) end,
        })
    end)

    it("can Bdelete through API", function()
        be.setup()

        local bstart = #vim.api.nvim_list_bufs()
        local loop = 10
        local bufs = {}

        for _ = 1, loop, 1 do
            bufs[#bufs + 1] = vim.api.nvim_create_buf(true, true)
            vim.api.nvim_set_current_buf(bufs[#bufs])
        end

        assert.are_equal(bstart + loop, #vim.api.nvim_list_bufs(), "Unexpected number of buffers were opened")

        for _ = 1, loop, 1 do
            local buf = table.remove(bufs)
            assert.are_equal(buf, vim.api.nvim_get_current_buf(), "Unexpected current buffer number")

            be.bdelete(buf)
            assert.is_false(
                vim.api.nvim_get_option_value("buflisted", { buf = buf }),
                "Unexpected 'listed' buffer after calling Bdelete"
            )
        end

        assert.are_equal(
            bstart + loop,
            #vim.api.nvim_list_bufs(),
            "Unexpected number of buffers open after calling Bdelete"
        )
    end)

    it("can Bwipeout through API", function()
        be.setup()

        local bstart = #vim.api.nvim_list_bufs()
        local loop = 10
        local bufs = {}

        for _ = 1, loop, 1 do
            bufs[#bufs + 1] = vim.api.nvim_create_buf(true, true)
            vim.api.nvim_set_current_buf(bufs[#bufs])
        end

        assert.are_equal(bstart + loop, #vim.api.nvim_list_bufs(), "Not all buffers opened as expected")

        for _ = 1, loop, 1 do
            assert.are_equal(bufs[#bufs], vim.api.nvim_get_current_buf(), "Current buffer number was not expected")
            be.bwipeout(table.remove(bufs))
        end

        assert.are_equal(
            bstart,
            #vim.api.nvim_list_bufs(),
            "Unexpected number of buffers still open after calling Bwipeout"
        )
    end)

    it("can Bdelete through VIM command", function()
        be.setup()

        local bstart = #vim.api.nvim_list_bufs()
        local loop = 10
        local bufs = {}

        for _ = 1, loop, 1 do
            bufs[#bufs + 1] = vim.api.nvim_create_buf(true, true)
            vim.api.nvim_set_current_buf(bufs[#bufs])
        end

        assert.are_equal(bstart + loop, #vim.api.nvim_list_bufs(), "Unexpected number of buffers were opened")

        for _ = 1, loop, 1 do
            local buf = table.remove(bufs)
            assert.are_equal(buf, vim.api.nvim_get_current_buf(), "Unexpected current buffer number")

            vim.cmd("Bdelete " .. buf)
            assert.is_false(
                vim.api.nvim_get_option_value("buflisted", { buf = buf }),
                "Unexpected 'listed' buffer after calling Bdelete"
            )
        end

        assert.are_equal(
            bstart + loop,
            #vim.api.nvim_list_bufs(),
            "Unexpected number of buffers open after calling Bdelete"
        )
    end)

    it("can Bwipeout through VIM command", function()
        be.setup()

        local bstart = #vim.api.nvim_list_bufs()
        local loop = 10
        local bufs = {}

        for _ = 1, loop, 1 do
            bufs[#bufs + 1] = vim.api.nvim_create_buf(true, true)
            vim.api.nvim_set_current_buf(bufs[#bufs])
        end

        assert.are_equal(bstart + loop, #vim.api.nvim_list_bufs(), "Not all buffers opened as expected")

        for _ = 1, loop, 1 do
            assert.are_equal(bufs[#bufs], vim.api.nvim_get_current_buf(), "Current buffer number was not expected")
            vim.cmd("Bwipeout " .. table.remove(bufs))
        end

        assert.are_equal(
            bstart,
            #vim.api.nvim_list_bufs(),
            "Unexpected number of buffers still open after calling Bwipeout"
        )
    end)

    it("can open a placeholder", function()
        be.setup()

        be.bdelete()
        local bufnr = vim.api.nvim_get_current_buf()
        assert.is_true(is_placeholder(bufnr), "Unexpected non-placeholder after closing only buffer")

        be.bdelete()
        assert.is_false(is_placeholder(bufnr), "Unexpected placeholder not updating after closing placeholder")

        bufnr = vim.api.nvim_get_current_buf()
        assert.is_true(is_placeholder(bufnr), "Unexpected non-placeholder after closing placeholder")

        vim.api.nvim_set_current_buf(vim.api.nvim_create_buf(true, true))
        assert.is_false(is_placeholder(bufnr), "Unexpected placeholder not closing after opening file")

        be.bdelete()
        bufnr = vim.api.nvim_get_current_buf()
        assert.is_true(is_placeholder(bufnr), "Unexpected non-placeholder after closing last buffer")
    end)

    it("can run hooks", function()
        local ref = { pre = false, post = 0 }

        be.setup({
            pre_placeholder_fn = function()
                ref.pre = true
            end,
            post_placeholder_fn = function(bufnr)
                ref.post = bufnr
            end,
        })

        be.bdelete()
        assert.is_true(is_placeholder(), "Unexpected non-placeholder after closing only buffer")
        assert.is_true(ref.pre, "Unexpected failure to call pre_placeholder_fn")
        assert.are_equal(
            vim.api.nvim_get_current_buf(),
            ref.post,
            "Unexpected failure to call post_placeholder_fn, or wrong arg value"
        )
    end)
end)
