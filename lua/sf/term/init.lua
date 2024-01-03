local Term = require "sf.term.terminal"
local t = Term:new()
local U = require "sf.term.util"

local M = {}

function M.toggle()
  t:toggle()
end

function M.saveAndPush()
  vim.api.nvim_command('write')
  local cmd = U.expand_cmd('sf project deploy start  -d %:p ') .. U.get_target_org()
  t:run(cmd)
end

function M.retrieve()
  local cmd = U.expand_cmd('sf project retrieve start  -d %:p ') .. U.get_target_org()
  t:run(cmd)
end

function M.run(c)
  local cmd = U.expand_cmd(c)
  t:run(cmd)
end

return M