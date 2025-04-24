
local M = {}

function M.spy_wrap(table, key, return_value)
  table[key] = function() return return_value end
  spy.on(table, key)
end

return M
