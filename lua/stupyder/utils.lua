

local M = {}

M.create_temp_filename = function(language)
    local dir = "/tmp/stupyder"
    local randStr = M.generateRandomString()
    vim.fn.mkdir(dir, "p")

    local ext = ""

    local languageMap = {
        python = "py",
        c = "c",
        bash = "sh",
    }

    ext = languageMap[language]
    if ext == "" then
        print("not supported")
    end

    return string.format("%s/%s.%s", dir, randStr, ext)
end

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

M.table_length = function(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

return M
