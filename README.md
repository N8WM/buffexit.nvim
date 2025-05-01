# buffexit.nvim

A Lua-based adaptation of [moll/vim-bbye](https://github.com/moll/vim-bbye) with additional configurable options. Use this as a drop-in replacement for `vim-bbye` or any call to Vim's built-in `:bdelete` or `:bwipeout`.

## Configuration

The default configuration is just an empty table; all options are `nil`. Below is an example of how **buffexit.nvim** could be set up with the default configuration using the **Lazy.nvim** package manager.

**Lazy.nvim**
```lua
return {
    "N8WM/buffexit.nvim",
    config = function()
        require("buffexit").setup({
            -- `hijack_netrw` - boolean
            -- Whether to avoid opening NetRW when nvim run with a dir
            hijack_netrw = nil,
            -- `post_hijack_fn` - fun(bufnr: integer): nil
            -- Function that is run when NetRW is bipassed
            post_hijack_fn = nil,
            -- `pre_placeholder_fn` - fun(): nil
            -- Function that is run before creating placeholder
            pre_placeholder_fn = nil,
            -- `post_placeholder_fn` - fun(bufnr: integer): nil
            -- Function that is run after creating placeholder
            post_placeholder_fn = nil,
        })
    end,
}
```

### NetRW Hijacking

By setting `hijack_netrw = true`, buffexit.nvim silences the `FileExplorer` autocommand event and automatically closes any buffers whose path is a directory, leaving only a placeholder buffer open. Pair this with `post_hijack_fn` to launch your preferred file-explorer plugin (e.g., `neo-tree.nvim`):

```lua
require("buffexit").setup({
    hijack_netrw = true,
    post_hijack_fn = function()
        vim.cmd("Neotree show")  -- effectively replaces NetRW
    end,
})
```

### Hooks

Two optional hooks let you run code before and after the placeholder buffer is created.

```lua
require("buffexit").setup({
    pre_placeholder_fn = function()
        print("Printed before opening placeholder")
        -- Any cleanup or pre-placeholder code can go here
    end,
    post_placeholder_fn = function(bufnr)
        print("The buffer id of the placeholder buffer is " .. bufnr)
        -- Any code to configure the placeholder buffer can go here
    end,
})
```

## Usage

### Lua API

Use the Lua functions to delete or wipe buffers programmatically:

```lua
-- bdelete the current buffer
require("buffexit").bdelete()

-- bdelete a specific buffer (by name or number)
require("buffexit").bdelete(14)
require("buffexit").bdelete("foo")

-- optionally force-bdelete a specific buffer
-- { bang = <boolean> }
require("buffexit").bdelete(14, { bang = true })  -- forced
require("buffexit").bdelete("foo", { bang = false })  -- not forced

-- optionally run callback after bdelete succeeds
-- { cb = <fun(bufnr: integer): nil> }

-- The following snippet deletes current buffer & prints name of new one
require("buffexit").bdelete({
    cb = function(bufnr)
        print("Current buffer: " .. vim.api.nvim_buf_get_name(bufnr))
    end,
})
```

```lua
-- bwipeout the current buffer
require("buffexit").bwipeout()

-- bwipeout a specific buffer (by name or number)
require("buffexit").bwipeout(14)
require("buffexit").bwipeout("foo")

-- optionally force-bwipeout a specific buffer (bang: boolean)
require("buffexit").bwipeout(14, { bang = true })  -- forced
require("buffexit").bwipeout("foo", { bang = false })  -- not forced

-- optionally run callback after bwipeout succeeds
-- { cb = <fun(bufnr: integer): nil> }

-- The following snippet wipes current buffer & prints name of new one
require("buffexit").bwipeout({
    cb = function(bufnr)
        print("Current buffer: " .. vim.api.nvim_buf_get_name(bufnr))
    end,
})
```

### Vim Commands

You can also invoke these via Vim commands:

```vim
:Bdelete
:Bdelete 14
:Bdelete! foo.txt
:Bwipeout
:Bwipeout! 14
:Bwipeout foo.txt
```
