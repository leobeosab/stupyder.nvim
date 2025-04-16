local Mode = {}
Mode.__index = Mode

function Mode:new()
    local context = setmetatable({}, Mode)
    return context
end

function Mode:start()
    print("Is running not implemented for mode")
end

function Mode:append_lines()
    print("Run not implemented for mode")
end

function Mode:done()
    print("Cancel not implemented for mode")
end

return Mode
