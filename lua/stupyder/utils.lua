

local M = {}

M.append_to_buffer = function(buff, lines)
    if not vim.api.nvim_buf_is_valid(buff) then
        print("Stupyder buff not valid")
        return
    end

    local current_line = vim.api.nvim_buf_line_count(buff) - 1

    vim.api.nvim_buf_set_lines(buff, current_line, current_line, false, lines)
end

M.generateRandomString = function()
    local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local result = {}
    for i = 1, 12 do
        local index = math.random(#chars)
        result[i] = chars:sub(index, index)
    end

    return table.concat(result)
end

M.isInbetween = function(val, a, b)
    local low = a > b and b or a
    local high = a > b and a or b

    if val >= low and val <= high then
        return true
    end

    return false
end

return M
