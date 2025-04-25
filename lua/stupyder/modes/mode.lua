local Mode = {}
Mode.__index = Mode

function Mode:new()
    local context = setmetatable({}, Mode)
    return context
end

function Mode:start()
end

function Mode:append_lines()
end

function Mode:append_errors()
end

function Mode:done()
end

function Mode:clean()
end

return Mode
