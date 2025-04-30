# buffexit.nvim

A Lua-based adaptation of [moll/vim-bbye](https://github.com/moll/vim-bbye) with additional configurable options. Use this as a drop-in replacement for `vim-bbye` or any call to Vim's built-in `:bdelete` or `:bwipeout`.

## Configuration

The default configuration is just an empty table; all options are `nil`.

```lua
require("buffexit").config({
    -- Whether to avoid opening NetRW when Neovim is opened on a dir
    hijack_netrw = nil,
    -- Function that is run when NetRW is bipassed
    post_hijack_fn = nil,

    -- Function that is run before creating placeholder
    pre_placeholder_fn = nil,
    -- Function that is run after creating placeholder
    post_placeholder_fn = nil,
})
```

### NetRW Hijacking

By setting `hijack_netrw = true`, buffexit.nvim silences the `FileExplorer` autocommand event and automatically closes any buffers whose path is a directory, leaving only a placeholder buffer open. Pair this with `post_hijack_fn` to launch your preferred file-explorer plugin (e.g., `neo-tree.nvim`):

```lua
require("buffexit").config({
    hijack_netrw = true,
    post_hijack_fn = function()
        vim.cmd("Neotree show")  -- effectively replaces NetRW
    end,
})
```

### Hooks

Two optional hooks let you run code before and after the placeholder buffer is created.

```lua
require("buffexit").config({
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

-- optionally force-delete a buffer (bang: boolean)
require("buffexit").bdelete(14, true)    -- forced
require("buffexit").bdelete("foo", false)  -- not forced
```

```lua
-- bwipeout the current buffer
require("buffexit").bwipeout()

-- bwipeout a specific buffer (by name or number)
require("buffexit").bwipeout(14)
require("buffexit").bwipeout("foo")

-- optionally force-wipeout a buffer (bang: boolean)
require("buffexit").bwipeout(14, true)    -- forced
require("buffexit").bwipeout("foo", false)  -- not forced
```

### Vim Commands

You can also invoke these via command-line in Vim/Neovim:

```vim
:Bdelete
:Bdelete 14
:Bdelete! foo.txt
:Bwipeout
:Bwipeout! 14
:Bwipeout foo.txt
```
