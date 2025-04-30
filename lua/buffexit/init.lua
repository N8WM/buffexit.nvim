local config = require("buffexit.config")
local core = require("buffexit.core")

local M = {}

M.setup = config.setup
M.bdelete = core.bdelete
M.bwipeout = core.bwipeout

return M
