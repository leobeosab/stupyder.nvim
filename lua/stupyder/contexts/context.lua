local Context = {}
Context.__index = Context

function Context:new()
    local context = setmetatable({}, Context)
    return context
end

function Context:is_running()
    print("Is running not implemented for context")
end

function Context:run(language, code)
    print("Run not implemented for context")
end

function Context:cancel()
    print("Cancel not implemented for context")
end

return Context
